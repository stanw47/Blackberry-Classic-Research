// wrexec tests: verify every A11 binder ioctl constant against the value the
// disassembled libbinder (bacon + Passport A11 arm32) passes, and the struct
// sizes against the A11 UAPI. This locks the ABI for the QNX resmgr.
#include "binder_a11.h"
#include <stdio.h>
#include <string.h>

#define CHECK(cond) do { if(!(cond)){ printf("FAIL: %s\n", #cond); fails++; } } while(0)

int main(void) {
    int fails = 0;
    /* ioctl numbers — MUST match libbinder disasm exactly */
    CHECK(BINDER_WRITE_READ == 0xc0306201u);
    CHECK(BINDER_VERSION == 0xc0046209u);
    CHECK(BINDER_SET_CONTEXT_MGR == 0x40046207u);
    CHECK(BINDER_SET_CONTEXT_MGR_EXT == 0x4018620du);
    CHECK(BINDER_THREAD_EXIT == 0x40046208u);
    CHECK(BINDER_SET_MAX_THREADS == 0x40086205u);
    CHECK(BINDER_GET_NODE_DEBUG_INFO == 0xc018620bu);
    CHECK(BINDER_GET_NODE_INFO_FOR_REF == 0xc018620cu);
    CHECK(BINDER_FREEZE == 0x400c620eu);
    CHECK(BINDER_GET_FROZEN_INFO == 0xc00c620fu);
    CHECK(BINDER_ENABLE_ONEWAY_SPAM_DETECTION == 0x40046210u);
    /* struct wire sizes (64-bit layout, ARM32) */
    CHECK(sizeof(struct binder_write_read) == 48);
    CHECK(sizeof(struct binder_transaction_data) == 64);
    CHECK(sizeof(struct flat_binder_object) == 24);
    CHECK(sizeof(struct binder_version) == 4);
    CHECK(sizeof(struct binder_node_debug_info) == 24);
    CHECK(sizeof(struct binder_node_info_for_ref) == 24);
    CHECK(sizeof(struct binder_freeze_info) == 12);
    CHECK(sizeof(struct binder_frozen_status_info) == 12);
    /* BC_/BR_ stream words */
    CHECK(BC_TRANSACTION == 0x40406300u);
    CHECK(BC_REQUEST_DEATH_NOTIFICATION == 0x400c630eu);
    CHECK(BC_CLEAR_DEATH_NOTIFICATION == 0x400c630fu);
    CHECK(BR_TRANSACTION == 0x80407202u);
    CHECK(BR_TRANSACTION_SEC_CTX == 0x80487202u);
    CHECK(BR_REPLY == 0x80407203u);
    CHECK(BR_SPAWN_LOOPER == 0x8000720du);

    printf(fails ? "%d FAILURES\n" : "ALL ABI CHECKS PASS\n", fails);
    return fails != 0;
}