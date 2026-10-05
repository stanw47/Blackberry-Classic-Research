/*
 * binder.c — Android 11 binder driver, reimplemented as a QNX resource manager.
 *
 * Grounded in:
 *   - Blackberry 10.2/10.3 QNX resource manager headers (sys/resmgr.h, sys/iofunc.h)
 *   - RIM 4.3 binary disassembly (specimens/binder: binder_devctl @ 0x4128,
 *     iofunc_devctl_verify, MsgInfo, pthread_cond_wait, shm_open, shm_ctl,
 *     mmap_peer, munmap_peer)
 *   - Portable A11 binder engine (binder_core.c, binder_handlers.c)
 *
 * Wire ABI is Android 11 (ARM32 64-bit layout, protocol version 8).
 * Build: QNX SDP ARM cross-toolchain (qcc -V4.8.2,gcc_ntoarmv7le).
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <stdint.h>
#include <stdarg.h>

/* QNX custom OCB declaration before iofunc.h defines RESMGR_OCB_T */
struct binder_ocb;
#define IOFUNC_OCB_T struct binder_ocb

#include <sys/iofunc.h>
#include <sys/dispatch.h>
#include <sys/resmgr.h>
#include <sys/mman.h>
#include <sys/neutrino.h>
#include <sys/slog2.h>
#include <sys/shm.h>

#include "binder_a11.h"
#include "binder_core.h"
#include "binder_handlers.h"

/* Per-mountpoint device attributes (/dev/binder, /dev/hwbinder, /dev/vndbinder).
 * Each path gets its own struct binder_ctx, isolating handle spaces. */
struct binder_attr {
    iofunc_attr_t       attr;
    struct binder_ctx  *ctx;
    const char         *path;
};

/* One shm region per process. RIM's binder created a shm object on open
 * and mapped it into both the client process and the driver process via
 * mmap_peer. The client's binder_write_read.write_buffer/read_buffer and
 * transaction data pointers all live inside this shared region.
 *
 * We track: client_vaddr (as seen by libbinder) -> driver_vaddr (our mmap). */
struct binder_shm_region {
    char                name[32];      /* shm object name: "binder-proc-<pid>" */
    int                 fd;            /* shm_open fd */
    void               *driver_vaddr;  /* our mmap address */
    size_t              size;          /* region size (e.g. 1 MiB) */
    binder_uintptr_t    client_base;   /* client virtual base (from mmap_peer) */
};

/* Allocate and map a shm region for a process.
 * Returns 0 on success, -errno on failure.
 * The region is mapped into our address space; the client will map it
 * via mmap_peer (triggered by the client's libbionic on first transaction). */
static int
binder_shm_region_create(struct binder_shm_region *r, int pid)
{
    snprintf(r->name, sizeof(r->name), "binder-proc-%d", pid);
    r->size = 1024 * 1024;   /* 1 MiB per process (RIM used 1 MiB max_txn_size) */

    r->fd = shm_open(r->name, O_RDWR | O_CREAT | O_EXCL, 0600);
    if (r->fd == -1) {
        if (errno == EEXIST) {
            /* Already exists (client raced); open it */
            r->fd = shm_open(r->name, O_RDWR, 0);
            if (r->fd == -1)
                return -errno;
        } else {
            return -errno;
        }
    }

    /* Set size and physical backing */
    if (shm_ctl(r->fd, SHM_CTL_ANON | SHM_CTL_PHYS, 0, r->size) == -1) {
        int e = errno;
        close(r->fd);
        shm_unlink(r->name);
        return -e;
    }

    /* Map into driver address space */
    r->driver_vaddr = mmap(NULL, r->size, PROT_READ | PROT_WRITE, MAP_SHARED, r->fd, 0);
    if (r->driver_vaddr == MAP_FAILED) {
        int e = errno;
        close(r->fd);
        shm_unlink(r->name);
        return -e;
    }

    /* Client base will be filled when client maps it via mmap_peer.
     * The client's libbionic maps on first transaction; we learn the
     * client_base from the first buffer pointer we see in WRITE_READ. */
    r->client_base = 0;

    return 0;
}

static void
binder_shm_region_destroy(struct binder_shm_region *r)
{
    if (r->driver_vaddr && r->driver_vaddr != MAP_FAILED) {
        munmap(r->driver_vaddr, r->size);
        r->driver_vaddr = NULL;
    }
    if (r->fd >= 0) {
        close(r->fd);
        r->fd = -1;
    }
    shm_unlink(r->name);
}

