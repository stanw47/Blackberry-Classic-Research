/* qnx_binder_redirect.h — force-included in the A11 libbinder build for QNX.
 *
 * Routes binder-driver ioctl()s and the ProcessState mmap() through the QNX
 * shim (runtime/a11-build/qnx_binder/).  The driver peer-maps the txn shm into
 * the client during CFG, so qnx_binder_mmap() returns that address instead of
 * mapping the fd (session50e).  Upstream sources are not patched; this is a
 * build-level redirect.
 */
#ifndef QNX_BINDER_REDIRECT_H
#define QNX_BINDER_REDIRECT_H

/* parse the real declarations first so the macros cannot corrupt them */
#include <sys/ioctl.h>
#include <sys/mman.h>
#include "qnx_bionic_redirect.h"

#ifdef __cplusplus
extern "C" {
#endif
int qnx_binder_ioctl(int fd, unsigned long request, void *arg);
void *qnx_binder_mmap(void *addr, unsigned long len, int prot, int flags, int fd, long long off);
#ifdef __cplusplus
}
#endif

#define ioctl(fd, req, args...) qnx_binder_ioctl((fd), (unsigned long)(req), (void *)(args))
#define mmap(addr, len, prot, flags, fd, off) qnx_binder_mmap((addr), (unsigned long)(len), (prot), (flags), (fd), (off))

#endif /* QNX_BINDER_REDIRECT_H */
