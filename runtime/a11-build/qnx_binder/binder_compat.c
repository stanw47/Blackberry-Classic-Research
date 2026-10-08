/* binder_compat.c — see binder_compat.h. Host-testable. */
#include "binder_compat.h"
#include <string.h>

#define ALIGN4(x) (((x) + 3u) & ~3u)
#define _IOC(dir, type, nr, size) \
    (((dir) << 30) | (((size) & 0x3fff) << 16) | (((type) & 0xff) << 8) | ((nr) & 0xff))
#define _IOW(t, n, s) _IOC(1, t, n, sizeof(s))
#define _IOR(t, n, s) _IOC(2, t, n, sizeof(s))
#define _IO(t, n) _IOC(0, t, n, 0)

/* 32-bit-era payload size per BC_/BR_ nr (0 = _IO). From the 4.3 UAPI, with
 * RIM extras verified from libbinder (BR_ATTEMPT_ACQUIRE = 12). */
static const uint8_t bc32_size[32] = {
    [BC_TRANSACTION] = 40, [BC_REPLY] = 40, [BC_ACQUIRE_RESULT] = 4,
    [BC_FREE_BUFFER] = 4, [BC_INCREFS] = 4, [BC_ACQUIRE] = 4,
    [BC_RELEASE] = 4, [BC_DECREFS] = 4, [BC_INCREFS_DONE] = 8,
    [BC_ACQUIRE_DONE] = 8, [BC_ATTEMPT_ACQUIRE] = 8, [BC_REGISTER_LOOPER] = 0,
    [BC_ENTER_LOOPER] = 0, [BC_EXIT_LOOPER] = 0,
    [BC_REQUEST_DEATH_NOTIFICATION] = 8, [BC_CLEAR_DEATH_NOTIFICATION] = 8,
    [BC_DEAD_BINDER_DONE] = 4,
};
static const uint8_t br32_size[32] = {
    [BR_ERROR] = 4, [BR_OK] = 0, [BR_TRANSACTION] = 40, [BR_REPLY] = 40,
    [BR_ACQUIRE_RESULT] = 4, [BR_DEAD_REPLY] = 0,
    [BR_TRANSACTION_COMPLETE] = 0, [BR_INCREFS] = 8, [BR_ACQUIRE] = 8,
    [BR_RELEASE] = 8, [BR_DECREFS] = 8, [BR_ATTEMPT_ACQUIRE] = 12,
    [BR_NOOP] = 0, [BR_SPAWN_LOOPER] = 0, [BR_FINISHED] = 0,
    [BR_DEAD_BINDER] = 4, [BR_CLEAR_DEATH_NOTIFICATION_DONE] = 4,
    [BR_FAILED_REPLY] = 0, [BR_FROZEN_REPLY] = 0,
};

static uint32_t swap_dir(uint32_t dir)
{
    if (dir == 1) return 2;
    if (dir == 2) return 1;
    return dir;
}

static uint32_t xlate_cmd(uint32_t cmd, int to32)
{
    uint32_t dir = cmd >> 30, type = (cmd >> 8) & 0xff, nr = cmd & 0xff;
    uint32_t sz = (cmd >> 16) & 0x3fff;
    uint32_t nsz;
    if (to32) {
        if (type == 'c') nsz = (nr < 32) ? bc32_size[nr] : 0;
        else if (type == 'r') nsz = (nr < 32) ? br32_size[nr] : 0;
        else nsz = sz;
    } else {
        /* rim -> A11 sizes: structs we translate have known A11 sizes */
        if (type == 'c') {
            switch (nr) {
            case BC_TRANSACTION: case BC_REPLY: nsz = sizeof(txn64_t); break;
            case BC_INCREFS_DONE: case BC_ACQUIRE_DONE: nsz = sizeof(pc64_t); break;
            case BC_REQUEST_DEATH_NOTIFICATION: case BC_CLEAR_DEATH_NOTIFICATION:
                nsz = 12; break; /* A11 binder_handle_cookie is packed 12 */
            default: nsz = sz; break;
            }
        } else if (type == 'r') {
            switch (nr) {
            case BR_TRANSACTION: case BR_REPLY: nsz = sizeof(txn64_t); break;
            case BR_INCREFS: case BR_ACQUIRE: case BR_RELEASE: case BR_DECREFS:
                nsz = sizeof(pc64_t); break;
            case BR_ATTEMPT_ACQUIRE: nsz = 16; break;
            case BR_DEAD_BINDER: case BR_CLEAR_DEATH_NOTIFICATION_DONE:
                nsz = 8; break;
            default: nsz = sz; break;
            }
        } else nsz = sz;
    }
    return (swap_dir(dir) << 30) | ((nsz & 0x3fff) << 16) | (type << 8) | nr;
}

