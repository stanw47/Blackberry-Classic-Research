/* ws1/glue_impl.c — real implementations for load-bearing bionic-only (GLUE)
 * symbols that have no direct QNX libc.so.3 equivalent.
 *
 * These are wired into the resolver via ws1_glue_impls[] below.  Anything not
 * listed still lands on __ws1_unimplemented (spin) until a real impl is added.
 *
 * Priority (this file):
 *   1. __futex_wait / __futex_wake — the bionic userspace sync primitive that
 *      pthread_mutex/condvar/once, std::mutex, and libc++ are all built on.
 *      Emulated with QNX native sync objects (SyncCreate/SyncMutexLock/
 *      SyncCondvarWait) keyed by the futex word address. sync_t is a 4-byte
 *      handle on QNX ARM, so no opaque pthread struct sizes need guessing.
 *   2. android_set_abort_message — simple static.
 *   3. __get_h_errno — per-thread h_errno via a QNX pthread key.
 */

typedef unsigned long size_t;
typedef long ssize_t;
typedef long long int64_t;

struct timespec_t { long tv_sec; long tv_nsec; };

/* ---- QNX pthread sync primitives, resolved BY POINTER from the real
 * libc.so.3 (NOT by name — the shim re-exports pthread_mutex_lock etc. as
 * bionic ABI symbols, and calling by name would bind to our own trampoline and
 * recurse).
 *
 * IMPORTANT (session71): QNX's pthread_mutex_t/cond_t are 8 bytes
 * (`struct _sync { int __count; unsigned __owner; }`), but bionic's are 4
 * bytes.  Handing a bionic 4-byte mutex to QNX's pthread_mutex_lock writes 8
 * bytes and clobbers the adjacent object (this is exactly what corrupted
 * libutils' gSyspropList).  So: internal QNX sync objects here are 8 bytes, and
 * the bionic 4-byte mutex/cond ABI is implemented in software over futexes. */
typedef struct { int __count; unsigned __owner; } pthread_mutex_t;   /* QNX _sync */
typedef pthread_mutex_t pthread_cond_t;

static int (*p_pthread_mutex_lock)(pthread_mutex_t *) = 0;
static int (*p_pthread_mutex_unlock)(pthread_mutex_t *) = 0;
static int (*p_pthread_cond_wait)(pthread_cond_t *, pthread_mutex_t *) = 0;
static int (*p_pthread_cond_signal)(pthread_cond_t *) = 0;
static int (*p_pthread_cond_broadcast)(pthread_cond_t *) = 0;
static int (*p_pthread_once)(void *, void (*)(void)) = 0;
static int (*p_pthread_key_create)(unsigned *, void (*)(void *)) = 0;
static void *(*p_pthread_getspecific)(unsigned) = 0;
static int (*p_pthread_setspecific)(unsigned, const void *) = 0;

extern void *dlopen(const char *, int);
extern void *dlsym(void *, const char *);
extern long write(int, const void *, unsigned long);

/* session50f tracing: "<tag> <hex>\n" on fd 1 (the probe's run.log). */
static void ws1_dbg(const char *tag, unsigned v)
{
    char b[40];
    int n = 0, i;
    while (*tag) b[n++] = *tag++;
    for (i = 0; i < 8; ++i) {
        unsigned d = (v >> ((7 - i) * 4)) & 0xf;
        b[n++] = d < 10 ? (char)('0' + d) : (char)('a' + d - 10);
    }
    b[n++] = '\n';
    write(1, b, (unsigned long)n);
}

static void resolve_pthread(void)
{
    void *libc = dlopen("libc.so.3", 0);
    if (!libc) return;
    p_pthread_mutex_lock   = (void *)dlsym(libc, "pthread_mutex_lock");
    p_pthread_mutex_unlock = (void *)dlsym(libc, "pthread_mutex_unlock");
    p_pthread_cond_wait    = (void *)dlsym(libc, "pthread_cond_wait");
    p_pthread_cond_signal  = (void *)dlsym(libc, "pthread_cond_signal");
    p_pthread_cond_broadcast = (void *)dlsym(libc, "pthread_cond_broadcast");
    p_pthread_once         = (void *)dlsym(libc, "pthread_once");
    p_pthread_key_create   = (void *)dlsym(libc, "pthread_key_create");
    p_pthread_getspecific  = (void *)dlsym(libc, "pthread_getspecific");
    p_pthread_setspecific  = (void *)dlsym(libc, "pthread_setspecific");
}

