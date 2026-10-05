/*
 * test_glue.c — host validation for the ioctl glue (binder_handlers.c).
 *
 * Emulates the QNX resmgr transport's staging loop:
 *   - packs args into a contiguous buffer according to _IOC_SIZE(cmd),
 *   - funnels through binder_handle_ioctl(),
 *   - asserts exact copy-back byte counts per the kernel ioctl rule
 *     (binder_ioctl_reply_size: copy if _IOC_DIR & _IOC_READ, else 0),
 *   - drives a two-process ping-pong transaction end-to-end to ensure
 *     that WRITE_READ payload copy-back and blocking round-trips work
 *     identically through the glue as they did through binder_core.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <errno.h>
#include <pthread.h>
#include <unistd.h>
#include <assert.h>

#include "binder_a11.h"
#include "binder_core.h"
#include "binder_handlers.h"

#define CHECK(cond) do { \
    if (!(cond)) { \
        fprintf(stderr, "FAIL: %s:%d: %s\n", __FILE__, __LINE__, #cond); \
        exit(1); \
    } \
} while (0)

static int g_pass = 0;
#define PASS(msg) do { g_pass++; printf("  [%2d] %s\n", g_pass, msg); } while (0)

/* Emulated transport devctl dispatch (mirrors src/binder.c devctl loop) */
static int
transport_devctl_emulated(struct binder_ctx *ctx, struct binder_proc *proc,
                          struct binder_thread *thr, unsigned int cmd,
                          void *data, size_t data_len, size_t *out_copied)
{
    size_t req = _IOC_SIZE(cmd);
    uint8_t stage[256];

    if (req > sizeof(stage)) return -EINVAL;
    if (data_len < req) return -EINVAL;

    if (req > 0)
        memcpy(stage, data, req);
    else
        memset(stage, 0, sizeof(stage));

    struct binder_call call = {
        .ctx = ctx,
        .proc = proc,
        .thread = thr,
        .mem = BINDER_MEM_HOST(),
        .nonblock = 0,
    };

    int ret = binder_handle_ioctl(&call, cmd, stage, req);
    if (ret < 0) return ret;

    if (ret > 0)
        memcpy(data, stage, (size_t)ret);

    if (out_copied)
        *out_copied = (size_t)ret;
    return 0;
}

/* ------------------------------------------------------------------ */
/* 1. Reply size table check                                          */
/* ------------------------------------------------------------------ */
static void
test_reply_size_table(void)
{
    printf("1. Verifying ioctl copy-back byte rules...\n");

    /* Commands with READ bit set MUST copy back _IOC_SIZE bytes */
    CHECK(binder_ioctl_reply_size(BINDER_WRITE_READ) == 48);
    CHECK(binder_ioctl_reply_size(BINDER_VERSION) == 4);
    CHECK(binder_ioctl_reply_size(BINDER_GET_NODE_INFO_FOR_REF) == 24);
    CHECK(binder_ioctl_reply_size(BINDER_GET_NODE_DEBUG_INFO) == 24);
    CHECK(binder_ioctl_reply_size(BINDER_GET_FROZEN_INFO) == 12);

    /* Pure write or void commands MUST copy back 0 bytes */
    CHECK(binder_ioctl_reply_size(BINDER_SET_MAX_THREADS) == 0);
    CHECK(binder_ioctl_reply_size(BINDER_SET_CONTEXT_MGR) == 0);
    CHECK(binder_ioctl_reply_size(BINDER_SET_CONTEXT_MGR_EXT) == 0);
    CHECK(binder_ioctl_reply_size(BINDER_FREEZE) == 0);
    CHECK(binder_ioctl_reply_size(BINDER_ENABLE_ONEWAY_SPAM_DETECTION) == 0);
    CHECK(binder_ioctl_reply_size(BINDER_THREAD_EXIT) == 0);

    PASS("reply-size table matches A11 _IOC definitions");
}

