/*
 * binder_handlers.h — portable glue between a binder client's ioctl and the
 * engine (binder_core.c).
 *
 * This is the layer every transport funnels into:
 *   - the QNX resmgr transport (src/binder.c) receives a _IO_DEVCTL message
 *     (QNX libc ioctl() == devctl()), resolves the caller to a
 *     binder_proc/binder_thread from the connection, stages the ioctl arg,
 *     and calls binder_handle_ioctl(); it then writes back the returned bytes.
 *   - the host simulator (tests/test_glue.c) drives this exact same function
 *     so the ioctl-arg staging and reply-size rules are validated off-device.
 *
 * The engine already implements every ioctl (WRITE_READ, SET_MAX_THREADS,
 * VERSION, SET_CONTEXT_MGR(_EXT), GET_NODE_*, FREEZE, ...) inside
 * binder_ioctl(); the glue only decides the arg/out byte accounting the way
 * the Linux kernel ioctl/ioctl-number conventions require.
 */

#ifndef BINDER_HANDLERS_H
#define BINDER_HANDLERS_H

#include <stddef.h>
#include <stdint.h>
#include "binder_core.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Per-call context. `mem` translates the client's transport pointers
 * (bwr->write_buffer/read_buffer, td.data.ptr.buffer/offsets) into
 * driver-accessible memory. `nonblock` mirrors O_NONBLOCK on the fd. */
struct binder_call {
    struct binder_ctx      *ctx;
    struct binder_proc     *proc;
    struct binder_thread   *thread;
    struct binder_mem       mem;
    int                     nonblock;
};

/* Number of bytes libbinder expects written back for `cmd`.
 * Mirrors kernel ioctl semantics: the _IOR/_IOWR commands return their arg
 * struct (size from the ioctl number); _IOW-only commands are pure inputs. */
size_t binder_ioctl_reply_size(unsigned int cmd);

/* Handle one ioctl for proc/thread.
 *   cmd      - A11 ioctl number (binder_a11.h BINDER_*).
 *   arg      - staged copy of the client's ioctl arg (writable buffer). The
 *              engine may update it in place (e.g. the binder_write_read's
 *              write_consumed/read_consumed, version, node info).
 *   arg_size - bytes the transport staged into arg; must be >= _IOC_SIZE(cmd).
 * Returns:
 *   >= 0  - bytes written back into arg that the transport must copy to the
 *           client (matches binder_ioctl_reply_size).
 *   < 0   - negative errno (client ioctl() returns -1, errno = the value). */
int binder_handle_ioctl(struct binder_call *c, unsigned int cmd,
                        void *arg, size_t arg_size);

#ifdef __cplusplus
}
#endif
#endif /* BINDER_HANDLERS_H */