uint32_t binder_cmd64_to_rim(uint32_t cmd) { return xlate_cmd(cmd, 1); }
uint32_t binder_cmd_rim_to64(uint32_t cmd) { return xlate_cmd(cmd, 0); }

int binder_bwr64_to_32(const bwr64_t *in, bwr32_t *out, xlate_ctx_t *ctx)
{
    if (!in || !out || !ctx || !ctx->cb_in) return -1;
    out->write_size = (uint32_t)in->write_size;
    out->write_consumed = (uint32_t)in->write_consumed;
    out->write_buffer = in->write_buffer ? ctx->cb_in(in->write_buffer) : 0;
    out->read_size = (uint32_t)in->read_size;
    out->read_consumed = (uint32_t)in->read_consumed;
    out->read_buffer = in->read_buffer ? ctx->cb_in(in->read_buffer) : 0;
    return 0;
}

int binder_bwr32_to_64(const bwr32_t *in, bwr64_t *out, xlate_ctx_t *ctx)
{
    if (!in || !out || !ctx) return -1;
    out->write_size = in->write_size;
    out->write_consumed = in->write_consumed;
    out->write_buffer = ctx->cb_out ? ctx->cb_out(in->write_buffer) : in->write_buffer;
    out->read_size = in->read_size;
    out->read_consumed = in->read_consumed;
    out->read_buffer = ctx->cb_out ? ctx->cb_out(in->read_buffer) : in->read_buffer;
    return 0;
}

/* Translate an object blob (A11 24B objects at offsets) 64->32 in place-ish:
 * src buffer -> dst buffer, offsets u64 array -> u32 array. Returns new
 * offsets_size or -1. */
static long xlate_objects64_to_32(const uint8_t *src, uint64_t data_size,
                                  const uint8_t *off64, uint64_t offsets_size,
                                  uint8_t *dst, uint8_t *off32, xlate_ctx_t *ctx)
{
    uint64_t i, n = offsets_size / sizeof(uint64_t);
    if (offsets_size % sizeof(uint64_t)) return -1;
    memcpy(dst, src, (size_t)data_size);
    for (i = 0; i < n; ++i) {
        uint64_t o64;
        obj64_t *o;
        memcpy(&o64, off64 + i * 8, 8);
        if (o64 + sizeof(obj64_t) > data_size) return -1;
        o = (obj64_t *)(dst + o64);
        if (o->type == BINDER_TYPE_FDA || o->type == BINDER_TYPE_PTR) return -1; /* not supported */
        /* 32-bit object at the same offset shrinks; field order is compatible */
        {
            obj32_t t;
            t.type = o->type;
            t.flags = o->flags;
            if (o->type == BINDER_TYPE_BINDER || o->type == BINDER_TYPE_WEAK_BINDER)
                t.handle = (uint32_t)o->binder;
            else
                t.handle = o->handle;
            t.cookie = (uint32_t)o->cookie;
            memcpy(dst + o64, &t, sizeof t);
        }
        {
            uint32_t o32 = (uint32_t)o64;
            memcpy(off32 + i * 4, &o32, 4);
        }
    }
    return (long)(n * 4);
}

