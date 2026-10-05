/*
 * binder_a11.h — minimal Android 11 binder driver UAPI, 64-bit wire layout.
 *
 * This is a redacted copy of the authoritative android11-5.4 kernel UAPI
 * (specimens/a11_binder_uapi.h), retaining ONLY the structures and numbers
 * the QNX resmgr must serve, with BINDER_IPC_32BIT NOT defined (the A11
 * arm32 libbinder does not define it — proof: WRITE_READ = 0xc0306201/48B,
 * SET_CONTEXT_MGR_EXT = _IOW size 24, VERSION prod => 8).
 *
 * All values verified 3 ways: UAPI header, libbinder.so disasm (bacon +
 * Passport A11), and AOSP android-11.0.0_r1 libbinder source.
 */

#ifndef BINDER_A11_H
#define BINDER_A11_H

/*
 * Types: on QNX we don't have <linux/...>; map to the equivalent
 * fixed-width stdint types so the wire layout is byte-identical to the
 * A11 kernel ABI (u64 == 8 bytes regardless of the 32-bit process).
 */
#include <stdint.h>
#include <sys/types.h>

typedef uint64_t binder_uintptr_t;
typedef uint64_t binder_size_t;
typedef uint32_t __u32;
typedef uint64_t __u64;
typedef int32_t  __s32;
typedef uint8_t  __u8;

#define _IOC_SIZE(nr) (((nr) >> _IOC_SIZESHIFT) & ((1 << _IOC_SIZEBITS) - 1))
typedef pid_t    binder_pid_t;   /* QNX pid_t is int (32-bit) — layout == arm32 */
typedef uid_t    binder_uid_t;   /* QNX uid_t is int (32-bit)             */
typedef int32_t  binder_pid;
typedef int32_t  binder_uid;

/*
 * pid_t / uid_t: QNX pid_t is int, uid_t int; A11 kernel uses kernel
 * types pid_t/uid_t (int on arm32).  Aliasing through int32 keeps layout.
 */

/* Kernel-style _IOC() macros (mirror linux/ioctl.h on arm32, 64-bit wire) */
#define _IOC_NRBITS     8
#define _IOC_TYPEBITS   8
#define _IOC_SIZEBITS   14
#define _IOC_DIRBITS    2

#define _IOC_NRSHIFT    0
#define _IOC_TYPESHIFT  (_IOC_NRSHIFT + _IOC_NRBITS)
#define _IOC_SIZESHIFT  (_IOC_TYPESHIFT + _IOC_TYPEBITS)
#define _IOC_DIRSHIFT   (_IOC_SIZESHIFT + _IOC_SIZEBITS)

#define _IOC_NONE       0U
#define _IOC_WRITE      1U
#define _IOC_READ       2U

#define _IOC(dir, type, nr, size) \
    (((dir)  << _IOC_DIRSHIFT) | \
     ((type) << _IOC_TYPESHIFT) | \
     ((nr)   << _IOC_NRSHIFT) | \
     ((size) << _IOC_SIZESHIFT))

#define _IOC_TYPECHECK(t) (sizeof(t))
#define _IO(type, nr)        _IOC(_IOC_NONE, (type), (nr), 0)
#define _IOR(type, nr, size_tp) _IOC(_IOC_READ, (type), (nr), _IOC_TYPECHECK(size_tp))
#define _IOW(type, nr, size_tp) _IOC(_IOC_WRITE, (type), (nr), _IOC_TYPECHECK(size_tp))
#define _IOWR(type, nr, size_tp) _IOC(_IOC_READ|_IOC_WRITE, (type), (nr), _IOC_TYPECHECK(size_tp))

#define BINDER_IPC_NR ('b')
#define BINDER_COMMAND_PROTOCOL 0x04000000UL

enum {
    BINDER_TYPE_BINDER = 1,
    BINDER_TYPE_WEAK_BINDER = 2,
    BINDER_TYPE_HANDLE = 3,
    BINDER_TYPE_WEAK_HANDLE = 4,
    BINDER_TYPE_FD = 5,
    BINDER_TYPE_FDA = 6,
    BINDER_TYPE_PTR = 7,
    BINDER_TYPE_CLEAR_BUF = 8,
    BINDER_TYPE_WEAK_PTR = 9,
    BINDER_TYPE_REDIRECTION = 10,
};

/* binder object header — common to all flat objects (zero-extended to 8B in kernel infos) */
struct binder_object_header {
    __u32 type;
};

