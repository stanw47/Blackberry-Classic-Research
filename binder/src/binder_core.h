/*
 * binder_core.h — portable Android 11 binder driver engine (kernel-semantics).
 *
 * This is the heart of the A11 binder-on-QNX resmgr port: a faithful port of
 * the android11-5.4 kernel binder driver's data model + transaction flow,
 * expressed as a self-contained C engine with NO kernel/QNX dependencies.
 *
 * The QNX resmgr glue
 *   (a) receives the ioctl (as a devctl message, cmd in msg->i.cmd)
 *   (b) has already copied-in the 48-byte binder_write_read struct
 *   (c) calls binder_ioctl() with the bwr and a `binder_mem` accessor that
 *       bridges the write_buffer/read_buffer pointers (client addresses) to
 *       driver-accessible memory (shm on QNX, host pointers in the simulator).
 *
 * Wire ABI is binder_a11.h: 64-bit layout, protocol version 8, exact A11
 * ioctl numbers + BC_/BR_ command words (all disasm/source verified).
 */

#ifndef BINDER_CORE_H
#define BINDER_CORE_H

#include <stddef.h>
#include <stdint.h>
#include <pthread.h>
#include "binder_a11.h"

#ifdef __cplusplus
extern "C" {
#endif

/* ---- memory accessor (client address -> driver-accessible bytes) ----
 * On QNX: opaque = shm/context handle; read/write translate the bwr's
 * client virtual addresses into the shared mapping (RIM did shm+mmap_peer).
 * Host simulator: opaque = NULL and addr is a real host pointer (same proc).
 * Returns 0 on success, -errno on failure. */
struct binder_mem {
    void *opaque;
    int (*read)(void *opaque, binder_uintptr_t addr, void *dst, size_t len);
    int (*write)(void *opaque, binder_uintptr_t addr, const void *src, size_t len);
};

/* ---- forward decls ---- */
struct binder_ctx;
struct binder_proc;
struct binder_thread;
struct binder_node;

/* ---- host memory accessor (also used by QNX glue as the reference
 *       implementation: addresses are real, dereferenceable pointers). ---- */
static inline int
binder_mem_host_read(void *opaque, binder_uintptr_t addr, void *dst, size_t len)
{
    (void)opaque;
    memcpy(dst, (const void *)(uintptr_t)addr, len);
    return 0;
}

static inline int
binder_mem_host_write(void *opaque, binder_uintptr_t addr, const void *src, size_t len)
{
    (void)opaque;
    memcpy((void *)(uintptr_t)addr, src, len);
    return 0;
}

#define BINDER_MEM_HOST() \
    ((struct binder_mem){ NULL, binder_mem_host_read, binder_mem_host_write })

/* Per-context-manager threat model: one ctx per binder device path
 * (binderfs-like separation between /dev/binder, /dev/hwbinder, /dev/vndbinder)
 * is achieved by allocating one struct binder_ctx per attached path. */
struct binder_ctx {
    /* config */
    size_t max_txn_size;          /* max payload+offsets per txn (RIM: 1 MiB) */

    /* context manager */
    struct binder_proc *ctx_mgr;        /* proc that called SET_CONTEXT_MGR(_EXT) */
    struct binder_node *ctx_mgr_node;   /* synthetic node {ptr=0,cookie=0} in mgr */
    int ctx_mgr_security_ctx;           /* FLAT_BINDER_FLAG_TXN_SECURITY_CTX set */

    /* the whole engine is serialized under this lock (one binder device) */
    pthread_mutex_t lock;

    /* txn buffer allocator. The driver hands the client a
     * binder_uintptr_t (trd.data.ptr.buffer) that it must be able to
     * dereference, and later passes back to BC_FREE_BUFFER. The glue replaces
     * these for cross-process shared memory; the default is host malloc. */
    void *alloc_opaque;
    int (*alloc_buffer)(void *opaque, struct binder_proc *for_proc,
                        size_t size, void **driver_ptr,
                        binder_uintptr_t *user_ptr);
    void (*free_buffer)(void *opaque, struct binder_proc *of_proc,
                        binder_uintptr_t user_ptr);

    /* trace to stderr (0 off, 1 on) */
    int debug;

    /* buffer token allocator */
    uint64_t next_buffer_id;

    /* node allocator */
    uint64_t next_node_id;

    /* live procs (for debug) */
    struct binder_proc *procs;
};

/* ---- non-portable glue sees only these ---- */

struct binder_ctx *binder_ctx_alloc(size_t max_txn_size);
void binder_ctx_free(struct binder_ctx *ctx);

/* Open/close of /dev/binder represents a binder_proc. Returns NULL on OOM.
 * pid/uid are the QNX pid + the mapped Android uid (libbionic bridge). */
struct binder_proc *binder_proc_open(struct binder_ctx *ctx,
                                     int32_t pid, int32_t uid);
void binder_proc_close(struct binder_ctx *ctx, struct binder_proc *proc);

/* Get or create the binder_thread for this (proc, tid) pair. tid is the
 * Android process thread id (client-side thread key). */
struct binder_thread *binder_thread_get(struct binder_proc *proc, int64_t tid);

/* Core ioctl dispatch. `arg` points to the copied-in data of `cmd`
 * (for WRITE_READ: a 48-byte binder_write_read; for the void ioctls: a
 * pointer to the 8/12/24-byte struct). `mem` bridges bwr->write_buffer and
 * bwr->read_buffer. `nonblock` mirrors O_NONBLOCK on the fd.
 * Returns: 0 on success, negative errno on error.
 * For VERSION/NODE_REFS/etc the result struct is written through mem into
 * the buffer described by cmd's _IOC size (glue copies back). */
int binder_ioctl(struct binder_ctx *ctx, struct binder_proc *proc,
                 struct binder_thread *thread, unsigned int cmd,
                 const void *arg, const struct binder_mem *mem,
                 int nonblock);

#ifdef __cplusplus
}
#endif
#endif /* BINDER_CORE_H */