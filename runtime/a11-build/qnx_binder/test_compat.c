/* test_compat.c — host unit tests for the 64<->32 binder wire translation.
 * Build: gcc -no-pie -I. binder_compat.c test_compat.c -o test_compat */
#include "binder_compat.h"
#include <stdio.h>
#include <string.h>

static uint32_t cb_in(uint64_t v) { return (uint32_t)v; }
static uint64_t cb_out(uint32_t v) { return (uint64_t)v; }

static int fails;

#define CK(name, a, b) do { \
    unsigned long _a = (unsigned long)(a), _b = (unsigned long)(b); \
    if (_a != _b) { printf("FAIL %-42s got 0x%lx want 0x%lx\n", name, _a, _b); fails++; } \
    else printf("ok   %s\n", name); \
} while (0)

int main(void)
{
    static xlate_ctx_t ctx = { cb_in, cb_out };

    /* --- command translation vs RIM's extracted values --- */
    CK("BC_TRANSACTION -> RIM", binder_cmd64_to_rim(0x40406300u), 0x80286300u);
    CK("BC_REPLY -> RIM",       binder_cmd64_to_rim(0x40406301u), 0x80286301u);
    CK("BC_INCREFS_DONE -> RIM",binder_cmd64_to_rim(0x40106308u), 0x80086308u);
    CK("BC_ACQUIRE_RESULT -> RIM", binder_cmd64_to_rim(0x40046302u), 0x80046302u);
    CK("BC_DEAD_BINDER_DONE -> RIM", binder_cmd64_to_rim(0x40086310u), 0x80046310u);
    CK("BR_TRANSACTION -> RIM", binder_cmd64_to_rim(0x80407202u), 0x40287202u);
    CK("BR_RELEASE -> RIM",     binder_cmd64_to_rim(0x80107209u), 0x40087209u);
    CK("BR_CLEAR_DEATH_DONE -> RIM", binder_cmd64_to_rim(0x80087210u), 0x40047210u);
    CK("BR_SPAWN_LOOPER unchanged", binder_cmd64_to_rim(0x720du), 0x720du);
    CK("BC_ENTER_LOOPER unchanged", binder_cmd64_to_rim(0x630cu), 0x630cu);
    CK("inverse BC_TRANSACTION", binder_cmd_rim_to64(0x80286300u), 0x40406300u);
    CK("inverse BR_TRANSACTION", binder_cmd_rim_to64(0x40287202u), 0x80407202u);

    /* --- binder_write_read 64 -> 32 --- */
    {
        bwr64_t in; bwr32_t out;
        memset(&in, 0, sizeof in);
        in.write_size = 0x48; in.write_buffer = 0x12345678;
        in.read_size = 0x100; in.read_buffer = 0x87654321;
        CK("bwr64->32 rc", binder_bwr64_to_32(&in, &out, &ctx), 0);
        CK("bwr write_size", out.write_size, 0x48u);
        CK("bwr write_buffer", out.write_buffer, 0x12345678u);
        CK("bwr read_buffer", out.read_buffer, 0x87654321u);
    }

    /* --- write buffer with BC_TRANSACTION + one flat object --- */
    {
        uint8_t blob[40];
        uint64_t offsets[1];
        uint8_t wb[4 + sizeof(txn64_t)];
        txn64_t t;
        obj64_t o;
        uint8_t outbuf[512];
        long n;

        memset(blob, 0, sizeof blob);
        o.type = BINDER_TYPE_BINDER; o.flags = 0x7;
        o.binder = 0x11112222; o.cookie = 0x33334444;
        memcpy(blob + 8, &o, sizeof o);
        offsets[0] = 8;

        memset(&t, 0, sizeof t);
        t.target.handle = 0x99;
        t.code = 0x4242;
        t.data_size = sizeof blob;
        t.offsets_size = sizeof offsets;
        t.data.ptr.buffer = (uint64_t)(uintptr_t)blob;
        t.data.ptr.offsets = (uint64_t)(uintptr_t)offsets;
        *(uint32_t *)wb = 0x40406300u; /* BC_TRANSACTION (A11) */
        memcpy(wb + 4, &t, sizeof t);

        n = binder_writebuf64_to_32(wb, sizeof wb, outbuf, sizeof outbuf, &ctx);
        CK("writebuf rc", n, (long)(4 + sizeof(txn32_t)));
        {
            uint32_t cmd;
            txn32_t t32;
            obj32_t *po;
            uint32_t *pof;
            memcpy(&cmd, outbuf, 4);
            memcpy(&t32, outbuf + 4, sizeof t32);
            CK("writebuf cmd", cmd, 0x80286300u);
            CK("txn32 code", t32.code, 0x4242u);
            CK("txn32 target", t32.target.handle, 0x99u);
            CK("txn32 data_size", t32.data_size, sizeof blob);
            CK("txn32 offsets_size", t32.offsets_size, 4u);
            po = (obj32_t *)((uint8_t *)(uintptr_t)t32.data.ptr.buffer + 8);
            pof = (uint32_t *)(uintptr_t)t32.data.ptr.offsets;
            CK("obj32 type", po->type, BINDER_TYPE_BINDER);
            CK("obj32 binder", po->handle, 0x11112222u);
            CK("obj32 cookie", po->cookie, 0x33334444u);
            CK("off32 value", pof[0], 8u);
        }
    }

    /* --- read buffer with BR_TRANSACTION --- */
    {
        uint8_t rb[4 + sizeof(txn32_t)];
        uint8_t outbuf[256];
        txn32_t t;
        long n;

        memset(&t, 0, sizeof t);
        t.target.handle = 0x55;
        t.code = 0x77;
        t.data_size = 0;
        t.offsets_size = 0;
        *(uint32_t *)rb = 0x40287202u; /* BR_TRANSACTION (RIM) */
        memcpy(rb + 4, &t, sizeof t);

        n = binder_readbuf32_to_64(rb, sizeof rb, outbuf, sizeof outbuf, &ctx);
        CK("readbuf rc", n, (long)(4 + sizeof(txn64_t)));
        {
            uint32_t cmd;
            txn64_t t64;
            memcpy(&cmd, outbuf, 4);
            memcpy(&t64, outbuf + 4, sizeof t64);
            CK("readbuf cmd", cmd, 0x80407202u);
            CK("txn64 code", t64.code, 0x77u);
            CK("txn64 target", t64.target.handle, 0x55u);
            CK("txn64 data_size", t64.data_size, 0u);
        }
    }

    printf(fails ? "RESULT: %d FAIL\n" : "RESULT: all pass\n", fails);
    return fails != 0;
}