/* _NTO_SYNC_MUTEX_FREE = 0x10, _NTO_SYNC_COND = 0x02 */
/* ---- futex emulation ---- */
#define FUTEX_TABLE_BITS 10
#define FUTEX_TABLE_SIZE (1 << FUTEX_TABLE_BITS)
#define FUTEX_ETIMEDOUT 110
#define FUTEX_EINTR     4

struct futex_entry {
    volatile int *addr;
    pthread_mutex_t m;
    pthread_cond_t  c;
    int            in_use;
};

static struct futex_entry futex_table[FUTEX_TABLE_SIZE];
static pthread_mutex_t futex_guard;

/* zero-init + lazy resolve of real QNX pthread pointers (dlopen during ctor
 * can return NULL because libc.so.3 isn't fully initialized yet). */
static void __attribute__((constructor)) futex_guard_init(void)
{
    /* QNX PTHREAD_MUTEX_INITIALIZER = { _NTO_SYNC_NONRECURSIVE, _NTO_SYNC_INITIALIZER } */
    futex_guard.__count = (int)0x80000000u;
    futex_guard.__owner = 0xffffffffu;
}

static void ensure_pthread(void)
{
    if (p_pthread_mutex_lock) return;
    resolve_pthread();
}

static unsigned futex_hash(volatile int *p)
{
    unsigned h = 2166136261u;
    unsigned char *b = (unsigned char *)&p;
    for (unsigned i = 0; i < sizeof p; ++i) { h ^= b[i]; h *= 16777619u; }
    return h & (FUTEX_TABLE_SIZE - 1);
}

int ws1_impl_futex_wait(volatile int *ftx, int value, const struct timespec_t *timeout)
{
    ensure_pthread();
    ws1_dbg("FW", (unsigned)(unsigned long)ftx);
    unsigned h = futex_hash(ftx);
    struct futex_entry *e;
    int i, found = -1;

    p_pthread_mutex_lock(&futex_guard);
    for (i = 0; i < FUTEX_TABLE_SIZE; ++i) {
        e = &futex_table[h];
        if (e->in_use && e->addr == ftx) { found = h; break; }
        if (!e->in_use && found < 0) found = h;
        h = (h + 1) & (FUTEX_TABLE_SIZE - 1);
    }
    if (found < 0) { p_pthread_mutex_unlock(&futex_guard); return FUTEX_EINTR; }
    e = &futex_table[found];
    if (!e->in_use) {
        e->in_use = 1;
        e->addr = (volatile int *)ftx;
        /* QNX init: mutex {NONRECURSIVE,-1}; cond {_NTO_SYNC_COND,-1} */
        e->m.__count = (int)0x80000000u; e->m.__owner = 0xffffffffu;
        e->c.__count = (int)0xfffffffb;  e->c.__owner = 0xffffffffu;
    }
    p_pthread_mutex_lock(&e->m);
    p_pthread_mutex_unlock(&futex_guard);

    int rc = 0;
    if (*ftx != value) {
        rc = 0;                       /* word already changed: don't sleep */
    } else {
        ws1_dbg("FS", (unsigned)(unsigned long)ftx);  /* actually sleeping */
        p_pthread_cond_wait(&e->c, &e->m);  /* timeout ignored in early smoke */
        rc = 0;
    }
    p_pthread_mutex_unlock(&e->m);
    return rc;
}

