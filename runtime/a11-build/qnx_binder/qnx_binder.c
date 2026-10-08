/* qnx_binder.c — QNX-side client layer for the BB10 /dev/binder driver.
 *
 * Compiled into the qnx-linked A11 libbinder (NDK clang, arm32).  Implements
 * qnx_binder_ioctl() used by qnx_binder_redirect.h:
 *   A11 BINDER_VERSION   (0xC0046209) -> devctl 0xC0046209 (4B)
 *   A11 SET_MAX_THREADS  (0x40046205) -> devctl 0xC108620C (CFG, 0xfe000)
 *   A11 BINDER_WRITE_READ(0xC0306201) -> translate + devctl 0xC0186201 (24B)
 *   anything else -> ENOTTY
 *
 * QNX devctl() returns 0 or a positive errno; bionic wants 0/-1+errno.
 */
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <stddef.h>
#include "binder_compat.h"

extern int devctl(int fd, int dcmd, void *data, size_t nbytes, int *info);
extern int *__errno(void);
#define SET_ERRNO(e) do { *__errno() = (e); } while (0)

/* A11 request words */
#define A11_BINDER_VERSION        0xC0046209u
#define A11_BINDER_SET_MAX_THREADS 0x40046205u
#define A11_BINDER_WRITE_READ     0xC0306201u

/* RIM driver dcmds */
#define RIM_DCMD_VERSION 0xC0046209
#define RIM_DCMD_CFG     0xC108620C
#define RIM_DCMD_TXNMEM  0xC03C620B
#define RIM_DCMD_WR      0xC0186201

#define BINDER_VM_SIZE ((1 * 1024 * 1024) - 4096 * 2) /* 0xfe000, matches RIM */

/* Identity mapping: our process is 32-bit, so the upper halves of the A11
 * 64-bit pointer fields are always zero. */
static uint32_t cb_in(uint64_t v) { return (uint32_t)v; }
static uint64_t cb_out(uint32_t v) { return (uint64_t)v; }
static xlate_ctx_t xctx = { cb_in, cb_out };

/* NOTE: single-threaded bring-up buffer set.  libbinder is multi-threaded once
 * the thread pool runs; replace with per-thread arenas before heavy use. */
static uint8_t  g_wbuf32[65536];
static uint8_t  g_rbuf64[131072];

static int do_version(int fd, void *arg)
{
    int info = 0;
    int rc = devctl(fd, RIM_DCMD_VERSION, arg, 4, &info);
    if (rc) { SET_ERRNO(rc); return -1; }
    return 0;
}

static int do_cfg(int fd, void *arg)
{
    uint8_t cfg[0x108];
    int info = 0, rc, i;
    (void)arg;
    for (i = 0; i < (int)sizeof cfg; ++i) cfg[i] = 0;
    *(uint32_t *)(cfg + 0x104) = BINDER_VM_SIZE;
    rc = devctl(fd, RIM_DCMD_CFG, cfg, sizeof cfg, &info);
    if (rc) { SET_ERRNO(rc); return -1; }
    return 0;
}

static int do_write_read(int fd, bwr64_t *b64)
{
    bwr32_t b32;
    int info = 0, rc;
    long wn;

    if (binder_bwr64_to_32(b64, &b32, &xctx)) { SET_ERRNO(EINVAL); return -1; }

    if (b64->write_size) {
        wn = binder_writebuf64_to_32((const void *)(uintptr_t)b64->write_buffer,
                                     (size_t)b64->write_size,
                                     g_wbuf32, sizeof g_wbuf32, &xctx);
        if (wn < 0) { SET_ERRNO(EINVAL); return -1; }
        b32.write_size = (uint32_t)wn;
        b32.write_buffer = (uint32_t)(uintptr_t)g_wbuf32;
    } else {
        b32.write_size = 0;
        b32.write_buffer = 0;
    }
    /* read buffer: let the driver fill the caller's buffer (32-bit address),
     * then translate the BR_ stream back for A11 libbinder. */
    b32.read_buffer = (uint32_t)b64->read_buffer;
    b32.read_size = (uint32_t)b64->read_size;

    rc = devctl(fd, RIM_DCMD_WR, &b32, sizeof b32, &info);
    if (rc) { SET_ERRNO(rc); return -1; }

    b64->write_consumed = b32.write_consumed; /* best-effort */

    if (b32.read_consumed) {
        long rn = binder_readbuf32_to_64((const void *)(uintptr_t)b64->read_buffer,
                                         b32.read_consumed,
                                         g_rbuf64, sizeof g_rbuf64, &xctx);
        if (rn < 0) { SET_ERRNO(EINVAL); return -1; }
        memcpy((void *)(uintptr_t)b64->read_buffer, g_rbuf64, (size_t)rn);
        b64->read_consumed = (uint64_t)rn;
    } else {
        b64->read_consumed = 0;
    }
    return 0;
}

int qnx_binder_ioctl(int fd, unsigned long request, void *arg)
{
    switch (request) {
    case A11_BINDER_VERSION:
        return do_version(fd, arg);
    case A11_BINDER_SET_MAX_THREADS:
        return do_cfg(fd, arg);
    case A11_BINDER_WRITE_READ:
        return do_write_read(fd, (bwr64_t *)arg);
    default:
        SET_ERRNO(ENOTTY);
        return -1;
    }
}

/* Optional helper for board bring-up: query the driver's txn-memory blob. */
int qnx_binder_txnmem(int fd, void *buf60, int nbytes)
{
    int info = 0, rc = devctl(fd, RIM_DCMD_TXNMEM, buf60, nbytes, &info);
    if (rc) { SET_ERRNO(rc); return -1; }
    return 0;
}
