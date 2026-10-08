/* stub: real decls in qnx_compat.h (freestanding QNX cross-compile) */
#include "qnx_compat.h"

/* bionic-style errno: route through the shim's __errno() (-> QNX per-thread
 * errno).  qnx_compat.h's `extern int errno;` declaration is shadowed here. */
extern int *__errno(void);
#ifndef errno
#define errno (*__errno())
#endif