int ws1_impl_futex_wake(volatile int *ftx, int count)
{
    ensure_pthread();
    ws1_dbg("FK", (unsigned)(unsigned long)ftx);
    unsigned h = futex_hash(ftx);
    struct futex_entry *e;
    int i, found = -1, woken = 0;

    p_pthread_mutex_lock(&futex_guard);
    for (i = 0; i < FUTEX_TABLE_SIZE; ++i) {
        e = &futex_table[h];
        if (e->in_use && e->addr == ftx) { found = h; break; }
        h = (h + 1) & (FUTEX_TABLE_SIZE - 1);
    }
    if (found < 0) { p_pthread_mutex_unlock(&futex_guard); return 0; }
    e = &futex_table[found];
    p_pthread_mutex_lock(&e->m);
    p_pthread_mutex_unlock(&futex_guard);

    if (count > 1 || count == 0x7fffffff) {
        p_pthread_cond_broadcast(&e->c);
        woken = 0x7fffffff;
    } else if (count == 1) {
        p_pthread_cond_signal(&e->c);
        woken = 1;
    } else {
        woken = 0;
    }
    p_pthread_mutex_unlock(&e->m);
    return woken;
}

/* ---- abort message ---- */
static const char *shim_abort_msg = 0;
void ws1_impl_android_set_abort_message(const char *msg) { shim_abort_msg = msg; }
const char *ws1_impl_android_get_abort_message(void) { return shim_abort_msg; }

/* ---- h_errno (per-thread via QNX pthread key) ---- */
static unsigned h_errno_key = 0;
static int  h_errno_key_inited = 0;

extern int pthread_key_create(unsigned *k, void (*dtor)(void *));
extern int pthread_getspecific(unsigned k);
extern int pthread_setspecific(unsigned k, const void *v);

int *ws1_impl_get_h_errno(void)
{
    int *p;
    if (!h_errno_key_inited) {
        pthread_key_create(&h_errno_key, 0);
        h_errno_key_inited = 1;
    }
    p = (int *)(long)pthread_getspecific(h_errno_key);
    if (!p) {
        static int zero = 0;
        pthread_setspecific(h_errno_key, &zero);
        p = &zero;
    }
    return p;
}

/* ---- locale / multibyte glue ----
 * libc++'s iostream/locale static initializers call newlocale/uselocale and the
 * multibyte conversions; QNX libc.so.3 does not export them.  Provide minimal
 * "C" locale semantics so std::ios_base::Init completes. */
static void *ws1_c_locale = (void *)1;   /* non-NULL dummy locale handle */

void *ws1_impl_newlocale(int mask, const char *name, void *base)
{
    (void)mask; (void)name; (void)base;
    return ws1_c_locale;
}
void *ws1_impl_uselocale(void *loc) { (void)loc; return ws1_c_locale; }
void  ws1_impl_freelocale(void *loc) { (void)loc; }
int   ws1_impl_mbsinit(const void *ps) { return ps ? (*(const int *)ps == 0) : 1; }
int ws1_impl_register_atfork(void *prep, void *parent, void *child, void *dso)
{ (void)prep; (void)parent; (void)child; (void)dso; return 0; }

/* bionic struct rlimit is 2x32-bit; QNX's is 2x64-bit, so the QNX getrlimit
 * would write 16 bytes into an 8-byte caller object and smash the caller's
 * stack frame (session50g: Parcel::initState SIGBUS).  Parcel only wants a
 * sane gMaxFds, so return a fixed limit without calling QNX. */
int ws1_impl_getrlimit(int resource, unsigned *rlp)
{
    (void)resource;
    if (rlp) { rlp[0] = 1024; rlp[1] = 1024; }
    return 0;
}

unsigned long ws1_impl_mbrtowc(int *pwc, const char *s, unsigned long n, void *ps)
{
    (void)ps;
    if (!s) return 0;
    if (n == 0) return (unsigned long)-2;
    if ((unsigned char)*s == 0) { if (pwc) *pwc = 0; return 0; }
    if (pwc) *pwc = (unsigned char)*s;
    return 1;
}
unsigned long ws1_impl_wcrtomb(char *s, int wc, void *ps)
{
    (void)ps;
    if (!s) return 1;
    *s = (char)wc;
    return 1;
}
unsigned long ws1_impl_mbsnrtowcs(int *dst, const char **src, unsigned long nms,
                                  unsigned long len, void *ps)
{
    (void)ps;
    const char *s = *src;
    unsigned long i = 0;
    if (dst) {
        for (; i < len && i < nms && s[i]; ++i) dst[i] = (unsigned char)s[i];
        if (i < nms && s[i] == 0) { dst[i] = 0; *src = 0; return i; }
    } else {
        while (i < nms && s[i]) ++i;
    }
    *src = s + i;
    return i;
}