/* ------------------------------------------------------------------ */
/* 2. Control ioctls through transport staging                        */
/* ------------------------------------------------------------------ */
static void
test_control_ioctls(void)
{
    printf("2. Testing control ioctls through transport devctl...\n");

    struct binder_ctx *ctx = binder_ctx_alloc(1024 * 1024);
    CHECK(ctx != NULL);
    struct binder_proc *proc = binder_proc_open(ctx, 1001, 1000);
    CHECK(proc != NULL);
    struct binder_thread *thr = binder_thread_get(proc, 1);
    CHECK(thr != NULL);

    size_t copied = 0;

    /* VERSION: in=4, out=4, returns proto 8 */
    struct binder_version ver;
    memset(&ver, 0, sizeof(ver));
    int rc = transport_devctl_emulated(ctx, proc, thr, BINDER_VERSION,
                                       &ver, sizeof(ver), &copied);
    CHECK(rc == 0);
    CHECK(copied == 4);
    CHECK(ver.protocol_version == BINDER_CURRENT_PROTOCOL_VERSION);
    CHECK(ver.protocol_version == 8);
    PASS("BINDER_VERSION returns proto 8 with 4 bytes copied");

    /* SET_MAX_THREADS: in=8, out=0 */
    uint64_t max_threads = 12;
    rc = transport_devctl_emulated(ctx, proc, thr, BINDER_SET_MAX_THREADS,
                                   &max_threads, sizeof(max_threads), &copied);
    CHECK(rc == 0);
    CHECK(copied == 0);
    PASS("BINDER_SET_MAX_THREADS succeeds with 0 bytes copied");

    /* SET_CONTEXT_MGR: in=4, out=0 */
    int32_t dummy = 0;
    rc = transport_devctl_emulated(ctx, proc, thr, BINDER_SET_CONTEXT_MGR,
                                   &dummy, sizeof(dummy), &copied);
    CHECK(rc == 0);
    CHECK(copied == 0);
    PASS("BINDER_SET_CONTEXT_MGR sets context manager with 0 bytes copied");

    /* Buffer undersize rejected */
    rc = transport_devctl_emulated(ctx, proc, thr, BINDER_VERSION,
                                   &ver, 2 /* too small */, &copied);
    CHECK(rc == -EINVAL);
    PASS("staged buffer smaller than _IOC_SIZE rejected with -EINVAL");

    binder_proc_close(ctx, proc);
    binder_ctx_free(ctx);
}

/* ------------------------------------------------------------------ */
/* 3. Cross-proc WRITE_READ through glue (sync call + reply)           */
/* ------------------------------------------------------------------ */
struct server_ctx {
    struct binder_ctx    *ctx;
    struct binder_proc   *proc;
    struct binder_thread *thr;
    pthread_t             tid;
    volatile bool         ready;
    volatile bool         done;
};