/* Translate a client virtual address to our driver mapping.
 * Returns driver_vaddr on success, NULL on failure (address not in our region). */
static void *
binder_shm_translate(const struct binder_shm_region *r, binder_uintptr_t client_addr)
{
    if (r->client_base == 0) {
        /* Not yet known; we can't translate. This happens if the
         * client hasn't mapped the region yet. The client maps on
         * first transaction; we'll learn client_base then. */
        return NULL;
    }
    if (client_addr < r->client_base ||
        client_addr >= r->client_base + r->size) {
        return NULL;
    }
    return (char *)r->driver_vaddr + (client_addr - r->client_base);
}

/* Called when we see a buffer pointer from the client (in WRITE_READ).
 * If we don't know client_base yet, infer it from the pointer. */
static void
binder_shm_maybe_init_client_base(struct binder_shm_region *r,
                                  binder_uintptr_t client_ptr)
{
    if (r->client_base != 0)
        return;

    /* Heuristic: the client's mmap_peer typically returns a page-aligned
     * address. We assume the first buffer we see is at offset 0 within
     * the region, so client_base = client_ptr & ~(PAGE_SIZE-1).
     * This matches RIM's observed pattern where the shm region is mapped
     * at a fixed offset and buffers start at the base. */
    r->client_base = client_ptr & ~(uintptr_t)(sysconf(_SC_PAGESIZE) - 1);
}

/* ------------------------------------------------------------------ */
/* Memory accessor implementation (binder_mem) backed by shm          */
/* ------------------------------------------------------------------ */

static int
binder_shm_mem_read(void *opaque, binder_uintptr_t addr, void *dst, size_t len)
{
    struct binder_shm_region *r = (struct binder_shm_region *)opaque;
    void *src = binder_shm_translate(r, addr);
    if (!src)
        return -EFAULT;
    memcpy(dst, src, len);
    return 0;
}

static int
binder_shm_mem_write(void *opaque, binder_uintptr_t addr, const void *src, size_t len)
{
    struct binder_shm_region *r = (struct binder_shm_region *)opaque;
    void *dst = binder_shm_translate(r, addr);
    if (!dst)
        return -EFAULT;
    memcpy(dst, src, len);
    return 0;
}

static struct binder_mem
binder_shm_mem(struct binder_shm_region *r)
{
    return (struct binder_mem){
        .opaque = r,
        .read   = binder_shm_mem_read,
        .write  = binder_shm_mem_write,
    };
}

/* Per-open connection state */
struct binder_ocb {
    iofunc_ocb_t             hdr;
    struct binder_attr      *gattr;
    struct binder_proc      *proc;
    struct binder_shm_region shm;   /* payload transport for this proc */
};

/* Logging helper: falls back to stderr if slog2 is not yet initialized */
void
binder_log(const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
}

/* ------------------------------------------------------------------ */
/* Custom OCB allocation hooks (called by iofunc_ocb_attach/detach)    */
/* ------------------------------------------------------------------ */

static struct binder_ocb *
binder_ocb_calloc(resmgr_context_t *ctp, iofunc_attr_t *attr)
{
    (void)ctp;
    (void)attr;
    return calloc(1, sizeof(struct binder_ocb));
}

static void
binder_ocb_free(struct binder_ocb *ocb)
{
    if (ocb) {
        /* Clean up shm region if initialized */
        if (ocb->shm.driver_vaddr) {
            binder_shm_region_destroy(&ocb->shm);
        }
        free(ocb);
    }
}

static iofunc_funcs_t binder_ocb_funcs = {
    _IOFUNC_NFUNCS,
    binder_ocb_calloc,
    binder_ocb_free,
    NULL,
    NULL,
    NULL
};

/* ------------------------------------------------------------------ */
/* resmgr connect funcs: open                                         */
/* ------------------------------------------------------------------ */