static void xlate_txn64_to_32(const txn64_t *in, txn32_t *out, xlate_ctx_t *ctx)
{
    out->target.handle = in->target.handle; /* handle paths only need the u32 */
    out->cookie = in->cookie ? ctx->cb_in(in->cookie) : 0;
    out->code = in->code;
    out->flags = in->flags;
    out->sender_pid = in->sender_pid;
    out->sender_euid = in->sender_euid;
    out->data_size = (uint32_t)in->data_size;
    out->offsets_size = (uint32_t)in->offsets_size;
    out->data.ptr.buffer = in->data.ptr.buffer ? ctx->cb_in(in->data.ptr.buffer) : 0;
    out->data.ptr.offsets = in->data.ptr.offsets ? ctx->cb_in(in->data.ptr.offsets) : 0;
}

long binder_writebuf64_to_32(const void *in, size_t in_size,
                             void *out, size_t out_cap, xlate_ctx_t *ctx)
{
    const uint8_t *p = in, *end = p + in_size;
    uint8_t *q = out, *qend = q + out_cap;
    while (p + 4 <= end) {
        uint32_t cmd;
        memcpy(&cmd, p, 4);
        if (cmd == 0) break;
        uint32_t type = (cmd >> 8) & 0xff, nr = cmd & 0xff;
        uint32_t sz = (cmd >> 16) & 0x3fff;
        if (type != 'c') return -1;
        if (q + 4 > qend) return -1;
        {
            uint32_t ncmd = binder_cmd64_to_rim(cmd);
            memcpy(q, &ncmd, 4);
        }
        p += 4; q += 4;
        if (nr == BC_TRANSACTION || nr == BC_REPLY) {
            txn64_t t64;
            txn32_t t32;
            if (p + sizeof(t64) > end || q + sizeof(t32) > qend) return -1;
            memcpy(&t64, p, sizeof t64);
            xlate_txn64_to_32(&t64, &t32, ctx);
            /* translate the pointed-to data/offsets blobs into appended arena
             * space (caller guarantees room; offsets are resolved by cb_in) */
            if (t64.data_size || t64.offsets_size) {
                const uint8_t *d64 = (const uint8_t *)(uintptr_t)t64.data.ptr.buffer;
                const uint8_t *o64 = (const uint8_t *)(uintptr_t)t64.data.ptr.offsets;
                long newoff, off32sz = 0;
                uint8_t *d32 = (uint8_t *)(uintptr_t)ctx->cb_out(t32.data.ptr.buffer);
                (void)newoff; (void)off32sz; (void)d64; (void)o64; (void)d32;
                /* Real target: buffers are in the same 32-bit space; the
                 * caller pre-allocates the translated blob and points
                 * t32.data.ptr at it (see test/session notes).  Here we just
                 * fail unless the caller pre-translated (identity mapping). */
                if (t64.offsets_size && t64.data_size) {
                    static uint8_t scratch[8192]; static uint8_t scratch_off[1024];
                    long r = xlate_objects64_to_32(d64, t64.data_size, o64,
                                                   t64.offsets_size, scratch,
                                                   scratch_off, ctx);
                    if (r < 0) return -1;
                    t32.data_size = (uint32_t)t64.data_size;
                    t32.offsets_size = (uint32_t)r;
                    t32.data.ptr.buffer = ctx->cb_in((uint64_t)(uintptr_t)scratch);
                    t32.data.ptr.offsets = ctx->cb_in((uint64_t)(uintptr_t)scratch_off);
                }
            }
            memcpy(q, &t32, sizeof t32);
            p += sizeof t64; q += sizeof t32;
        } else {
            /* payloads: pc64 -> pc32, or u64 ptr -> u32, or fixed-size u32s */
            uint32_t psz = sz; /* A11 size */
            if (p + psz > end || q + psz > qend) return -1;
            if (nr == BC_INCREFS_DONE || nr == BC_ACQUIRE_DONE) {
                pc64_t a; pc32_t b;
                memcpy(&a, p, sizeof a);
                b.ptr = (uint32_t)a.ptr;
                b.cookie = (uint32_t)a.cookie;
                memcpy(q, &b, sizeof b);
                p += sizeof a; q += sizeof b;
            } else if (nr == BC_FREE_BUFFER || nr == BC_DEAD_BINDER_DONE) {
                uint64_t a; uint32_t b;
                memcpy(&a, p, 8); b = (uint32_t)a; memcpy(q, &b, 4);
                p += 8; q += 4;
            } else if (nr == BC_REQUEST_DEATH_NOTIFICATION ||
                       nr == BC_CLEAR_DEATH_NOTIFICATION) {
                /* A11 packed binder_handle_cookie {u32 handle; u64 cookie} = 12 */
                uint32_t handle; uint64_t cookie;
                memcpy(&handle, p, 4); memcpy(&cookie, p + 4, 8);
                memcpy(q, &handle, 4);
                { uint32_t c = (uint32_t)cookie; memcpy(q + 4, &c, 4); }
                p += 12; q += 8;
            } else {
                memcpy(q, p, psz); p += psz; q += psz;
            }
        }
        p = (const uint8_t *)in + ALIGN4((size_t)(p - (const uint8_t *)in));
        q = (uint8_t *)out + ALIGN4((size_t)(q - (uint8_t *)out));
    }
    return (long)(q - (uint8_t *)out);
}