static void *
server_worker(void *arg)
{
    struct server_ctx *sc = (struct server_ctx *)arg;

    /* 1. Register as looper via write-only WRITE_READ */
    uint32_t enter_cmd = BC_ENTER_LOOPER;
    struct binder_write_read bwr;
    memset(&bwr, 0, sizeof(bwr));
    bwr.write_size = sizeof(enter_cmd);
    bwr.write_buffer = (binder_uintptr_t)(uintptr_t)&enter_cmd;

    size_t copied = 0;
    int rc = transport_devctl_emulated(sc->ctx, sc->proc, sc->thr,
                                       BINDER_WRITE_READ, &bwr, sizeof(bwr),
                                       &copied);
    CHECK(rc == 0);
    CHECK(copied == 48);
    CHECK(bwr.write_consumed == sizeof(enter_cmd));

    sc->ready = true;

    /* 2. Wait for incoming transaction (blocking read) */
    uint8_t rbuf[256];
    memset(&bwr, 0, sizeof(bwr));
    bwr.read_size = sizeof(rbuf);
    bwr.read_buffer = (binder_uintptr_t)(uintptr_t)rbuf;

    rc = transport_devctl_emulated(sc->ctx, sc->proc, sc->thr,
                                   BINDER_WRITE_READ, &bwr, sizeof(bwr),
                                   &copied);
    CHECK(rc == 0);
    CHECK(copied == 48);
    CHECK(bwr.read_consumed > 0);

    /* Parse incoming commands */
    uint8_t *p = rbuf;
    uint8_t *end = rbuf + bwr.read_consumed;
    bool got_txn = false;
    struct binder_transaction_data tr;

    while (p < end) {
        uint32_t cmd;
        memcpy(&cmd, p, 4);
        p += 4;
        if (cmd == BR_NOOP || cmd == BR_SPAWN_LOOPER) continue;
        if (cmd == BR_TRANSACTION) {
            memcpy(&tr, p, sizeof(tr));
            p += sizeof(tr);
            got_txn = true;
            break;
        }
    }
    CHECK(got_txn);
    CHECK(tr.code == 0x1234);

    /* 3. Send BC_REPLY back to client (write-only) */
    uint32_t reply_payload = 0xbeefcafe;
    struct binder_transaction_data rep;
    memset(&rep, 0, sizeof(rep));
    rep.target.handle = 0;
    rep.cookie = 0;
    rep.code = 0;
    rep.data_size = sizeof(reply_payload);
    rep.data.ptr.buffer = (binder_uintptr_t)(uintptr_t)&reply_payload;

    uint8_t wbuf[128];
    uint32_t bc_reply = BC_REPLY;
    memcpy(wbuf, &bc_reply, 4);
    memcpy(wbuf + 4, &rep, sizeof(rep));

    memset(&bwr, 0, sizeof(bwr));
    bwr.write_size = 4 + sizeof(rep);
    bwr.write_buffer = (binder_uintptr_t)(uintptr_t)wbuf;

    rc = transport_devctl_emulated(sc->ctx, sc->proc, sc->thr,
                                   BINDER_WRITE_READ, &bwr, sizeof(bwr),
                                   &copied);
    CHECK(rc == 0);
    CHECK(copied == 48);
    CHECK(bwr.write_consumed == 4 + sizeof(rep));

    sc->done = true;
    return NULL;
}

