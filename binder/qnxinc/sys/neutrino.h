#ifndef _SYS_NEUTRINO_H
#define _SYS_NEUTRINO_H
#include "../qnx_compat.h"

/* struct _msg_info — returned by MsgInfo(). */
struct _msg_info {
    uint32_t    nd, srcnd;
    pid_t       pid;
    int32_t     tid, chid, scoid, coid;
    int32_t     msglen;
    uint32_t    srcmsglen, dstmsglen;
    int16_t     priority;
    int16_t     flags;
    int32_t     reserved[4];
};

/* struct _cred_info */
struct _cred_info {
    uid_t  ruid, euid, suid;
    gid_t  rgid, egid, sgid;
    uint32_t  ngroups;
    gid_t  grouplist[8];
};

/* struct _client_info */
struct _client_info {
    uint32_t        nd, flags;
    pid_t           pid;
    int32_t         sid, tid, chid, scoid, coid;
    struct _cred_info cred;
};

/* struct sigevent (QNX) */
struct sigevent {
    int16_t sigev_notify;
    int16_t sigev_signo;
    union { int sival_int; void *sival_ptr; } sigev_value;
    int32_t sigev_coid;
    int32_t sigev_id;
    int32_t sigev_priority;
};
typedef struct sigevent sigevent;

/* struct _pulse */
struct _pulse {
    uint16_t type, subtype;
    int8_t   code;
    int8_t   zero;
    int32_t  value;
    int32_t  scoid;
};
typedef struct _pulse io_pulse_t;

typedef struct { int dummy; } pm_power_attr_t;
typedef struct { void *iov_base; size_t iov_len; } iov_t;
#define SETIOV(i, a, l) ((i)->iov_base = (void*)(a), (i)->iov_len = (l))
#define EOK 0
#define O_NONBLOCK 0x4000
#endif
