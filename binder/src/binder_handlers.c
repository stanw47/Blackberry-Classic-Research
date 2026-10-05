/*
 * binder_handlers.c — portable ioctl glue (see binder_handlers.h).
 *
 * The engine is a faithful port of the kernel's binder_ioctl();
 * these two functions are the glue that makes it behave exactly like
 * an Android ioctl():
 *
 *   - binder_ioctl_reply_size() implements the kernel's implicit copy-back:
 *     a command is _IOWR (or _IOR) when its ioctl number has the WRITE
 *     (i.e. "read into user") bit set, so libbinder expects that many bytes
 *     written back into the arg buffer. Pure _IOW commands get no copy-back.
 *
 *   - binder_handle_ioctl() validates that the transport staged enough arg
 *     bytes, funnels the call into the engine, and returns how many bytes
 *     the transport must copy back (or a negative errno).
 *
 * Compiled into both the QNX devctl transport (src/binder.c) and the host
 * simulator (tests/test_glue.c) so the exact same code path serves the real
 * device and the off-device tests.
 */

#include <errno.h>
#include <string.h>
#include "binder_handlers.h"

size_t
binder_ioctl_reply_size(unsigned int cmd)
{
    /* _IOC_DIRSHIFT is the bit offset of the direction field; kernel-style:
     * reply_buf_size = (_IOC_DIR(cmd) & _IOC_WRITE) ? _IOC_SIZE(cmd) : 0. */
    if (((cmd >> _IOC_DIRSHIFT) & _IOC_READ) != 0)
        return _IOC_SIZE(cmd);
    return 0;
}

int
binder_handle_ioctl(struct binder_call *c, unsigned int cmd,
                    void *arg, size_t arg_size)
{
    size_t req;
    int ret;

    req = _IOC_SIZE(cmd);
    if (arg_size < req)
        return -EINVAL;

    ret = binder_ioctl(c->ctx, c->proc, c->thread, cmd, arg,
                       &c->mem, c->nonblock);
    if (ret != 0)
        return ret;

    /* success: the number of bytes the transport copies back to the client
     * is dictated by the ioctl number, not by the engine. */
    return (int)binder_ioctl_reply_size(cmd);
}