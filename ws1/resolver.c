/* ws1/resolver.c — pre-fill slots in constructor, resolve via QNX libc dlsym.
 *
 * The REAL QNX dlopen/dlsym live in libc.so.3 and are the only definitions in
 * scope: the shim deliberately does NOT export dlopen/dlsym trampolines (see
 * gen_tramps.py).  That guarantees the references here bind to libc.so.3 and
 * never route back through an unfilled shim slot (which would bx 0).
 *
 * Slots may also be filled lazily from ws1_resolver.S via ws1_resolve_slot(),
 * so a call arriving before the constructor still resolves correctly.
 */
#include "resolver.h"

extern void *dlopen(const char *file, int mode);
extern void *dlsym(void *handle, const char *name);

#ifdef WS1_TRACE
extern void ws1_dbg_note(const char *);
extern void ws1_dbg_note2(const char *, void *);
extern void ws1_dbg_arm_now(void);
#endif

void __attribute__((visibility("hidden"))) __ws1_unimplemented(void)
{
    for (;;)
        ;
}

static void *volatile ws1_libc_handle;
static int ws1_in_ctor;
static int ws1_resolving;

/* Report symbols that fall through to the spin stub, but only when a running
 * program actually calls them (not while the ctor pre-fills every slot). */
static void ws1_diag_miss(const char *name)
{
    static long (*w)(int, const void *, unsigned long);
    static int in_diag;
    if (ws1_in_ctor || in_diag)
        return;
    in_diag = 1;
    if (!w) {
        void *h = dlopen("libc.so.3", 0);
        if (h) w = (long (*)(int, const void *, unsigned long))dlsym(h, "write");
    }
    if (w) {
        unsigned n = 0;
        while (name && name[n]) n++;
        w(2, "WS1MISS: ", 9);
        if (name && n) w(2, name, n);
        w(2, "\n", 1);
    }
    in_diag = 0;
}

static void *resolve_symbol_inner(const char *name, int kind)
{
    void *impl = ws1_lookup_glue(name);
    if (impl)
        return impl;
    if (kind == WS1_GLUE || name == 0 || name[0] == 0) {
        ws1_diag_miss(name);
        return (void *)__ws1_unimplemented;
    }
    void *libc = ws1_libc_handle;
    if (!libc) {
        void *p;
        if (ws1_resolving) {
            /* Re-entrant resolve: QNX dlopen() internally calls libc functions
             * (e.g. getenv) that are interposed by our trampolines.  Calling
             * dlopen again here deadlocks/crashes the loader lock, so resolve
             * with RTLD_NEXT to skip our own definition and find QNX libc's. */
            p = dlsym((void *)-3 /* RTLD_NEXT */, name);
            if (p) return p;
            p = dlsym((void *)-2 /* RTLD_DEFAULT */, name);
            return p ? p : (void *)__ws1_unimplemented;
        }
        ws1_resolving = 1;
        libc = dlopen("libc.so.3", 0);
        ws1_libc_handle = libc;
        ws1_resolving = 0;
    }
    if (libc) {
        void *p = dlsym(libc, name);
        if (p) return p;
    }
    ws1_diag_miss(name);
    return (void *)__ws1_unimplemented;
}

static void *resolve_symbol(const char *name, int kind)
{
    void *r;
#ifdef WS1_TRACE
    if (!ws1_in_ctor) {
        ws1_dbg_arm_now();
        ws1_dbg_note(name);
    }
#endif
    r = resolve_symbol_inner(name, kind);
#ifdef WS1_TRACE
    if (!ws1_in_ctor)
        ws1_dbg_note2(name, r);
#endif
    return r;
}

void * __attribute__((visibility("hidden")))
ws1_resolve_slot(struct ws1_slot *s)
{
#ifdef WS1_TRACE
    ws1_dbg_arm_now();
#endif
    if (s && s->ptr) {
        if (!*s->ptr)
            *s->ptr = resolve_symbol(s->name, s->kind);
        return *s->ptr;
    }
    return (void *)__ws1_unimplemented;
}

#ifdef WS1_TRACE
static void ws1_trace(unsigned i, unsigned sp)
{
    static long (*w)(int, const void *, unsigned long);
    static const char hx[] = "0123456789abcdef";
    char b[24];
    int k = 0, j;
    if (!w) {
        void *h = dlopen("libc.so.3", 0);
        if (h) w = (long (*)(int, const void *, unsigned long))dlsym(h, "write");
    }
    if (!w)
        return;
    b[k++] = '[';
    for (j = 7; j >= 0; --j) b[k++] = hx[(i >> (j * 4)) & 0xf];
    b[k++] = ' ';
    for (j = 7; j >= 0; --j) b[k++] = hx[(sp >> (j * 4)) & 0xf];
    b[k++] = ']'; b[k++] = '\n';
    w(1, b, k);
}
#endif

__attribute__((constructor(200)))
static void ws1_onload(void)
{
    unsigned i;
    ws1_in_ctor = 1;
#ifdef WS1_TRACE
    {
        register unsigned sp __asm__("sp");
        ws1_trace(ws1_nslots, sp);
    }
    for (i = 0; i < ws1_nslots; ++i) {
        if ((i & 31) == 0) {
            register unsigned sp __asm__("sp");
            ws1_trace(i, sp);
        }
        ws1_resolve_slot(&ws1_slots[i]);
    }
#else
    for (i = 0; i < ws1_nslots; ++i)
        ws1_resolve_slot(&ws1_slots[i]);
#endif
    ws1_in_ctor = 0;
}
