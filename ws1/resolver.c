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

void __attribute__((visibility("hidden"))) __ws1_unimplemented(void)
{
    for (;;)
        ;
}

static void *volatile ws1_libc_handle;
static int ws1_in_ctor;

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

static void *resolve_symbol(const char *name, int kind)
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
        libc = dlopen("libc.so.3", 0);
        ws1_libc_handle = libc;
    }
    if (libc) {
        void *p = dlsym(libc, name);
        if (p) return p;
    }
    ws1_diag_miss(name);
    return (void *)__ws1_unimplemented;
}

void * __attribute__((visibility("hidden")))
ws1_resolve_slot(struct ws1_slot *s)
{
    if (s && s->ptr) {
        if (!*s->ptr)
            *s->ptr = resolve_symbol(s->name, s->kind);
        return *s->ptr;
    }
    return (void *)__ws1_unimplemented;
}

__attribute__((constructor(200)))
static void ws1_onload(void)
{
    unsigned i;
    ws1_in_ctor = 1;
    for (i = 0; i < ws1_nslots; ++i)
        ws1_resolve_slot(&ws1_slots[i]);
    ws1_in_ctor = 0;
}