/* ---- bionic pthread mutex/cond over futexes ----
 * bionic's pthread_mutex_t is a 4-byte word (PTHREAD_MUTEX_INITIALIZER == 0);
 * implement lock/unlock/trylock with a 0/1 word + the futex emulation above so
 * a bionic object is never passed to QNX's 8-byte pthread_mutex_*.  bionic's
 * pthread_cond_t is a 4-byte counter signalled via __futex_wake. */
int ws1_impl_pthread_mutex_lock(unsigned *m)
{
    ws1_dbg("ML", (unsigned)(unsigned long)m);
    for (;;) {
        if (*m == 0 && __sync_bool_compare_and_swap(m, 0u, 1u))
            return 0;
        ws1_dbg("MW", (unsigned)(unsigned long)m);  /* contended: about to sleep */
        ws1_impl_futex_wait((volatile int *)m, 1, 0);
    }
}
int ws1_impl_pthread_mutex_trylock(unsigned *m)
{
    return __sync_bool_compare_and_swap(m, 0u, 1u) ? 0 : 16;  /* EBUSY */
}
int ws1_impl_pthread_mutex_unlock(unsigned *m)
{
    ws1_dbg("MU", (unsigned)(unsigned long)m);
    *m = 0;
    ws1_impl_futex_wake((volatile int *)m, 1);
    return 0;
}
int ws1_impl_pthread_mutex_init(unsigned *m, const void *a) { (void)a; *m = 0; return 0; }
int ws1_impl_pthread_mutex_destroy(unsigned *m) { *m = 0; return 0; }

/* forwarders with tracing (these are otherwise trampolines to QNX) */
int ws1_impl_pthread_once(unsigned *once, void (*init)(void))
{
    ws1_dbg("PO", (unsigned)(unsigned long)once);
    /* bionic pthread_once_t is a 4-byte word (0=uninit, 2=done); QNX's is a
     * different size, so implement it over the futex emulation. */
    if (__sync_bool_compare_and_swap(once, 0u, 1u)) {
        init();
        *once = 2;
        ws1_impl_futex_wake((volatile int *)once, 0x7fffffff);
        return 0;
    }
    while (*once != 2)
        ws1_impl_futex_wait((volatile int *)once, 1, 0);
    return 0;
}
int ws1_impl_pthread_key_create(unsigned *k, void (*dtor)(void *))
{
    ws1_dbg("KC", (unsigned)(unsigned long)k);
    ensure_pthread();
    return p_pthread_key_create(k, dtor);
}
void *ws1_impl_pthread_getspecific(unsigned k)
{
    ws1_dbg("KG", k);
    ensure_pthread();
    return p_pthread_getspecific(k);
}
int ws1_impl_pthread_setspecific(unsigned k, const void *v)
{
    ws1_dbg("KS", k);
    ensure_pthread();
    return p_pthread_setspecific(k, v);
}

int ws1_impl_pthread_cond_wait(unsigned *c, unsigned *m)
{
    unsigned seq = *c;
    ws1_impl_pthread_mutex_unlock(m);
    ws1_impl_futex_wait((volatile int *)c, (int)seq, 0);
    ws1_impl_pthread_mutex_lock(m);
    return 0;
}
int ws1_impl_pthread_cond_timedwait(unsigned *c, unsigned *m, const void *ts)
{
    (void)ts;   /* timeout not honoured yet */
    return ws1_impl_pthread_cond_wait(c, m);
}
int ws1_impl_pthread_cond_signal(unsigned *c)
{
    __sync_fetch_and_add(c, 1u);
    ws1_impl_futex_wake((volatile int *)c, 1);
    return 0;
}
int ws1_impl_pthread_cond_broadcast(unsigned *c)
{
    __sync_fetch_and_add(c, 1u);
    ws1_impl_futex_wake((volatile int *)c, 0x7fffffff);
    return 0;
}
int ws1_impl_pthread_cond_init(unsigned *c, const void *a) { (void)a; *c = 0; return 0; }
int ws1_impl_pthread_cond_destroy(unsigned *c) { *c = 0; return 0; }

