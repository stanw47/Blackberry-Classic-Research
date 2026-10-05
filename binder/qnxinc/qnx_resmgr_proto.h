/* QNX symbols in libc.so.3 but not declared by our 3 real headers. */
#include "qnx_compat.h"
#include <sys/neutrino.h>

struct _dispatch;
typedef struct _dispatch dispatch_t;

/* resmgr_attr_t — 32 bytes (RIM memset(sp+128,0,32); [sp+132]=1, [sp+136]=2048
 * => flags@+0, nparts_max@+4, msg_max_size@+8). */
typedef struct _resmgr_attr {
    unsigned flags;         /* [+0] */
    unsigned nparts_max;    /* [+4] */
    unsigned msg_max_size;  /* [+8] */
    int      nparts_hi;     /* [+12] */
    int      nparts_lo;     /* [+16] */
    void    *other_func;    /* [+20] */
    unsigned reserved[3];   /* [+24..+36] */
} resmgr_attr_t;
/* thread_pool_attr_t — 68 bytes (RIM memset(sp+16,0,68)).
 * [+0]=handle, [+4..+20]=5 fn ptrs (block_func,unblock_func,handler_func,
 *   context_alloc,context_free), [+28]=lo_water, [+30]=hi_water,
 *   [+32]=increment, [+34]=maximum (halfwords). */
typedef struct _thread_pool_attr {
    void    *handle;        /* [+0] dispatch_t* */
    void    *block_func;    /* [+4] */
    void    *unblock_func;  /* [+8] */
    void    *handler_func;  /* [+12] */
    void    *context_alloc; /* [+16] */
    void    *context_free;  /* [+20] */
    unsigned short lo_water;    /* [+28] (pad [+24]) */
    unsigned short hi_water;    /* [+30] */
    unsigned short increment;   /* [+32] */
    unsigned short maximum;     /* [+34] */
    unsigned reserved[8];   /* [+36..+68] */
} thread_pool_attr_t;
typedef struct _thread_pool { int dummy; } thread_pool_t;

#define S_IFCHR 0x2000
#define _FTYPE_ANY 0

extern dispatch_t *dispatch_create(void);
extern int dispatch_context_alloc(dispatch_t *dpp);
extern void dispatch_context_free(dispatch_t *dpp, void *ctp);
extern int dispatch_handler(void *ctp);
extern void *dispatch_block(void *ctp);
extern int dispatch_unblock(void *ctp);
extern int resmgr_attach(dispatch_t *dpp, resmgr_attr_t *attr, const char *path,
                         int ftype, unsigned flags, const void *connect_funcs, const void *io_funcs, void *handle);
extern thread_pool_t *thread_pool_create(thread_pool_attr_t *attr, unsigned flags);
extern int thread_pool_start(void *pool);
extern int MsgInfo(int rcvid, struct _msg_info *info);
extern int MsgReply(int rcvid, int status, const void *msg, int nbytes);
extern int MsgError(int rcvid, int error);
extern int ChannelCreate(unsigned flags);
extern void perror(const char *s);
extern char *strerror(int errnum);