/* Classic flat binder object (aligned 8 on A11/64-bit-wire) */
struct flat_binder_object {
    struct binder_object_header hdr;
    __u32 flags;

    union {
        binder_uintptr_t binder;
        __u32 handle;
    };

    binder_uintptr_t cookie;
};

#define FLAT_BINDER_FLAG_ACCEPTS_FDS 0x01
#define FLAT_BINDER_FLAG_TXN_SECURITY_CTX 0x02
#define FLAT_BINDER_FLAG_SUPPORTS_REDIRECTION 0x04
#define FLAT_BINDER_FLAG_REDIRECTION_REQUIRED 0x08

struct binder_fd_object {
    struct binder_object_header hdr;
    __u32 pad_flags;
    union {
        binder_uintptr_t parent; /* "parent" fd — must be 0 on create */
        __u32 fd;
    };
    binder_uintptr_t cookie;
};

struct binder_buffer_object {
    struct binder_object_header hdr;
    __u32 flags;
    binder_uintptr_t buffer;
    binder_size_t length;
    binder_size_t parent;
    binder_size_t parent_offset;
};

enum {
    BINDER_BUFFER_FLAG_HAS_PARENT = 1,
};

struct binder_fd_array_object {
    struct binder_object_header hdr;
    __u32 pad;
    binder_size_t num_fds;
    binder_size_t parent;
    binder_size_t parent_offset;
};

struct binder_transaction_data {
    union {
        __u32 handle;
        binder_uintptr_t ptr;
    } target;
    binder_uintptr_t cookie;   /* target object cookie */
    __u32 code;                /* transaction command */
    __u32 flags;

    binder_pid_t sender_pid;
    binder_uid_t sender_euid;

    binder_size_t data_size;
    binder_size_t offsets_size;

    union {
        struct {
            binder_uintptr_t buffer;
            binder_uintptr_t offsets;
        } ptr;
        __u8 buf[8];
    } data;
};

struct binder_transaction_data_secctx {
    struct binder_transaction_data transaction_data;
    binder_uintptr_t secctx;
};

struct binder_transaction_data_sg {
    struct binder_transaction_data transaction_data;
    binder_size_t buffers_size;
};

/* The txn flags as consumed by userspace drivers */
#define TF_ONE_WAY 0x01
#define TF_ROOT_OBJECT 0x04
#define TF_STATUS_CODE 0x08
#define TF_ACCEPT_FDS 0x10
#define TF_CLEAR_BUF 0x20
#define TF_UPDATE_TXN 0x40

struct binder_write_read {
    binder_size_t write_size;
    binder_size_t write_consumed;
    binder_uintptr_t write_buffer;
    binder_size_t read_size;
    binder_size_t read_consumed;
    binder_uintptr_t read_buffer;
};

struct binder_version {
    __s32 protocol_version;
};

#define BINDER_CURRENT_PROTOCOL_VERSION 8   /* 64-bit wire; libbinder requires
                                              * driver to report exactly this  */

struct binder_node_debug_info {
    binder_uintptr_t ptr;
    binder_uintptr_t cookie;
    __u32 has_strong_ref;
    __u32 has_weak_ref;
};

struct binder_node_info_for_ref {
    __u32 handle;
    __u32 strong_count;
    __u32 weak_count;
    __u32 reserved1;
    __u32 reserved2;
    __u32 reserved3;
};

struct binder_freeze_info {
    __u32 pid;
    __u32 enable;
    __u32 timeout_ms;
};

struct binder_frozen_status_info {
    __u32 pid;
    __u32 sync_recv;
    __u32 async_recv;
};

struct binder_ptr_cookie {
    binder_uintptr_t ptr;
    binder_uintptr_t cookie;
};

struct binder_handle_cookie {
    __u32 handle;
    binder_uintptr_t cookie;
};

struct binder_pri_ptr_cookie {
    binder_uintptr_t ptr;
    binder_uintptr_t cookie;
    __s32 priority;      /* priority hint; A11 libbinder expects 0x1000 (NORMAL) */
};

struct binder_pri_desc {
    __s32 priority;      /* 0x1000 NORMAL; 0x1001 URGENT */
    __u32 desc;
};

struct binder_frozen_state_info {
    binder_uintptr_t ptr;
    __u32 sync_recv;
    __u32 async_recv;
};

/* ioctl numbers — these are the EXACT constants libbinder.so passes.
   Verified via disasm of bacon (build ce058344) & Passport (89b2606d).    */