long binder_readbuf32_to_64(const void *in, size_t in_size,
                            void *out, size_t out_cap, xlate_ctx_t *ctx)
{
    const uint8_t *p = in, *end = p + in_size;
    uint8_t *q = out, *qend = q + out_cap;
    while (p + 4 <= end) {
        uint32_t cmd;
        memcpy(&cmd, p, 4);
        if (cmd == 0) break;
        uint32_t type = (cmd >> 8) & 0xff, nr = cmd & 0xff, sz = (cmd >> 16) & 0x3fff;
        if (type != 'r') return -1;
        if (q + 4 > qend) return -1;
        { uint32_t ncmd = binder_cmd_rim_to64(cmd); memcpy(q, &ncmd, 4); }
        p += 4; q += 4;
        if (nr == BR_TRANSACTION || nr == BR_REPLY) {
            txn32_t t32; txn64_t t64;
            if (p + sizeof t32 > end || q + sizeof t64 > qend) return -1;
            memcpy(&t32, p, sizeof t32);
            memset(&t64, 0, sizeof t64);
            t64.target.handle = t32.target.handle;
            t64.cookie = ctx->cb_out ? ctx->cb_out(t32.cookie) : t32.cookie;
            t64.code = t32.code; t64.flags = t32.flags;
            t64.sender_pid = t32.sender_pid; t64.sender_euid = t32.sender_euid;
            t64.data_size = t32.data_size; t64.offsets_size = t32.offsets_size;
            t64.data.ptr.buffer = ctx->cb_out ? ctx->cb_out(t32.data.ptr.buffer) : t32.data.ptr.buffer;
            t64.data.ptr.offsets = ctx->cb_out ? ctx->cb_out(t32.data.ptr.offsets) : t32.data.ptr.offsets;
            /* NOTE: the pointed-to blobs need 32->64 expansion in the real
             * integration (handled there with an arena); structures only here. */
            memcpy(q, &t64, sizeof t64);
            p += sizeof t32; q += sizeof t64;
        } else {
            if (p + sz > end || q + sz > qend) return -1;
            if (nr == BR_INCREFS || nr == BR_ACQUIRE || nr == BR_RELEASE || nr == BR_DECREFS) {
                pc32_t a; pc64_t b;
                memcpy(&a, p, sizeof a); b.ptr = a.ptr; b.cookie = a.cookie;
                memcpy(q, &b, sizeof b); p += sizeof a; q += sizeof b;
            } else if (nr == BR_DEAD_BINDER || nr == BR_CLEAR_DEATH_NOTIFICATION_DONE) {
                uint32_t a; uint64_t b;
                memcpy(&a, p, 4); b = a; memcpy(q, &b, 8); p += 4; q += 8;
            } else {
                memcpy(q, p, sz); p += sz; q += sz;
            }
        }
        p = (const uint8_t *)in + ALIGN4((size_t)(p - (const uint8_t *)in));
        q = (uint8_t *)out + ALIGN4((size_t)(q - (uint8_t *)out));
    }
    return (long)(q - (uint8_t *)out);
}

/* keep the _IOC macros referenced (used by callers/tests) */
uint32_t binder_ioc(int dir, int type, int nr, int size) { return _IOC(dir, type, nr, size); }
