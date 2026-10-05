/*
 * test_binder.c — host simulator for the A11 binder engine.
 *
 * Three participants share one binder context (three binder_proc's):
 *
 *   proc "smgr"   (pid 100) — the context manager (servicemanager). A server
 *                             thread loops on reads and answers requests.
 *   proc "client" (pid 42)  — sends a sync transaction carrying a Binder
 *                             object, then a one-way shutdown.
 *   proc "victim" (pid 500) — sends its own object; main then closes it so
 *                             the server must observe BR_DEAD_BINDER.
 *
 * Command streams are what libbinder actually writes/reads: plain
 * BC_TRANSACTION / BC_REPLY, 64-byte binder_transaction_data, payload
 * referenced by user pointers, and BC_REQUEST_DEATH_NOTIFICATION (handle
 * u32 + cookie u64). Payload buffers are host pointers, the analogue of a
 * kernel binder_alloc address in the client's space.
 *
 * Build/run:
 *   gcc -O1 -g -Wall -Iinclude -pthread \
 *       src/binder_core.c tests/test_binder.c -o build/test_binder
 *   ./build/test_binder
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <errno.h>

#include "binder_core.h"

/* ---- tiny test harness ---- */
static int g_pass, g_fail;
#define CHECK(cond, ...) do {                                       \
        if (cond) { g_pass++; printf(__VA_ARGS__); printf("  [PASS]\n"); }  \
        else      { g_fail++; printf(__VA_ARGS__); printf("  [FAIL]\n"); }  \
    } while (0)

/* ---- byte stream helpers ---- */
static uint32_t rd32(const uint8_t *p) { uint32_t v; memcpy(&v, p, 4); return v; }
static uint64_t rd64(const uint8_t *p) { uint64_t v; memcpy(&v, p, 8); return v; }

static void w32(uint8_t *o, size_t *p, uint32_t v) { memcpy(o + *p, &v, 4); *p += 4; }
static void w64(uint8_t *o, size_t *p, uint64_t v) { memcpy(o + *p, &v, 8); *p += 8; }

#define MAX_OUT 512
#define MAX_IN  1024

struct mst {                    /* state shared with the server thread */
    struct binder_ctx *ctx;
    struct binder_proc *smgr;
    struct binder_thread *smgr_thr;
    int server_handle;          /* handle server holds for client's object */
    int server_handle2;         /* handle server holds for victim's object */
    volatile int death_seen;
    volatile int server_done;
    int failures;               /* server-side assertion failures */
};

static int
talk(struct binder_ctx *ctx, struct binder_proc *p, struct binder_thread *thr,
     const uint8_t *out, size_t outsz, uint8_t *in, size_t insz,
     size_t *inused)
{
    struct binder_write_read bwr;
    memset(&bwr, 0, sizeof(bwr));
    bwr.write_size = outsz;
    bwr.write_buffer = (binder_uintptr_t)out;
    bwr.read_size = insz;
    bwr.read_buffer = (binder_uintptr_t)in;

    const struct binder_mem host = BINDER_MEM_HOST();
    int r = binder_ioctl(ctx, p, thr, BINDER_WRITE_READ, &bwr, &host, 0);
    if (inused) *inused = bwr.read_consumed;
    return r;
}

static int
drv_ioctl(struct binder_ctx *ctx, struct binder_proc *p,
          struct binder_thread *thr, unsigned int cmd, void *arg)
{
    const struct binder_mem host = BINDER_MEM_HOST();
    return binder_ioctl(ctx, p, thr, cmd, arg, &host, 0);
}

/* ---- read-buffer parser ---- */
struct br_event {
    uint32_t cmd;
    uint32_t code;
    uint32_t flags;
    uint64_t cookie;
    void *buffer;               /* tr.data.ptr.buffer (host pointer) */
    size_t data_size;
    size_t offsets_size;
    int is_reply;
};
typedef void (*br_cb)(struct mst *t, const struct br_event *ev, void *ud);

