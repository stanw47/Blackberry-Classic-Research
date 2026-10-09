/* qnx_binder.c — QNX-side client layer for the BB10 /dev/binder driver.
 *
 * Compiled into the qnx-linked A11 libbinder (NDK clang, arm32) and used by
 * qnx_binder_redirect.h to route ioctl()/mmap() into the driver.
 *
 * Driver facts established in the player context (sessions 50/50b-50e):
 *  - BINDER_VERSION reports 7 and the A11 libbinder is built with
 *    -DBINDER_IPC_32BIT=1, so all wire structs match byte-for-byte.
 *  - The driver only knows RIM's direction-swapped SET_MAX_THREADS word
 *    (0x80046205); A11's 0x40046205 returns ENOSYS.
 *  - CFG (0xC108620C, 0x108 B, vm_size at +0x104) creates
 *    /dev/shmem/binder_<id>, maps it (mmap64 in the driver), peer-maps it into
 *    the calling process (mmap_peer) and returns the CLIENT-SIDE address of
 *    that mapping at cfg+0x100.  That address is the transaction memory
 *    (mVMStart).  mmap() on the driver fd itself is not supported.
 *  - WRITE_READ (0xC0186201, 24 B) is a straight devctl; the driver
 *    peer-maps the client buffers it needs.
 *
 * QNX devctl() returns 0 or a positive errno; bionic wants 0/-1+errno.
 */
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <stddef.h>

extern int devctl(int fd, int dcmd, void *data, size_t nbytes, int *info);
extern int *__errno(void);
extern void *mmap(void *addr, size_t len, int prot, int flags, int fd, long long off);
extern long write(int fd, const void *buf, unsigned long n);

#define SET_ERRNO(e) do { *__errno() = (e); } while (0)

/* trace helper: prints "<tag> <hex>\n" to stdout (the probe's run.log) */
static void dbg1(const char *tag, unsigned v)
{
    char b[64];
    int n = 0, i;
    while (*tag) b[n++] = *tag++;
    for (i = 0; i < 8; ++i) {
        unsigned d = (v >> ((7 - i) * 4)) & 0xf;
        b[n++] = d < 10 ? (char)('0' + d) : (char)('a' + d - 10);
    }
    b[n++] = '\n';
    write(1, b, (unsigned long)n);
}

#define BINDER_VERSION         0xC0046209u
#define BINDER_SET_MAX_THREADS 0x40046205u /* A11 word (unsupported by driver) */
#define RIM_SET_MAX_THREADS    0x80046205u /* RIM direction-swapped word */
#define BINDER_WRITE_READ      0xC0186201u
#define BINDER_WRITE_READ_LEN  24 /* sizeof(struct binder_write_read), 32-bit ABI */

#define RIM_DCMD_CFG 0xC108620C
#define BINDER_VM_SIZE ((1 * 1024 * 1024) - 4096 * 2) /* 0xfe000, matches RIM */

/* 32-bit binder_write_read (BINDER_IPC_32BIT build) */
struct bwr32 {
    uint32_t write_size, write_consumed, write_buffer;
    uint32_t read_size, read_consumed, read_buffer;
};
/* 32-bit binder_transaction_data — AOSP order vs RIM's reordered wire order
 * (verified from RIM IPCThreadState::writeTransactionData, session50i):
 *   AOSP: target, cookie, code, flags, pid, euid, data_size, offsets_size, buffer, offsets
 *   RIM:  target, cookie, code, flags, pid, euid, buffer,    offsets_size, offsets, data_size
 */
struct txn_a11 {
    uint32_t target, cookie, code, flags;
    uint32_t sender_pid, sender_euid;
    uint32_t data_size, offsets_size;
    uint32_t buffer, offsets;
};

#define BC_TRANSACTION_A11 0x40286300u
#define BC_REPLY_A11       0x40286301u
#define BR_TRANSACTION_RIM 0x40287202u
#define BR_REPLY_RIM       0x40287203u

static int      g_binder_fd = -1;  /* recorded on the first VERSION ioctl */
static unsigned g_vm_base   = 0;   /* client-side txn memory (CFG writeback) */

