/* ws1/extra_impls.c — bionic symbols referenced by the NDK libc++/libdl that
 * have no QNX counterpart.  Exported directly (hide_slots.map exports "*").
 *
 *   __emutls_get_address()  — clang's emulated-TLS accessor (Android ABI:
 *       struct __emutls_control { size_t size; size_t align;
 *           union { uintptr_t index; void *address; } object; void *value; })
 *   dl_unwind_find_exidx()  — bionic ARM unwinder exidx lookup (stub: no
 *       exidx tables are returned yet; revisit when C++ exceptions run)
 */

typedef unsigned long size_t;
typedef unsigned long uintptr_t;

extern void *malloc(size_t);
extern void *calloc(size_t, size_t);
extern void free(void *);

extern int pthread_key_create(unsigned *k, void (*dtor)(void *));
extern void *pthread_getspecific(unsigned k);
extern int pthread_setspecific(unsigned k, const void *v);

/* ---- emulated TLS ------------------------------------------------------ */

struct __emutls_control {
    size_t size;
    size_t align;
    union {
        uintptr_t index;
        void *address;
    } object;
    void *value;
};

struct emutls_array {
    unsigned size;
    void *data[1];
};

static unsigned emutls_key;
static int emutls_key_inited;
static unsigned emutls_next;
static int emutls_lock;

static void emutls_copy(void *dst, const void *src, size_t n)
{
    unsigned char *d = (unsigned char *)dst;
    const unsigned char *s = (const unsigned char *)src;
    while (n--) *d++ = *s++;
}

void *__emutls_get_address(struct __emutls_control *control)
{
    struct emutls_array *arr;
    unsigned idx, nsz, i;
    void *p;

    if (!control) return 0;

    if (!control->object.index) {
        while (__sync_lock_test_and_set(&emutls_lock, 1)) ;
        if (!control->object.index)
            control->object.index = ++emutls_next;
        __sync_lock_release(&emutls_lock);
    }
    idx = (unsigned)control->object.index;

    if (!emutls_key_inited) {
        while (__sync_lock_test_and_set(&emutls_lock, 1)) ;
        if (!emutls_key_inited) {
            if (pthread_key_create(&emutls_key, 0) == 0)
                emutls_key_inited = 1;
        }
        __sync_lock_release(&emutls_lock);
    }
    if (!emutls_key_inited) return 0;

    arr = (struct emutls_array *)pthread_getspecific(emutls_key);
    if (!arr || arr->size < idx) {
        struct emutls_array *na;
        nsz = idx > 8 ? idx : 8;
        na = (struct emutls_array *)calloc(
            1, sizeof(struct emutls_array) + nsz * sizeof(void *));
        if (!na) return 0;
        if (arr) {
            for (i = 0; i < arr->size && i < nsz; ++i)
                na->data[i] = arr->data[i];
            free(arr);
        }
        na->size = nsz;
        arr = na;
        pthread_setspecific(emutls_key, arr);
    }

    p = arr->data[idx - 1];
    if (!p) {
        if (control->align > 16) {
            size_t extra = control->align - 1;
            void *raw = malloc(control->size + extra + sizeof(void *));
            uintptr_t aligned;
            if (!raw) return 0;
            aligned = ((uintptr_t)raw + sizeof(void *) + extra)
                      & ~(uintptr_t)(control->align - 1);
            ((void **)aligned)[-1] = raw;
            p = (void *)aligned;
        } else {
            p = malloc(control->size);
            if (!p) return 0;
        }
        if (control->value) emutls_copy(p, control->value, control->size);
        arr->data[idx - 1] = p;
    }
    return p;
}

/* ---- bionic ARM unwinder exidx lookup ---------------------------------- */

unsigned long *dl_unwind_find_exidx(unsigned long pc, int *count)
{
    (void)pc;
    if (count) *count = 0;
    return 0;
}