static void
test_cross_proc_roundtrip(void)
{
    printf("3. Testing full cross-proc transaction roundtrip through glue...\n");

    struct binder_ctx *ctx = binder_ctx_alloc(1024 * 1024);
    CHECK(ctx != NULL);

    /* Server setup */
    struct binder_proc *srv_proc = binder_proc_open(ctx, 2000, 1000);
    CHECK(srv_proc != NULL);
    struct binder_thread *srv_thr = binder_thread_get(srv_proc, 1);
    CHECK(srv_thr != NULL);

    /* Make server context manager via devctl */
    int32_t dummy = 0;
    size_t copied = 0;
    int rc = transport_devctl_emulated(ctx, srv_proc, srv_thr,
                                       BINDER_SET_CONTEXT_MGR, &dummy,
                                       sizeof(dummy), &copied);
    CHECK(rc == 0);

    /* Spawn server looper thread */
    struct server_ctx sc = {
        .ctx = ctx,
        .proc = srv_proc,
        .thr = srv_thr,
        .ready = false,
        .done = false,
    };
    pthread_create(&sc.tid, NULL, server_worker, &sc);

    while (!sc.ready)
        usleep(1000);

    /* Client setup */
    struct binder_proc *cli_proc = binder_proc_open(ctx, 3000, 2000);
    CHECK(cli_proc != NULL);
    struct binder_thread *cli_thr = binder_thread_get(cli_proc, 1);
    CHECK(cli_thr != NULL);

    /* Client looper registration */
    uint32_t enter_cmd = BC_ENTER_LOOPER;
    struct binder_write_read bwr;
    memset(&bwr, 0, sizeof(bwr));
    bwr.write_size = sizeof(enter_cmd);
    bwr.write_buffer = (binder_uintptr_t)(uintptr_t)&enter_cmd;
    rc = transport_devctl_emulated(ctx, cli_proc, cli_thr,
                                   BINDER_WRITE_READ, &bwr, sizeof(bwr),
                                   &copied);
    CHECK(rc == 0);

    /* Client sends sync call to context manager (handle 0) and waits for reply */
    uint32_t client_req = 0x11223344;
    struct binder_transaction_data tr;
    memset(&tr, 0, sizeof(tr));
    tr.target.handle = 0;   /* context manager */
    tr.code = 0x1234;
    tr.data_size = sizeof(client_req);
    tr.data.ptr.buffer = (binder_uintptr_t)(uintptr_t)&client_req;

    uint8_t wbuf[128];
    uint32_t bc_txn = BC_TRANSACTION;
    memcpy(wbuf, &bc_txn, 4);
    memcpy(wbuf + 4, &tr, sizeof(tr));

    uint8_t rbuf[256];
    memset(&bwr, 0, sizeof(bwr));
    bwr.write_size = 4 + sizeof(tr);
    bwr.write_buffer = (binder_uintptr_t)(uintptr_t)wbuf;
    bwr.read_size = sizeof(rbuf);
    bwr.read_buffer = (binder_uintptr_t)(uintptr_t)rbuf;

    /* This call blocks inside binder_handle_ioctl until server replies */
    rc = transport_devctl_emulated(ctx, cli_proc, cli_thr,
                                   BINDER_WRITE_READ, &bwr, sizeof(bwr),
                                   &copied);
    CHECK(rc == 0);
    CHECK(copied == 48);
    CHECK(bwr.write_consumed == 4 + sizeof(tr));
    CHECK(bwr.read_consumed > 0);

    /* Verify we received BR_REPLY */
    uint8_t *p = rbuf;
    uint8_t *end = rbuf + bwr.read_consumed;
    bool got_reply = false;
    struct binder_transaction_data rep;

    while (p < end) {
        uint32_t cmd;
        memcpy(&cmd, p, 4);
        p += 4;
        if (cmd == BR_NOOP || cmd == BR_TRANSACTION_COMPLETE) continue;
        if (cmd == BR_REPLY) {
            memcpy(&rep, p, sizeof(rep));
            p += sizeof(rep);
            got_reply = true;
            break;
        }
    }
    CHECK(got_reply);
    CHECK(rep.data_size == 4);

    uint32_t val;
    memcpy(&val, (const void *)(uintptr_t)rep.data.ptr.buffer, 4);
    CHECK(val == 0xbeefcafe);

    /* Free reply buffer */
    uint8_t free_buf[16];
    uint32_t bc_free = BC_FREE_BUFFER;
    memcpy(free_buf, &bc_free, 4);
    memcpy(free_buf + 4, &rep.data.ptr.buffer, 8);
    memset(&bwr, 0, sizeof(bwr));
    bwr.write_size = 12;
    bwr.write_buffer = (binder_uintptr_t)(uintptr_t)free_buf;
    rc = transport_devctl_emulated(ctx, cli_proc, cli_thr,
                                   BINDER_WRITE_READ, &bwr, sizeof(bwr),
                                   &copied);
    CHECK(rc == 0);

    pthread_join(sc.tid, NULL);
    CHECK(sc.done);

    PASS("cross-process sync txn + reply through glue verified (48B copy-back)");

    binder_proc_close(ctx, cli_proc);
    binder_proc_close(ctx, srv_proc);
    binder_ctx_free(ctx);
}

int
main(void)
{
    printf("=== Running test_glue (ioctl glue & staging validation) ===\n");
    test_reply_size_table();
    test_control_ioctls();
    test_cross_proc_roundtrip();
    printf("=== All glue tests passed (%d checks) ===\n", g_pass);
    return 0;
}