/* ws1/resolver.c — slot resolution via the link-time binding table.
 *
 * Every alias/overlap slot has a `direct` pointer into libqnxbind.so's
 * qnxb_ptrs[] table: entries are direct references to QNX libc.so.3 symbols,
 * relocated by the loader at load time.  Glue slots resolve to the shim's own
 * C implementations via ws1_lookup_glue().  No dlopen/dlsym is used at
 * resolution time, so a trampoline call arriving before the shim's constructor
 * (or before the loader's init phase completes) cannot re-enter the runtime
 * linker (that was the session74 pre-ctor crash).
 */
#include "resolver.h"

#ifdef WS1_TRACE
extern void *dlopen(const char *file, int mode);
extern void *dlsym(void *handle, const char *name);
extern void ws1_dbg_note(const char *);
extern void ws1_dbg_note2(const char *, void *);
extern void ws1_dbg_arm_now(void);
#endif

void __attribute__((visibility("hidden"))) __ws1_unimplemented(void)
{
#ifdef WS1_SPINMARK
    extern void *qnxb_ptrs[];
    static int marked;
    if (!marked) {
        long (*w)(int, const void *, unsigned long) =
            (long (*)(int, const void *, unsigned long))qnxb_ptrs[667];
        marked = 1;
        if (w) w(2, "WS1SPIN\n", 8);
    }
#endif
    for (;;)
        ;
}

static int ws1_in_ctor;

/* Symbols with no QNX binding and no glue impl land on the spin stub.  Keep
 * this diagnostic loader-call-free (it can run pre-ctor). */
static void ws1_diag_miss(const char *name)
{
    (void)name;
}

static void *resolve_symbol(struct ws1_slot *s)
{
    void *impl;
#ifdef WS1_TRACE
    if (!ws1_in_ctor) {
        ws1_dbg_arm_now();
        ws1_dbg_note(s->name);
    }
#endif
    impl = ws1_lookup_glue(s->name);
    if (!impl && s->direct)
        impl = *s->direct;
    if (!impl) {
        ws1_diag_miss(s->name);
        impl = (void *)__ws1_unimplemented;
    }
#ifdef WS1_TRACE
    if (!ws1_in_ctor)
        ws1_dbg_note2(s->name, impl);
#endif
    return impl;
}

void * __attribute__((visibility("hidden")))
ws1_resolve_slot(struct ws1_slot *s)
{
#ifdef WS1_TRACE
    ws1_dbg_arm_now();
#endif
    if (s && s->ptr) {
        if (!*s->ptr)
            *s->ptr = resolve_symbol(s);
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