static void
process_read(struct mst *t, const uint8_t *in, size_t used, br_cb cb, void *ud)
{
    size_t off = 0;
    while (off + 4 <= used) {
        uint32_t cmd = rd32(in + off);
        off += 4;
        if (cmd == BR_NOOP || cmd == BR_SPAWN_LOOPER ||
            cmd == BR_TRANSACTION_COMPLETE || cmd == BR_FINISHED ||
            cmd == BR_OK)
            continue;
        if (cmd == BR_TRANSACTION || cmd == BR_REPLY ||
            cmd == BR_TRANSACTION_SEC_CTX) {
            struct binder_transaction_data tr;
            if (off + sizeof(tr) > used) break;
            memcpy(&tr, in + off, sizeof(tr));
            off += sizeof(tr);
            struct br_event ev;
            memset(&ev, 0, sizeof(ev));
            ev.cmd = cmd;
            ev.code = tr.code;
            ev.flags = tr.flags;
            ev.buffer = (void *)(uintptr_t)tr.data.ptr.buffer;
            ev.data_size = tr.data_size;
            ev.offsets_size = tr.offsets_size;
            ev.is_reply = (cmd == BR_REPLY);
            if (cb) cb(t, &ev, ud);
            continue;
        }
        if (cmd == BR_DEAD_BINDER ||
            cmd == BR_CLEAR_DEATH_NOTIFICATION_DONE) {
            if (off + 8 > used) break;
            uint64_t cookie = rd64(in + off);
            off += 8;
            struct br_event ev;
            memset(&ev, 0, sizeof(ev));
            ev.cmd = cmd;
            ev.cookie = cookie;
            if (cb) cb(t, &ev, ud);
            continue;
        }
        break;   /* unknown command: stop mis-parsing */
    }
}

/* ---- server side ---- */
#define C_SETUP       0x10
#define C_DEATHSETUP  0x20
#define C_SHUTDOWN    0x30

static void
server_handler(struct mst *t, const struct br_event *ev, void *ud)
{
    (void)ud;

    if (ev->cmd == BR_DEAD_BINDER) {
        if (ev->cookie != 0xDEADC0DEULL)
            t->failures++;
        t->death_seen = 1;
        return;
    }
    if (ev->is_reply)
        return;

    uint8_t out[MAX_OUT];
    size_t p = 0;
    int reply_action = 0;
    int do_death = 0;

    if (ev->code == C_SETUP || ev->code == C_DEATHSETUP) {
        /* the object at data[0] must have been rewritten to a HANDLE */
        struct flat_binder_object *obj = (struct flat_binder_object *)ev->buffer;
        if (ev->data_size < sizeof(*obj) || obj->hdr.type != BINDER_TYPE_HANDLE) {
            t->failures++;
            fprintf(stderr, "server: bad object (type=%u size=%zu)\n",
                    obj->hdr.type, ev->data_size);
        } else if (ev->code == C_SETUP) {
            t->server_handle = obj->handle;
            if (obj->handle != 1 || obj->cookie != 0)
                t->failures++;
        } else {
            t->server_handle2 = obj->handle;
            if (obj->handle != 2)
                t->failures++;
            do_death = 1;
        }
        reply_action = 1;
    } else if (ev->code == C_SHUTDOWN) {
        t->server_done = 1;
        return;
    }

    if (reply_action) {
        static const char ack[] = "ack42";
        struct binder_transaction_data tr;
        memset(&tr, 0, sizeof(tr));
        tr.code = ev->code;
        tr.flags = TF_ACCEPT_FDS;
        tr.data_size = sizeof(ack) - 1;
        tr.data.ptr.buffer = (binder_uintptr_t)ack;

        w32(out, &p, BC_REPLY);
        memcpy(out + p, &tr, sizeof(tr));
        p += sizeof(tr);

        if (do_death) {
            w32(out, &p, BC_REQUEST_DEATH_NOTIFICATION);
            w32(out, &p, (uint32_t)t->server_handle2);
            w64(out, &p, 0xDEADC0DEULL);
        }
    }

    /* write the reply only; the read happens on the next loop spin */
    int r = talk(t->ctx, t->smgr, t->smgr_thr, out, p, NULL, 0, NULL);
    if (r < 0) t->failures++;
}