/* RIM's _IOC direction bits are swapped vs Linux (WRITE=2, READ=1).  The swap
 * is its own inverse, so the same function converts both ways. */
static uint32_t rim_cmd(uint32_t c)
{
    return (c & 0x3FFFFFFFu) | ((c & 0x40000000u) << 1) | ((c & 0x80000000u) >> 1);
}

/* Scratch areas inside the peer-mapped txn shm.  The driver bounds-checks the
 * bwr buffers against the region as OFFSETS (session50h), so everything the
 * driver sees must be region-relative. */
#define SHM_WSCRATCH 0x1000u
#define SHM_RSCRATCH 0x80000u
#define SHM_PAYLOAD  0x40000u
#define SHM_PAYLOAD_END 0x7F000u

static unsigned g_payload_off = SHM_PAYLOAD;

static uint32_t shm_alloc(unsigned n)
{
    unsigned off = (g_payload_off + 3u) & ~3u;
    if (off + n > SHM_PAYLOAD_END)
        return 0;
    g_payload_off = off + n;
    return off;   /* region-relative offset */
}

/* Walk a binder command stream and convert between A11 and RIM encodings:
 * to_offsets=1 (write side): A11 words -> RIM words, A11 txn layout -> RIM
 * txn layout, payload pointers -> region offsets.  to_offsets=0 (read side):
 * RIM words -> A11 words, RIM txn layout -> A11 layout, region offsets ->
 * payload pointers. */
static void xlate_stream(unsigned char *w, unsigned size, int to_offsets)
{
    unsigned off = 0;
    while (off + 4 <= size) {
        uint32_t cmd = *(uint32_t *)(w + off);
        unsigned plen = (cmd >> 16) & 0x3fffu;
        off += 4;
        if ((cmd == (to_offsets ? BC_TRANSACTION_A11 : BR_TRANSACTION_RIM) ||
             cmd == (to_offsets ? BC_REPLY_A11       : BR_REPLY_RIM))
            && off + sizeof(struct txn_a11) <= size) {
            uint32_t *t = (uint32_t *)(w + off);
            uint32_t data_size = t[6], offsets_size = t[7], buffer = t[8], offsets = t[9];
            if (to_offsets) {
                /* A11 layout -> RIM layout (pointers already region offsets) */
                t[6] = buffer;
                t[7] = offsets_size;
                t[8] = offsets;
                t[9] = data_size;
            } else {
                /* RIM layout -> A11 layout (region offsets -> pointers) */
                if (buffer)  buffer  += g_vm_base;
                if (offsets) offsets += g_vm_base;
                t[6] = data_size;
                t[7] = offsets_size;
                t[8] = buffer;
                t[9] = offsets;
            }
        }
        *(uint32_t *)(w + off - 4) = rim_cmd(cmd);
        off += plen;
    }
}

/* Walk the BC_ command stream in the write buffer, copy the transaction
 * payloads into the region, rewrite their pointers to region offsets, convert
 * the txn struct to RIM's layout and the command words to RIM's encoding. */