static int
binder_open(resmgr_context_t *ctp, io_open_t *msg,
            RESMGR_HANDLE_T *handle, void *extra)
{
    struct binder_attr *gattr = (struct binder_attr *)handle;
    struct binder_ocb *ocb;
    struct _client_info cinfo;
    int ret;

    /* Verify client permissions */
    ret = iofunc_client_info(ctp, msg->connect.ioflag, &cinfo);
    if (ret != EOK)
        return ret;

    /* Allocate custom OCB */
    ocb = binder_ocb_calloc(ctp, &gattr->attr);
    if (!ocb)
        return ENOMEM;

    ocb->gattr = gattr;

    /* Initialize proc in engine.
     * TODO: map QNX uid to Android uid via libbionic's table (cinfo.cred.euid) */
    ocb->proc = binder_proc_open(gattr->ctx, cinfo.pid, cinfo.cred.euid);
    if (!ocb->proc) {
        binder_ocb_free(ocb);
        return ENOMEM;
    }

    /* Create shared memory region for this process's payload buffers */
    ret = binder_shm_region_create(&ocb->shm, cinfo.pid);
    if (ret != 0) {
        binder_proc_close(gattr->ctx, ocb->proc);
        binder_ocb_free(ocb);
        return -ret;
    }

    /* Attach OCB to QNX resmgr framework */
    ret = iofunc_ocb_attach(ctp, msg, (iofunc_ocb_t *)ocb, &gattr->attr, NULL);
    if (ret != EOK) {
        binder_proc_close(gattr->ctx, ocb->proc);
        binder_ocb_free(ocb);
        return ret;
    }

    binder_log("[binder] proc %d attached, shm region '%s' created\n",
               cinfo.pid, ocb->shm.name);

    return EOK;
}

/* ------------------------------------------------------------------ */
/* resmgr io funcs: close_ocb                                         */
/* ------------------------------------------------------------------ */

static int
binder_close_ocb(resmgr_context_t *ctp, void *reserved, RESMGR_OCB_T *ocb)
{
    struct binder_ocb *b_ocb = (struct binder_ocb *)ocb;

    if (b_ocb && b_ocb->proc && b_ocb->gattr) {
        binder_log("[binder] proc detaching, closing shm region\n");
        binder_proc_close(b_ocb->gattr->ctx, b_ocb->proc);
        b_ocb->proc = NULL;
    }

    /* binder_ocb_free will clean up the shm region */
    return iofunc_close_ocb_default(ctp, reserved, (iofunc_ocb_t *)ocb);
}

/* ------------------------------------------------------------------ */
/* resmgr io funcs: devctl                                            */
/* ------------------------------------------------------------------ */

static int
binder_devctl(resmgr_context_t *ctp, io_devctl_t *msg, RESMGR_OCB_T *ocb)
{
    struct binder_ocb *b_ocb = (struct binder_ocb *)ocb;
    unsigned int cmd = (unsigned int)msg->i.dcmd;
    size_t req = _IOC_SIZE(cmd);
    uint8_t stage[256];
    int ret;

    /* Verify devctl permissions (RIM did checks=0x13: READ|WRITE|VERIFY_MSG_LEN) */
    ret = iofunc_devctl_verify(ctp, msg, (iofunc_ocb_t *)ocb, 0);
    if (ret != EOK)
        return ret;

    if (!b_ocb || !b_ocb->proc || !b_ocb->gattr)
        return EBADF;

    if (req > sizeof(stage))
        return EINVAL;

    /* Data argument is located inline immediately after header */
    void *data_ptr = (void *)(msg + 1);

    if (req > 0)
        memcpy(stage, data_ptr, req);
    else
        memset(stage, 0, sizeof(stage));

    /* Resolve caller thread from QNX tid */
    struct binder_thread *thr = binder_thread_get(b_ocb->proc, ctp->info.tid);
    if (!thr)
        return ENOMEM;

    /* For WRITE_READ, we may see client buffer pointers that tell us
     * where the client mapped the shm region. Update our client_base. */
    if (cmd == BINDER_WRITE_READ) {
        struct binder_write_read *bwr = (struct binder_write_read *)stage;
        if (bwr->write_buffer != 0)
            binder_shm_maybe_init_client_base(&b_ocb->shm, bwr->write_buffer);
        if (bwr->read_buffer != 0)
            binder_shm_maybe_init_client_base(&b_ocb->shm, bwr->read_buffer);
    }

    struct binder_call call = {
        .ctx      = b_ocb->gattr->ctx,
        .proc     = b_ocb->proc,
        .thread   = thr,
        .mem      = binder_shm_mem(&b_ocb->shm),
        .nonblock = (b_ocb->hdr.ioflag & O_NONBLOCK) ? 1 : 0,
    };

    ret = binder_handle_ioctl(&call, cmd, stage, req);
    if (ret < 0)
        return -ret;   /* Return positive errno to QNX resmgr */

    /* Copy back reply data if the command carries an output struct */
    if (ret > 0) {
        memcpy(data_ptr, stage, (size_t)ret);
        msg->o.ret_val = 0;
        msg->o.nbytes = (uint32_t)ret;
        return _RESMGR_PTR(ctp, &msg->o, sizeof(msg->o) + (size_t)ret);
    }

    msg->o.ret_val = 0;
    msg->o.nbytes = 0;
    return _RESMGR_PTR(ctp, &msg->o, sizeof(msg->o));
}

