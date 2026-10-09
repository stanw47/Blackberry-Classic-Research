/* qnx_bionic_redirect.h — force-included in every A11 chain library built for
 * the QNX port.
 *
 * The chain NEEDs libc.so.3 FIRST (session57 loader requirement), and QNX
 * libc.so.3 exports the pthread mutex/cond/once/key functions with its own
 * ABIs (8-byte sync objects), which would shadow the WS1 shim's
 * bionic-compatible 4-byte implementations and corrupt/hang the chain
 * (session50f).  Rename the call sites to the shim's exported implementations
 * so the loader binds them to the shim regardless of NEEDED order.
 */
#ifndef QNX_BIONIC_REDIRECT_H
#define QNX_BIONIC_REDIRECT_H

/* parse real declarations first so the macros cannot corrupt them */
#include <pthread.h>
#include <sys/resource.h>

/* the shim's exported implementations (declared so renamed call sites compile) */
#ifdef __cplusplus
extern "C" {
#endif
int  ws1_impl_pthread_mutex_lock(pthread_mutex_t *m);
int  ws1_impl_pthread_mutex_trylock(pthread_mutex_t *m);
int  ws1_impl_pthread_mutex_unlock(pthread_mutex_t *m);
int  ws1_impl_pthread_mutex_init(pthread_mutex_t *m, const pthread_mutexattr_t *a);
int  ws1_impl_pthread_mutex_destroy(pthread_mutex_t *m);
int  ws1_impl_pthread_cond_wait(pthread_cond_t *c, pthread_mutex_t *m);
int  ws1_impl_pthread_cond_timedwait(pthread_cond_t *c, pthread_mutex_t *m, const struct timespec *ts);
int  ws1_impl_pthread_cond_signal(pthread_cond_t *c);
int  ws1_impl_pthread_cond_broadcast(pthread_cond_t *c);
int  ws1_impl_pthread_cond_init(pthread_cond_t *c, const pthread_condattr_t *a);
int  ws1_impl_pthread_cond_destroy(pthread_cond_t *c);
int  ws1_impl_pthread_once(pthread_once_t *o, void (*fn)(void));
int  ws1_impl_pthread_key_create(pthread_key_t *k, void (*dtor)(void *));
void *ws1_impl_pthread_getspecific(pthread_key_t k);
int  ws1_impl_pthread_setspecific(pthread_key_t k, const void *v);
int  ws1_impl_getrlimit(int resource, struct rlimit *rlp);
#ifdef __cplusplus
}
#endif

#define pthread_mutex_lock       ws1_impl_pthread_mutex_lock
#define pthread_mutex_unlock     ws1_impl_pthread_mutex_unlock
#define pthread_mutex_trylock    ws1_impl_pthread_mutex_trylock
#define pthread_mutex_init       ws1_impl_pthread_mutex_init
#define pthread_mutex_destroy    ws1_impl_pthread_mutex_destroy
#define pthread_cond_wait        ws1_impl_pthread_cond_wait
#define pthread_cond_timedwait   ws1_impl_pthread_cond_timedwait
#define pthread_cond_signal      ws1_impl_pthread_cond_signal
#define pthread_cond_broadcast   ws1_impl_pthread_cond_broadcast
#define pthread_cond_init        ws1_impl_pthread_cond_init
#define pthread_cond_destroy     ws1_impl_pthread_cond_destroy
#define pthread_once             ws1_impl_pthread_once
#define pthread_key_create       ws1_impl_pthread_key_create
#define pthread_getspecific      ws1_impl_pthread_getspecific
#define pthread_setspecific      ws1_impl_pthread_setspecific
#define getrlimit                ws1_impl_getrlimit

#endif /* QNX_BIONIC_REDIRECT_H */
