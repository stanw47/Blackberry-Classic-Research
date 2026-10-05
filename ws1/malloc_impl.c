/* ws1/malloc_impl.c — bionic malloc-family glue.
 *
 * QNX libc.so.3 already provides malloc/free/calloc/realloc/memalign/
 * posix_memalign (they are in the ALIAS list, resolved by dlsym).  This file
 * implements the bionic-SPECIFIC surface that has no QNX equivalent:
 *   - dlmalloc* aliases (bionic's dlmalloc entry points) -> forward to QNX malloc
 *   - malloc_usable_size / dlmalloc_usable_size -> QNX _msize
 *   - __malloc_hook / __free_hook / __realloc_hook / __memalign_hook (NULL globals)
 *   - reallocarray (overflow-checked realloc)
 *   - sbrk / brk / __bionic_brk -> QNX brk/_curbrk
 */

typedef unsigned long size_t;
typedef unsigned long uintptr_t;

/* QNX malloc-family (resolved at runtime; declared extern for linking). */
extern void *malloc(size_t n);
extern void *calloc(size_t n, size_t sz);
extern void *realloc(void *p, size_t n);
extern void free(void *p);
extern void *memalign(size_t align, size_t n);
extern int posix_memalign(void **memptr, size_t align, size_t n);

/* QNX _msize (usable size of an allocation). */
extern size_t _msize(void *p);

/* QNX brk/sbrk support. */
extern void *_curbrk;         /* QNX current break symbol */
extern void *__brk(void *addr);

/* ---- dlmalloc entry points -> forward to QNX malloc ---- */
void *ws1_impl_dlmalloc(size_t n) { return malloc(n); }
void ws1_impl_dlfree(void *p) { free(p); }
void *ws1_impl_dlcalloc(size_t n, size_t sz) { return calloc(n, sz); }
void *ws1_impl_dlrealloc(void *p, size_t n) { return realloc(p, n); }
void *ws1_impl_dlmemalign(size_t a, size_t n) { return memalign(a, n); }

/* ---- usable size ---- */
size_t ws1_impl_malloc_usable_size(void *p) { return _msize(p); }
size_t ws1_impl_dlmalloc_usable_size(void *p) { return _msize(p); }

/* ---- dlmalloc introspection (stubs returning 0/empty) ---- */
size_t ws1_impl_dlmalloc_footprint(void) { return 0; }
size_t ws1_impl_dlmalloc_max_footprint(void) { return 0; }
size_t ws1_impl_dlmalloc_footprint_limit(void) { return 0; }
size_t ws1_impl_dlmalloc_set_footprint_limit(size_t v) { return v; }
void ws1_impl_dlmalloc_stats(void) { }
void ws1_impl_dlmalloc_inspect_all(void (*h)(void*, void*, size_t, void*), void *arg)
{
    (void)h; (void)arg;
}
int ws1_impl_dlmalloc_trim(size_t pad) { (void)pad; return 0; }

/* ---- reallocarray (overflow check + realloc) ---- */
void *ws1_impl_reallocarray(void *p, size_t n, size_t sz)
{
    if (sz && n > (size_t)-1 / sz) return 0;   /* overflow */
    return realloc(p, n * sz);
}

/* ---- brk / sbrk ---- */
void *ws1_impl_brk(void *addr)
{
    /* QNX: __brk sets the break; returns new break or -1 on error. */
    return __brk(addr);
}

void *ws1_impl_sbrk(long incr)
{
    void *old = _curbrk;
    void *nw = (void *)((char *)old + incr);
    if (__brk(nw) == (void *)-1) return (void *)-1;
    return old;
}

/* ---- malloc leak info / iterate / backtrace (stubs) ---- */
size_t ws1_impl_malloc_info(int fd) { (void)fd; return 0; }
void ws1_impl_malloc_enable(void) { }
void ws1_impl_malloc_disable(void) { }
void ws1_impl_malloc_iterate(void (*cb)(uintptr_t, size_t, void*), void *arg)
{
    (void)cb; (void)arg;
}
void ws1_impl_malloc_backtrace(void *p) { (void)p; }


/* ---- registration ---- */
struct ws1_glue_impl { const char *name; void *fn; };

struct ws1_glue_impl ws1_malloc_impls[] = {
    { "dlmalloc",                 (void *)ws1_impl_dlmalloc },
    { "dlfree",                   (void *)ws1_impl_dlfree },
    { "dlcalloc",                 (void *)ws1_impl_dlcalloc },
    { "dlrealloc",                (void *)ws1_impl_dlrealloc },
    { "dlmemalign",               (void *)ws1_impl_dlmemalign },
    { "malloc_usable_size",       (void *)ws1_impl_malloc_usable_size },
    { "dlmalloc_usable_size",     (void *)ws1_impl_dlmalloc_usable_size },
    { "dlmalloc_footprint",       (void *)ws1_impl_dlmalloc_footprint },
    { "dlmalloc_max_footprint",   (void *)ws1_impl_dlmalloc_max_footprint },
    { "dlmalloc_footprint_limit", (void *)ws1_impl_dlmalloc_footprint_limit },
    { "dlmalloc_set_footprint_limit", (void *)ws1_impl_dlmalloc_set_footprint_limit },
    { "dlmalloc_stats",           (void *)ws1_impl_dlmalloc_stats },
    { "dlmalloc_inspect_all",     (void *)ws1_impl_dlmalloc_inspect_all },
    { "dlmalloc_trim",            (void *)ws1_impl_dlmalloc_trim },
    { "reallocarray",             (void *)ws1_impl_reallocarray },
    { "brk",                      (void *)ws1_impl_brk },
    { "sbrk",                     (void *)ws1_impl_sbrk },
    { "malloc_info",              (void *)ws1_impl_malloc_info },
    { "malloc_enable",            (void *)ws1_impl_malloc_enable },
    { "malloc_disable",           (void *)ws1_impl_malloc_disable },
    { "malloc_iterate",           (void *)ws1_impl_malloc_iterate },
    { "malloc_backtrace",         (void *)ws1_impl_malloc_backtrace },
    { 0, 0 },
};