/* ------------------------------------------------------------------ */
/* main entry point                                                   */
/* ------------------------------------------------------------------ */

int
main(int argc, char **argv)
{
    dispatch_t *dpp;
    resmgr_io_funcs_t io_funcs;
    resmgr_connect_funcs_t connect_funcs;
    resmgr_attr_t rattr;
    int i;

    if (argc < 2) {
        fprintf(stderr, "usage: binder <path> [<path> ...]\n");
        fprintf(stderr, "  e.g.: binder /dev/binder /dev/hwbinder /dev/vndbinder\n");
        return EXIT_FAILURE;
    }

    fprintf(stderr, "[binder] init: before dispatch_create\n");
    dpp = dispatch_create();
    if (!dpp) {
        perror("dispatch_create");
        return EXIT_FAILURE;
    }

    memset(&rattr, 0, sizeof(rattr));
    rattr.nparts_max = 4096;
    rattr.msg_max_size = 1048576;

    fprintf(stderr, "[binder] init: before iofunc_func_init\n");
    iofunc_func_init(_RESMGR_CONNECT_NFUNCS, &connect_funcs,
                     _RESMGR_IO_NFUNCS, &io_funcs);
    fprintf(stderr, "[binder] init: after iofunc_func_init\n");

    connect_funcs.open = binder_open;
    io_funcs.close_ocb = binder_close_ocb;
    io_funcs.devctl    = binder_devctl;

    /* Attach each requested path with its own independent engine context */
    for (i = 1; i < argc; i++) {
        struct binder_attr *gattr = calloc(1, sizeof(struct binder_attr));
        if (!gattr) {
            perror("calloc");
            return EXIT_FAILURE;
        }

        gattr->path = argv[i];
        gattr->ctx = binder_ctx_alloc(1024 * 1024);
        if (!gattr->ctx) {
            fprintf(stderr, "failed to allocate binder ctx for %s\n", argv[i]);
            return EXIT_FAILURE;
        }

        fprintf(stderr, "[binder] init: iofunc_attr_init(%s)\n", argv[i]);
        iofunc_attr_init(&gattr->attr, S_IFCHR | 0666, NULL, NULL);
        fprintf(stderr, "[binder] init: before resmgr_attach(%s)\n", argv[i]);
        gattr->attr.mount = calloc(1, sizeof(iofunc_mount_t));
        if (gattr->attr.mount)
            gattr->attr.mount->funcs = &binder_ocb_funcs;

        int id = resmgr_attach(dpp, &rattr, argv[i], _FTYPE_ANY, 0,
                               &connect_funcs, &io_funcs, (RESMGR_HANDLE_T *)gattr);
        if (id == -1) {
            fprintf(stderr, "resmgr_attach('%s') failed: %s\n", argv[i], strerror(errno));
            return EXIT_FAILURE;
        }

        binder_log("[binder] attached '%s' (A11 wire ABI, proto %d)\n",
                   argv[i], BINDER_CURRENT_PROTOCOL_VERSION);
    }

    /* Start thread pool for concurrent request dispatch */
    thread_pool_attr_t tattr;
    memset(&tattr, 0, sizeof(tattr));
    tattr.handle = dpp;
    tattr.context_alloc = dispatch_context_alloc;
    tattr.block_func = dispatch_block;
    tattr.unblock_func = dispatch_unblock;
    tattr.handler_func = dispatch_handler;
    tattr.context_free = dispatch_context_free;
    tattr.lo_water = 2;
    tattr.hi_water = 4;
    tattr.maximum  = 8;

    thread_pool_t *tpp = thread_pool_create(&tattr, 0);
    if (!tpp) {
        perror("thread_pool_create");
        return EXIT_FAILURE;
    }

    thread_pool_start(tpp);
    return EXIT_SUCCESS;
}