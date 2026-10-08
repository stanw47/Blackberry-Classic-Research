/* binder_compat.h — Android-11 (64-bit binder ABI) <-> BB10/RIM 4.3 (32-bit
 * binder ABI) wire translation, for the Passport driver path.
 *
 * RIM's build swapped the ioctl direction bits (_IOC_WRITE=2, _IOC_READ=1) and
 * uses 32-bit-era struct sizes.  Verified values extracted from RIM's
 * libbinder/libbionic are in
 * Blackberry-Passport-Research/tools/passport-a11/rim_binder_commands.md.
 *
 * Host-testable; no QNX dependencies.
 */
#ifndef BINDER_COMPAT_H
#define BINDER_COMPAT_H

#include <stdint.h>
#include <stddef.h>

/* ---- commands ---- */
enum {
    BR_ERROR = 0, BR_OK, BR_TRANSACTION, BR_REPLY, BR_ACQUIRE_RESULT,
    BR_DEAD_REPLY, BR_TRANSACTION_COMPLETE, BR_INCREFS, BR_ACQUIRE,
    BR_RELEASE, BR_DECREFS, BR_ATTEMPT_ACQUIRE, BR_NOOP, BR_SPAWN_LOOPER,
    BR_FINISHED, BR_DEAD_BINDER, BR_CLEAR_DEATH_NOTIFICATION_DONE,
    BR_FAILED_REPLY, BR_FROZEN_REPLY
};
enum {
    BC_TRANSACTION = 0, BC_REPLY, BC_ACQUIRE_RESULT, BC_FREE_BUFFER,
    BC_INCREFS, BC_ACQUIRE, BC_RELEASE, BC_DECREFS, BC_INCREFS_DONE,
    BC_ACQUIRE_DONE, BC_ATTEMPT_ACQUIRE, BC_REGISTER_LOOPER,
    BC_ENTER_LOOPER, BC_EXIT_LOOPER, BC_REQUEST_DEATH_NOTIFICATION,
    BC_CLEAR_DEATH_NOTIFICATION, BC_DEAD_BINDER_DONE
};

/* Convert an A11 (64-bit ABI) BC_/BR_ command word to RIM's 32-bit word:
 * 1) size field -> 32-bit-era size, 2) direction bits swapped. */
uint32_t binder_cmd64_to_rim(uint32_t cmd);
/* Inverse (for translating RIM's driver replies into A11 words). */
uint32_t binder_cmd_rim_to64(uint32_t cmd);

/* ---- structs (packed to be layout-explicit) ---- */
typedef struct __attribute__((packed)) {
    uint64_t write_size, write_consumed, write_buffer;
    uint64_t read_size, read_consumed, read_buffer;
} bwr64_t; /* 48 */

typedef struct __attribute__((packed)) {
    uint32_t write_size, write_consumed, write_buffer;
    uint32_t read_size, read_consumed, read_buffer;
} bwr32_t; /* 24 */

typedef struct __attribute__((packed)) {
    union { uint32_t handle; uint64_t ptr; } target;
    uint64_t cookie;
    uint32_t code, flags;
    int32_t sender_pid;
    uint32_t sender_euid;
    uint64_t data_size, offsets_size;
    union { struct { uint64_t buffer, offsets; } ptr; uint8_t buf[8]; } data;
} txn64_t; /* 64 */

typedef struct __attribute__((packed)) {
    union { uint32_t handle; uint32_t ptr; } target;
    uint32_t cookie;
    uint32_t code, flags;
    int32_t sender_pid;
    uint32_t sender_euid;
    uint32_t data_size, offsets_size;
    union { struct { uint32_t buffer, offsets; } ptr; uint8_t buf[8]; } data;
} txn32_t; /* 40 */

typedef struct __attribute__((packed)) {
    uint32_t type, flags;
    union { uint64_t binder; uint32_t handle; };
    uint64_t cookie;
} obj64_t; /* 24 */

typedef struct __attribute__((packed)) {
    uint32_t type, flags;
    union { uint32_t binder; uint32_t handle; };
    uint32_t cookie;
} obj32_t; /* 16 */

typedef struct __attribute__((packed)) { uint64_t ptr, cookie; } pc64_t; /* 16 */
typedef struct __attribute__((packed)) { uint32_t ptr, cookie; } pc32_t; /* 8 */

/* flat_binder_object types (same numbers both eras) */
#define BINDER_TYPE_BINDER 1
#define BINDER_TYPE_WEAK_BINDER 2
#define BINDER_TYPE_HANDLE 3
#define BINDER_TYPE_WEAK_HANDLE 4
#define BINDER_TYPE_FD 5
#define BINDER_TYPE_FDA 6
#define BINDER_TYPE_PTR 7

/* ---- translation entry points ----
 * cb_in maps a 64-bit userspace pointer (as stored in the A11 structs) to the
 * 32-bit address space (identity in the host tests); cb_out is the reverse. */
typedef struct {
    uint32_t (*cb_in)(uint64_t va);
    uint64_t (*cb_out)(uint32_t va);
} xlate_ctx_t;

int binder_bwr64_to_32(const bwr64_t *in, bwr32_t *out, xlate_ctx_t *ctx);
int binder_bwr32_to_64(const bwr32_t *in, bwr64_t *out, xlate_ctx_t *ctx);

/* Translate a write buffer (BC_ commands + payloads) A11->RIM.
 * `out` must be >= in_size; returns bytes written or -1. */
long binder_writebuf64_to_32(const void *in, size_t in_size,
                             void *out, size_t out_cap, xlate_ctx_t *ctx);

/* Translate a read buffer (BR_ commands + payloads) RIM->A11. */
long binder_readbuf32_to_64(const void *in, size_t in_size,
                            void *out, size_t out_cap, xlate_ctx_t *ctx);

#endif /* BINDER_COMPAT_H */
