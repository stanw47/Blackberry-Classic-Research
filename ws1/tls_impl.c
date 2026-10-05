/* ws1/tls_impl.c — bionic TLS/thread glue (__get_tls, __get_thread, ...).
 *
 * bionic ABI (from RIM's 4.3 libbionic disassembly):
 *   __get_tls()        -> pointer to the thread's TLS base; [tls+4] holds the
 *                         pthread_internal_t* (the "thread" handle).
 *   __get_thread()     -> __get_tls()[4]  == pthread_self() on QNX.
 *   __pthread_gettid(t)-> t->tid (offset +32 in pthread_internal_t).
 *   pthread_gettid_np()-> gettid().
 *
 * QNX provides pthread_self() (returns the thread handle), gettid(), and
 * per-thread storage via pthread_key_create/getspecific/setspecific.  We keep a
 * tiny per-thread struct whose [4] slot = pthread_self(), and return its address
 * from __get_tls().
 */

typedef unsigned uint32_t;
typedef unsigned long size_t;

extern void *pthread_self(void);
extern int gettid(void);

extern int pthread_key_create(unsigned *k, void (*dtor)(void *));
extern int pthread_getspecific(unsigned k);
extern int pthread_setspecific(unsigned k, const void *v);

/* per-thread TLS base: [0]=unused, [4]=pthread_internal_t* (== pthread_self()) */
struct tls_base {
    void     *reserved0;
    void     *thread;   /* == pthread_self() */
    int       tid;      /* == gettid() */
};

static unsigned tls_key = 0;
static int      tls_key_inited = 0;

static struct tls_base *get_tls_base(void)
{
    struct tls_base *b;
    if (!tls_key_inited) {
        pthread_key_create(&tls_key, 0);
        tls_key_inited = 1;
    }
    b = (struct tls_base *)(long)pthread_getspecific(tls_key);
    if (!b) {
        static struct tls_base zero;
        b = &zero;
        /* Can't allocate per-thread storage without malloc; use a static slot
         * as the singleton TLS base for the (single-threaded) smoke phase.  A
         * real implementation would allocate per-thread once malloc works. */
        b->thread = pthread_self();
        b->tid    = gettid();
        pthread_setspecific(tls_key, b);
    }
    return b;
}

struct tls_base *ws1_impl___get_tls(void)
{
    return get_tls_base();
}

void *ws1_impl___get_thread(void)
{
    return get_tls_base()->thread;
}

int ws1_impl___pthread_gettid(const void *thread)
{
    /* thread is a pthread_internal_t*; on QNX we map it to gettid() because the
     * QNX pthread_self() handle is opaque and doesn't expose a +32 tid slot. */
    (void)thread;
    return gettid();
}

int ws1_impl_pthread_gettid_np(void)
{
    return gettid();
}

/* __tls_get_addr: general dynamic TLS lookup — unsupported without a real TLS
 * model; return a per-thread dummy slot. */
void *ws1_impl___tls_get_addr(void *ti)
{
    (void)ti;
    return (void *)get_tls_base();
}

/* ---- registration ---- */
struct ws1_glue_impl { const char *name; void *fn; };

struct ws1_glue_impl ws1_tls_impls[] = {
    { "__get_tls",         (void *)ws1_impl___get_tls },
    { "__get_thread",      (void *)ws1_impl___get_thread },
    { "__pthread_gettid",  (void *)ws1_impl___pthread_gettid },
    { "pthread_gettid_np", (void *)ws1_impl_pthread_gettid_np },
    { "__tls_get_addr",    (void *)ws1_impl___tls_get_addr },
    { 0, 0 },
};