static void *
smgr_thread(void *arg)
{
    struct mst *t = arg;

    /* register the main looper (write-only; does not consume work) */
    uint8_t out[MAX_OUT];
    size_t p = 0;
    w32(out, &p, BC_ENTER_LOOPER);
    int rr = talk(t->ctx, t->smgr, t->smgr_thr, out, p, NULL, 0, NULL);
    if (rr < 0) t->failures++;

    while (!t->server_done) {
        uint8_t in[MAX_IN];
        memset(in, 0, sizeof(in));
        size_t used = 0;
        int r = talk(t->ctx, t->smgr, t->smgr_thr, NULL, 0,
                     in, sizeof(in), &used);
        if (r < 0) { t->failures++; break; }
        process_read(t, in, used, server_handler, NULL);
    }
    return NULL;
}

/* ---- main (client + orchestrator) ---- */

static size_t
build_transaction(uint8_t *out, uint32_t code, uint32_t flags,
                  uint32_t handle, const void *data, size_t data_size,
                  const uint64_t *offs, size_t offsets_size)
{
    struct binder_transaction_data tr;
    memset(&tr, 0, sizeof(tr));
    tr.target.handle = handle;
    tr.code = code;
    tr.flags = flags;
    tr.data_size = data_size;
    tr.offsets_size = offsets_size;
    tr.data.ptr.buffer = (binder_uintptr_t)data;
    tr.data.ptr.offsets = (binder_uintptr_t)offs;

    size_t p = 0;
    w32(out, &p, BC_TRANSACTION);
    memcpy(out + p, &tr, sizeof(tr));
    p += sizeof(tr);
    return p;
}

static void
open_proc(struct binder_ctx *ctx, int32_t pid, int32_t uid,
          struct binder_proc **pp, struct binder_thread **tp, int64_t tid)
{
    struct binder_proc *proc = binder_proc_open(ctx, pid, uid);
    CHECK(proc != NULL, "open proc pid=%d", pid);
    *pp = proc;
    *tp = binder_thread_get(proc, tid);
    CHECK(*tp != NULL, "thread get pid=%d tid=%lld", pid, (long long)tid);

    struct binder_version v;
    int r = drv_ioctl(ctx, proc, *tp, BINDER_VERSION, &v);
    CHECK(r == 0 && v.protocol_version == 8, "version==8 (pid=%d)", pid);

    int32_t mthr = 4;
    r = drv_ioctl(ctx, proc, *tp, BINDER_SET_MAX_THREADS, &mthr);
    CHECK(r == 0, "set_max_threads pid=%d", pid);
}

/* Send a sync txn + object, wait for reply, verify ack, free the reply
 * buffer. Returns 0 on success (all sub-checks OK). */
static int
sync_obj_roundtrip(struct binder_ctx *ctx, struct binder_proc *p,
                   struct binder_thread *thr, uint32_t code,
                   uintptr_t obj_ptr, uintptr_t obj_cookie)
{
    struct payload {
        struct flat_binder_object obj;
        char s[16];
    } pld;
    memset(&pld, 0, sizeof(pld));
    pld.obj.hdr.type = BINDER_TYPE_BINDER;
    pld.obj.flags = FLAT_BINDER_FLAG_ACCEPTS_FDS;
    pld.obj.binder = obj_ptr;
    pld.obj.cookie = obj_cookie;
    strcpy(pld.s, "hello");
    uint64_t offs[1] = { 0 };

    uint8_t out[MAX_OUT];
    size_t osz = build_transaction(out, code, TF_ACCEPT_FDS, 0,
                                   &pld, sizeof(pld), offs, sizeof(offs));
    uint8_t in[MAX_IN];
    size_t used = 0;
    int r = talk(ctx, p, thr, out, osz, in, sizeof(in), &used);
    if (r < 0) return -1;

    int got_complete = 0;
    int ok = 0;
    size_t off = 0;
    while (off + 4 <= used) {
        uint32_t cmd = rd32(in + off);
        off += 4;
        if (cmd == BR_TRANSACTION_COMPLETE) { got_complete = 1; continue; }
        if (cmd == BR_NOOP || cmd == BR_SPAWN_LOOPER) continue;
        if (cmd == BR_REPLY) {
            struct binder_transaction_data tr;
            if (off + sizeof(tr) > used) break;
            memcpy(&tr, in + off, sizeof(tr));
            off += sizeof(tr);
            ok = (tr.data_size == 5) &&
                 memcmp((const void *)(uintptr_t)tr.data.ptr.buffer,
                        "ack42", 5) == 0;
            /* release the reply payload as libbinder would */
            uint8_t fb[MAX_OUT];
            size_t fp = 0;
            w32(fb, &fp, BC_FREE_BUFFER);
            memcpy(fb + fp, &tr.data.ptr.buffer, 8);
            fp += 8;
            (void)talk(ctx, p, thr, fb, fp, NULL, 0, NULL);
            break;
        }
    }
    return (got_complete && ok) ? 0 : -2;
}

