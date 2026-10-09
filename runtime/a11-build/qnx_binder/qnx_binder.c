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

/* Walk the BC stream inside the devctl message; copy txn payloads into the
 * message after the stream, rewrite payload pointers to MESSAGE OFFSETS, and
 * swap command words to RIM's encoding.  (The driver reads client data with
 * resmgr_msgread(ctp, dst, size, offset) — everything is message-relative.) */
static void pack_writemsg(unsigned char *w, unsigned size, unsigned char *msg,
                          unsigned *payload_off)
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
                uint32_t no = *payload_off;
                memcpy(msg + no, (void *)(unsigned long)buffer, data_size);
                *payload_off = (no + data_size + 3) & ~3u;
                buffer = no;
            } else if (cmd == BC_TRANSACTION_A11 && data_size == 0) {
                /* RIM's 4.3 client always sent writeInt32(0) for the context-
                 * manager PING; the driver's size check may require >= 4. */
                uint32_t no = *payload_off;
                *(uint32_t *)(msg + no) = 0;
                *payload_off = (no + 4 + 3) & ~3u;
                buffer = no;
                data_size = 4;
            }
            if (offsets_size && offsets) {
                uint32_t no = *payload_off;
                memcpy(msg + no, (void *)(unsigned long)offsets, offsets_size);
                *payload_off = (no + offsets_size + 3) & ~3u;
                offsets = no;
            }
            /* AOSP field order is what the driver parses (verified against
             * RIM's writeTransactionData: data_size, offsets_size, buffer,
             * offsets at +0x18..+0x24) */
            t[6] = data_size;
            t[7] = offsets_size;
            t[8] = buffer;
            t[9] = offsets;
        }
        *(uint32_t *)(w + off - 4) = rim_cmd(cmd);
        off += plen;
    }
}

/* Walk the BR stream in the reply area; convert message offsets in txn fields
 * to absolute pointers into the caller's read buffer and swap words to A11. */
static void unpack_readmsg(unsigned char *w, unsigned size, unsigned char *readbase)
{
    unsigned off = 0;
    while (off + 4 <= size) {
        uint32_t cmd = *(uint32_t *)(w + off);
        unsigned plen = (cmd >> 16) & 0x3fffu;
        off += 4;
        if ((cmd == BR_TRANSACTION_RIM || cmd == BR_REPLY_RIM)
            && off + sizeof(struct txn_a11) <= size) {
            uint32_t *t = (uint32_t *)(w + off);
            if (t[8]) t[8] = (uint32_t)(unsigned long)(readbase + t[8]);
            if (t[9]) t[9] = (uint32_t)(unsigned long)(readbase + t[9]);
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
        /* One devctl message carries everything: [bwr 24B][write stream +
         * payloads][read area].  All pointers the driver sees are message
         * offsets (it uses resmgr_msgread/write with them). */
        struct bwr32 *b = (struct bwr32 *)arg;
        unsigned char *shm = (unsigned char *)(unsigned long)g_vm_base;
        unsigned char *msg = shm + SHM_WSCRATCH;
        struct bwr32 *mb = (struct bwr32 *)msg;
        uint32_t wb = b->write_buffer, rb = b->read_buffer;
        unsigned ws = b->write_size, rs = b->read_size;
        unsigned payload_off, total;

        if (!g_vm_base) { SET_ERRNO(EINVAL); return -1; }
        if (ws > 0x20000 || rs > 0x20000) { SET_ERRNO(EINVAL); return -1; }
        if (24 + ws > SHM_PAYLOAD - SHM_WSCRATCH - 0x40000) { SET_ERRNO(EINVAL); return -1; }
        if (ws) memcpy(msg + 24, (void *)(unsigned long)wb, ws);
        payload_off = 24 + ws;
        if (ws) pack_writemsg(msg + 24, ws, msg, &payload_off);
        mb->write_size = ws;
        mb->write_consumed = 0;
        mb->write_buffer = 24;
        mb->read_size = rs;
        mb->read_consumed = 0;
        mb->read_buffer = payload_off;
        total = payload_off + rs;

        rc = devctl(fd, BINDER_WRITE_READ, msg, total, &info);

        b->write_consumed = mb->write_consumed;
        b->write_buffer = wb;
        b->read_buffer = rb;
        if (rc == 0 && mb->read_consumed) {
            if (mb->read_consumed > rs) mb->read_consumed = rs;
            unpack_readmsg(msg + payload_off, mb->read_consumed,
                           (unsigned char *)(unsigned long)rb);
            memcpy((void *)(unsigned long)rb, msg + payload_off, mb->read_consumed);
            b->read_consumed = mb->read_consumed;
        } else {
            b->read_consumed = 0;
        }
        dbg1("QB wr rc", (unsigned)rc);
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