static void relocate_writebuf2(unsigned char *w, unsigned size, unsigned char *shm,
                               int paymode, int reorder, int synthpayload)
{
    unsigned off = 0;
    while (off + 4 <= size) {
        uint32_t cmd = *(uint32_t *)(w + off);
        unsigned plen = (cmd >> 16) & 0x3fffu;
        off += 4;
        if ((cmd == BC_TRANSACTION_A11 || cmd == BC_REPLY_A11)
            && off + sizeof(struct txn_a11) <= size) {
            uint32_t *t = (uint32_t *)(w + off);
            uint32_t data_size = t[6], offsets_size = t[7];
            uint32_t buffer = t[8], offsets = t[9];
            if (data_size && buffer) {
                uint32_t no = shm_alloc(data_size);
                if (!no) return;
                memcpy(shm + no, (void *)(unsigned long)buffer, data_size);
                buffer = paymode ? (uint32_t)(unsigned long)(shm + no) : no;
            }
            if (offsets_size && offsets) {
                uint32_t no = shm_alloc(offsets_size);
                if (!no) return;
                memcpy(shm + no, (void *)(unsigned long)offsets, offsets_size);
                offsets = paymode ? (uint32_t)(unsigned long)(shm + no) : no;
            }
            dbg1("QB tgt", t[0]);
            dbg1("QB code", t[2]);
            dbg1("QB flg", t[3]);
            dbg1("QB dsz", data_size);
            dbg1("QB osz", offsets_size);
            dbg1("QB buf", buffer);
            if (synthpayload && data_size == 0) {
                uint32_t no = shm_alloc(4);
                if (no) {
                    *(uint32_t *)(shm + no) = 0;
                    buffer = paymode ? (uint32_t)(unsigned long)(shm + no) : no;
                    data_size = 4;
                    dbg1("QB synth", no);
                }
            }
            if (reorder) {   /* A11 layout -> RIM layout */
                t[6] = buffer;
                t[7] = offsets_size;
                t[8] = offsets;
                t[9] = data_size;
            } else {
                t[6] = data_size;
                t[7] = offsets_size;
                t[8] = buffer;
                t[9] = offsets;
            }
        }
        *(uint32_t *)(w + off - 4) = rim_cmd(cmd);
        off += plen;
    }
}

static int do_cfg(int fd)
{
    uint8_t cfg[0x108];
    int info = 0, rc, i;

    if (g_vm_base)
        return 0; /* one CFG per process; the driver returns EBUSY on repeats */
    for (i = 0; i < (int)sizeof cfg; ++i) cfg[i] = 0;
    *(uint32_t *)(cfg + 0x104) = BINDER_VM_SIZE;
    rc = devctl(fd, RIM_DCMD_CFG, cfg, sizeof cfg, &info);
    if (rc) { SET_ERRNO(rc); return -1; }
    g_vm_base = *(uint32_t *)(cfg + 0x100);
    return 0;
}