int
main(void)
{
    struct binder_ctx *ctx = binder_ctx_alloc(1u << 20);
    CHECK(ctx != 0, "ctx alloc");
    ctx->debug = 1;

    struct mst T;
    memset(&T, 0, sizeof(T));
    T.ctx = ctx;

    /* --- open servicemanager, make it the context manager --- */
    open_proc(ctx, 100, 1000, &T.smgr, &T.smgr_thr, 1);
    struct flat_binder_object fbo;
    memset(&fbo, 0, sizeof(fbo));
    int r = drv_ioctl(ctx, T.smgr, T.smgr_thr, BINDER_SET_CONTEXT_MGR_EXT, &fbo);
    CHECK(r == 0, "servicemanager becomes context manager");

    /* --- start the server thread --- */
    pthread_t srv;
    pthread_create(&srv, NULL, smgr_thread, &T);
    usleep(20000);

    /* --- open client + register looper (write-only, like a pool thread
     * registering without blocking the orchestrator) --- */
    struct binder_proc *client;
    struct binder_thread *cthr;
    open_proc(ctx, 42, 1000, &client, &cthr, 1);
    {
        uint8_t out[MAX_OUT];
        size_t p = 0;
        w32(out, &p, BC_ENTER_LOOPER);
        int rr = talk(ctx, client, cthr, out, p, NULL, 0, NULL);
        CHECK(rr == 0, "client enters looper");
    }

    /* --- client: sync txn + object, expect ack --- */
    CHECK(sync_obj_roundtrip(ctx, client, cthr, C_SETUP,
                             0x12340000ULL, 0x56780000ULL) == 0,
          "client sync roundtrip (object rewritten, ack verified)");
    CHECK(T.server_handle == 1, "server holds handle 1 for client obj");

    /* --- node info for the server's ref --- */
    {
        struct binder_node_info_for_ref info;
        memset(&info, 0, sizeof(info));
        info.handle = 1;
        r = drv_ioctl(ctx, T.smgr, T.smgr_thr, BINDER_GET_NODE_INFO_FOR_REF,
                      &info);
        CHECK(r == 0 && info.strong_count == 1,
              "GET_NODE_INFO_FOR_REF strong_count==1");
    }

    /* --- victim: sync txn + object -> server requests death on it --- */
    struct binder_proc *victim;
    struct binder_thread *vthr;
    open_proc(ctx, 500, 1000, &victim, &vthr, 5);
    CHECK(sync_obj_roundtrip(ctx, victim, vthr, C_DEATHSETUP,
                             0x55440000ULL, 0x99880000ULL) == 0,
          "victim sync roundtrip");
    CHECK(T.server_handle2 == 2, "server holds handle 2 for victim obj");

    /* --- close the victim: server must get BR_DEAD_BINDER --- */
    binder_proc_close(ctx, victim);
    for (int i = 0; i < 10000 && !T.death_seen; i++)
        usleep(100);
    CHECK(T.death_seen, "server received BR_DEAD_BINDER after victim close");
    CHECK(T.failures == 0, "no server-side assertion failures");

    /* --- one-way shutdown from the client (write-only) --- */
    {
        uint8_t out[MAX_OUT];
        size_t osz = build_transaction(out, C_SHUTDOWN, TF_ONE_WAY |
                                       TF_ACCEPT_FDS, 0, NULL, 0, NULL, 0);
        (void)talk(ctx, client, cthr, out, osz, NULL, 0, NULL);
    }
    pthread_join(srv, NULL);
    CHECK(T.server_done, "server thread exited after shutdown");

    /* --- teardown; everything must free cleanly --- */
    binder_proc_close(ctx, client);
    binder_ctx_free(ctx);

    printf("\n=== %d pass, %d fail ===\n", g_pass, g_fail);
    return g_fail == 0 ? 0 : 1;
}