#define BINDER_WRITE_READ              _IOWR('b', 1, struct binder_write_read)
#define BINDER_SET_IDLE_TIMEOUT        _IOW('b', 3, __u64)
#define BINDER_SET_MAX_THREADS         _IOW('b', 5, __u64)
#define BINDER_SET_IDLE_PRIORITY       _IOW('b', 6, __s32)
#define BINDER_SET_CONTEXT_MGR         _IOW('b', 7, __s32)
#define BINDER_THREAD_EXIT             _IOW('b', 8, __s32)
#define BINDER_VERSION                 _IOWR('b', 9, struct binder_version)
#define BINDER_GET_NODE_DEBUG_INFO     _IOWR('b', 11, struct binder_node_debug_info)
#define BINDER_GET_NODE_INFO_FOR_REF   _IOWR('b', 12, struct binder_node_info_for_ref)
#define BINDER_SET_CONTEXT_MGR_EXT     _IOW('b', 13, struct flat_binder_object)
#define BINDER_FREEZE                  _IOW('b', 14, struct binder_freeze_info)
#define BINDER_GET_FROZEN_INFO         _IOWR('b', 15, struct binder_frozen_status_info)
#define BINDER_ENABLE_ONEWAY_SPAM_DETECTION _IOW('b', 16, __u32)

#ifndef BC_TRANSACTION
/* command protocol (BC_) — the exact 32-bit words read from write_buffer.
 * Each is the _IOW('c', nr, struct) / _IO('c', nr) encoding; the "size"
 * field (bits 29:16) tells the driver how many payload bytes follow.
 * Verified via the same _IOC math that yields the binder ioctl constants. */
enum {
    BC_TRANSACTION = 0x40406300,  /* _IOW('c',0, binder_transaction_data=64) */
    BC_REPLY       = 0x40406301,
    BC_ACQUIRE_RESULT = 0x40046302,
    BC_FREE_BUFFER = 0x40086303,
    BC_INCREFS     = 0x40046304,
    BC_ACQUIRE     = 0x40046305,
    BC_RELEASE     = 0x40046306,
    BC_DECREFS     = 0x40046307,
    BC_INCREFS_DONE = 0x40106308,
    BC_ACQUIRE_DONE = 0x40106309,
    BC_ATTEMPT_ACQUIRE = 0x4014630a,
    BC_REGISTER_LOOPER = 0x4000630b,
    BC_ENTER_LOOPER    = 0x4000630c,
    BC_EXIT_LOOPER     = 0x4000630d,
    BC_REQUEST_DEATH_NOTIFICATION = 0x400c630e,
    BC_CLEAR_DEATH_NOTIFICATION   = 0x400c630f,
    BC_DEAD_BINDER_DONE = 0x40086310,
    BC_TRANSACTION_SG = 0x40486311,
    BC_REPLY_SG       = 0x40486312,
    BC_REQUEST_FREEZE_NOTIFICATION = 0x400c6313,
    BC_CLEAR_FREEZE_NOTIFICATION   = 0x400c6314,
    BC_FREEZE_NOTIFICATION_DONE    = 0x40086315,
};
#endif

/* response protocol (BR_) — exact 32-bit words written into read_buffer. */
#define BR_ERROR 0x80047200
#define BR_OK 0x80007201
#define BR_TRANSACTION_SEC_CTX 0x80487202
#define BR_TRANSACTION 0x80407202
#define BR_REPLY 0x80407203
#define BR_ACQUIRE_RESULT 0x80047204
#define BR_DEAD_REPLY 0x80007205
#define BR_TRANSACTION_COMPLETE 0x80007206
#define BR_INCREFS 0x80107207
#define BR_ACQUIRE 0x80107208
#define BR_RELEASE 0x80107209
#define BR_DECREFS 0x8010720a
#define BR_ATTEMPT_ACQUIRE 0x8018720b
#define BR_NOOP 0x8000720c
#define BR_SPAWN_LOOPER 0x8000720d
#define BR_FINISHED 0x8000720e
#define BR_DEAD_BINDER 0x8008720f
#define BR_CLEAR_DEATH_NOTIFICATION_DONE 0x80087210
#define BR_FAILED_REPLY 0x80007211
#define BR_FROZEN_REPLY 0x80007212
#define BR_ONEWAY_SPAM_SUSPECT 0x80007213
#define BR_FROZEN_BINDER 0x80107215
#define BR_CLEAR_FREEZE_NOTIFICATION_DONE 0x80087216

#endif /* BINDER_A11_H */