/* qnx_binder_redirect.h — force-included in the A11 libbinder build for QNX.
 *
 * Routes ioctl() calls (binder driver fd) through qnx_binder_ioctl(), which
 * speaks the BB10 /dev/binder driver's devctl protocol with the 32-bit
 * translation (runtime/a11-build/qnx_binder/).  Upstream sources are not
 * patched; this is a build-level redirect.
 */
#ifndef QNX_BINDER_REDIRECT_H
#define QNX_BINDER_REDIRECT_H

/* parse the real declaration first so the macro below cannot corrupt it */
#include <sys/ioctl.h>

#ifdef __cplusplus
extern "C" {
#endif
int qnx_binder_ioctl(int fd, unsigned long request, void *arg);
#ifdef __cplusplus
}
#endif

#define ioctl(fd, req, args...) qnx_binder_ioctl((fd), (unsigned long)(req), (void *)(args))

#endif /* QNX_BINDER_REDIRECT_H */