/* ---- registration table: bionic name -> real impl ---- */
struct ws1_glue_impl { const char *name; void *fn; };
extern struct ws1_glue_impl ws1_prop_impls[];
extern struct ws1_glue_impl ws1_tls_impls[];
extern struct ws1_glue_impl ws1_malloc_impls[];
struct ws1_glue_impl __attribute__((visibility("hidden"))) ws1_glue_impls[] = {
    { "__futex_wait",               (void *)ws1_impl_futex_wait },
    { "__futex_wake",               (void *)ws1_impl_futex_wake },
    { "android_set_abort_message",  (void *)ws1_impl_android_set_abort_message },
    { "__get_h_errno",              (void *)ws1_impl_get_h_errno },
    { "newlocale",                  (void *)ws1_impl_newlocale },
    { "uselocale",                  (void *)ws1_impl_uselocale },
    { "freelocale",                 (void *)ws1_impl_freelocale },
    { "mbsinit",                    (void *)ws1_impl_mbsinit },
    { "mbrtowc",                    (void *)ws1_impl_mbrtowc },
    { "wcrtomb",                    (void *)ws1_impl_wcrtomb },
    { "mbsnrtowcs",                 (void *)ws1_impl_mbsnrtowcs },
    { "__register_atfork",          (void *)ws1_impl_register_atfork },
    { "getrlimit",                  (void *)ws1_impl_getrlimit },
    { "pthread_once",               (void *)ws1_impl_pthread_once },
    { "pthread_key_create",         (void *)ws1_impl_pthread_key_create },
    { "pthread_getspecific",        (void *)ws1_impl_pthread_getspecific },
    { "pthread_setspecific",        (void *)ws1_impl_pthread_setspecific },
    { "pthread_mutex_lock",         (void *)ws1_impl_pthread_mutex_lock },
    { "pthread_mutex_trylock",      (void *)ws1_impl_pthread_mutex_trylock },
    { "pthread_mutex_unlock",       (void *)ws1_impl_pthread_mutex_unlock },
    { "pthread_mutex_init",         (void *)ws1_impl_pthread_mutex_init },
    { "pthread_mutex_destroy",      (void *)ws1_impl_pthread_mutex_destroy },
    { "pthread_cond_wait",          (void *)ws1_impl_pthread_cond_wait },
    { "pthread_cond_timedwait",     (void *)ws1_impl_pthread_cond_timedwait },
    { "pthread_cond_signal",        (void *)ws1_impl_pthread_cond_signal },
    { "pthread_cond_broadcast",     (void *)ws1_impl_pthread_cond_broadcast },
    { "pthread_cond_init",          (void *)ws1_impl_pthread_cond_init },
    { "pthread_cond_destroy",       (void *)ws1_impl_pthread_cond_destroy },
    { 0, 0 },
};

/* local strcmp (NOT the shim trampoline — this runs during the resolver ctor,
 * before slots are filled, so calling strcmp would recurse into the resolver) */
static int glue_strcmp(const char *a, const char *b)
{
    while (*a && *a == *b) { ++a; ++b; }
    return (unsigned char)*a - (unsigned char)*b;
}

void *__attribute__((visibility("hidden"))) ws1_lookup_glue(const char *name)
{
    unsigned i;
    if (!name || !name[0]) return 0;
    for (i = 0; ws1_glue_impls[i].name; ++i)
        if (glue_strcmp(ws1_glue_impls[i].name, name) == 0)
            return ws1_glue_impls[i].fn;
    for (i = 0; ws1_prop_impls[i].name; ++i)
        if (glue_strcmp(ws1_prop_impls[i].name, name) == 0)
            return ws1_prop_impls[i].fn;
    for (i = 0; ws1_tls_impls[i].name; ++i)
        if (glue_strcmp(ws1_tls_impls[i].name, name) == 0)
            return ws1_tls_impls[i].fn;
    for (i = 0; ws1_malloc_impls[i].name; ++i)
        if (glue_strcmp(ws1_malloc_impls[i].name, name) == 0)
            return ws1_malloc_impls[i].fn;
    return 0;
}