int qnx_binder_ioctl(int fd, unsigned long request, void *arg)
{
    int info = 0, rc;
    dbg1("QB ioctl", (unsigned)request);
    switch (request) {
    case BINDER_VERSION:
        g_binder_fd = fd;
        rc = devctl(fd, BINDER_VERSION, arg, 4, &info);
        break;
    case BINDER_SET_MAX_THREADS:
        /* pass the u32 max-threads through with the driver's own word */
        rc = devctl(fd, RIM_SET_MAX_THREADS, arg, 4, &info);
        break;
    case BINDER_WRITE_READ: {
        struct bwr32 *b = (struct bwr32 *)arg;
        unsigned char *shm = (unsigned char *)(unsigned long)g_vm_base;
        uint32_t wb = b->write_buffer, rb = b->read_buffer;
        int vi, done = 0;

        if (!g_vm_base) { SET_ERRNO(EINVAL); return -1; }
        dbg1("QB wsz", b->write_size);
        if (b->write_size >= 4) {
            uint32_t *cw = (uint32_t *)(unsigned long)wb;
            dbg1("QB c0", cw[0]);
            if (b->write_size >= 12) dbg1("QB c1", cw[2]);
            if (b->write_size >= 16) dbg1("QB c2", cw[3]);
        }
        for (vi = 0; vi < 14 && !done; vi++) {
            int bufmode = (vi == 2 || vi == 3);      /* 0: region offsets, 1: addresses */
            int paymode = (vi == 1 || vi == 3 || vi == 7); /* payload offsets vs addresses */
            int reorder = (vi != 4);                 /* RIM txn layout vs AOSP */
            int filter  = (vi >= 6 && vi < 8);       /* drop non-transaction commands */
            int synth   = (vi >= 8 && vi < 10);      /* synthesize 4-byte payload */
            int noread  = (vi >= 10);                /* zero the read request */
            int prefix  = (vi >= 12);                /* prepend refcount op for handle 0 */
            g_payload_off = SHM_PAYLOAD;
            b->write_buffer = wb; b->read_buffer = rb;
            if (b->write_size) {
                unsigned wsize = b->write_size;
                unsigned char *dst = shm + SHM_WSCRATCH + (prefix ? 8 : 0);
                if (wsize > SHM_PAYLOAD - SHM_WSCRATCH - 0x1000 - (prefix ? 8 : 0)) { SET_ERRNO(EINVAL); return -1; }
                memcpy(dst, (void *)(unsigned long)wb, wsize);
                if (filter) {
                    /* keep only BC_TRANSACTION/BC_REPLY commands */
                    unsigned ro = 0, wo = 0;
                    while (ro + 4 <= wsize) {
                        uint32_t c = *(uint32_t *)(dst + ro);
                        unsigned pl = (c >> 16) & 0x3fffu;
                        if (c == BC_TRANSACTION_A11 || c == BC_REPLY_A11) {
                            memmove(dst + wo, dst + ro, 4 + pl);
                            wo += 4 + pl;
                        }
                        ro += 4 + pl;
                    }
                    wsize = wo;
                }
                relocate_writebuf2(dst, wsize, shm, paymode, reorder, synth);
                if (prefix) {
                    /* RIM-encoded refcount op on handle 0 (already wire form) */
                    *(uint32_t *)(shm + SHM_WSCRATCH) = (vi == 13) ? 0x80046305u : 0x80046304u;
                    *(uint32_t *)(shm + SHM_WSCRATCH + 4) = 0;
                    wsize += 8;
                }
                b->write_size = wsize;
                b->write_buffer = bufmode ? (uint32_t)(unsigned long)(shm + SHM_WSCRATCH) : SHM_WSCRATCH;
            }
            if (b->read_size)
                b->read_buffer = bufmode ? (uint32_t)(unsigned long)(shm + SHM_RSCRATCH) : SHM_RSCRATCH;
            if (noread) { b->read_size = 0; b->read_buffer = 0; }
            rc = devctl(fd, BINDER_WRITE_READ, arg, BINDER_WRITE_READ_LEN, &info);
            dbg1("QB try", (unsigned)vi);
            dbg1("QB rc ", (unsigned)rc);
            if (rc == 0) done = 1;
        }
        b->write_buffer = wb;
        if (b->read_size) {
            if (rc == 0 && b->read_consumed) {
                if (b->read_consumed > b->read_size) b->read_consumed = b->read_size;
                xlate_stream(shm + SHM_RSCRATCH, b->read_consumed, 0);
                memcpy((void *)(unsigned long)rb, shm + SHM_RSCRATCH, b->read_consumed);
            }
            b->read_buffer = rb;
        }
        if (rc == 0) {
            dbg1("QB wr wc", b->write_consumed);
            dbg1("QB wr rcc", b->read_consumed);
        }
        break;
    }
    default:
        SET_ERRNO(ENOTTY);
        return -1;
    }
    if (rc) { SET_ERRNO(rc); return -1; }
    return 0;
}

/* Intercepts ProcessState's mmap(BINDER_VM_SIZE, fd): performs the CFG
 * handshake and returns the peer-mapped txn memory the driver created for us.
 * Any other fd is passed through to the real mmap(). */
void *qnx_binder_mmap(void *addr, unsigned long len, int prot, int flags, int fd, long long off)
{
    if (fd >= 0 && fd == g_binder_fd) {
        dbg1("QB mmap fd", (unsigned)fd);
        if (do_cfg(fd)) {
            dbg1("QB cfg FAIL", 0xffffffff);
            return (void *)-1;
        }
        dbg1("QB token", g_vm_base);
        (void)addr; (void)len; (void)prot; (void)flags; (void)off;
        return (void *)(unsigned long)g_vm_base;
    }
    return mmap(addr, (size_t)len, prot, flags, fd, off);
}

/* Optional helper for board bring-up: query the driver's txn-memory blob. */
int qnx_binder_txnmem(int fd, void *buf60, int nbytes)
{
    int info = 0, rc = devctl(fd, 0xC03C620B, buf60, nbytes, &info);
    if (rc) { SET_ERRNO(rc); return -1; }
    return 0;
}
