/* ws1/prop_impl.c — bionic system_property_* glue (in-process property store).
 *
 * Implements the A11 bionic property ABI (sys/_system_properties.h) on top of a
 * simple fixed-size in-memory table.  A11's libc normally uses a shared mmap'd
 * prop_area across processes; for the QNX shim we keep a per-process store.
 *
 * Serial encoding (matches bionic): bits 0..23 = change counter, bits 24..30 =
 * value length, bit 31 = long-property flag (unused, always 0).
 */

#define PROP_NAME_MAX  32
#define PROP_VALUE_MAX 92
#define PROP_MAX_ENTRIES 256

typedef unsigned uint32_t;

struct prop_info {
    uint32_t serial;
    char     value[PROP_VALUE_MAX];
    char     name[PROP_NAME_MAX];
};

static struct prop_info g_props[PROP_MAX_ENTRIES];
static unsigned g_count = 0;
static uint32_t g_serial = 1;      /* global change counter (area serial) */

/* --- string helpers (hand-rolled, no libc deps to avoid shadowing) --- */
static unsigned p_strlen(const char *s)
{
    unsigned n = 0;
    if (!s) return 0;
    while (s[n]) ++n;
    return n;
}
static int p_strcmp(const char *a, const char *b)
{
    while (*a && *a == *b) { ++a; ++b; }
    return (unsigned char)*a - (unsigned char)*b;
}
static void p_memcpy(char *d, const char *s, unsigned n)
{
    while (n--) *d++ = *s++;
}

/* ---- find ---- */
extern int write(int, const void *, unsigned long);
static struct prop_info *prop_find(const char *name)
{
    unsigned i;
    for (i = 0; i < g_count; ++i)
        if (p_strcmp(g_props[i].name, name) == 0)
            return &g_props[i];
    return 0;
}

/* ---- public API (ws1_impl_* bodies, mapped by ws1_prop_impls) ---- */

void *ws1_impl___system_property_area_init(void)
{
    return (void *)&g_serial;
}

uint32_t ws1_impl___system_property_area_serial(const void *area)
{
    (void)area;
    return g_serial;
}

const struct prop_info *ws1_impl___system_property_find(const char *name)
{
    return prop_find(name);
}

int ws1_impl___system_property_get(const char *name, char *value)
{
    struct prop_info *pi = prop_find(name);
    unsigned len;
    if (!pi) return -1;
    len = (pi->serial >> 24) & 0x7f;
    p_memcpy(value, pi->value, len);
    value[len] = 0;
    return (int)len;
}

int ws1_impl___system_property_read(const struct prop_info *pi, char *name, char *value)
{
    unsigned len;
    if (!pi) return -1;
    p_memcpy(name, pi->name, p_strlen(pi->name) + 1);
    len = (pi->serial >> 24) & 0x7f;
    p_memcpy(value, pi->value, len);
    value[len] = 0;
    return (int)len;
}

uint32_t ws1_impl___system_property_serial(const struct prop_info *pi)
{
    if (!pi) return 0;
    return pi->serial & 0x00ffffff;
}

int ws1_impl___system_property_set(const char *name, const char *value)
{
    struct prop_info *pi = prop_find(name);
    unsigned len = p_strlen(value);
    if (len >= PROP_VALUE_MAX) len = PROP_VALUE_MAX - 1;
    if (pi) {
        p_memcpy(pi->value, value, len);
        pi->value[len] = 0;
        pi->serial = ((pi->serial + 1) & 0x00ffffff) | (len << 24);
        ++g_serial;
        return 0;
    }
    if (g_count >= PROP_MAX_ENTRIES) return -1;
    pi = &g_props[g_count++];
    unsigned nlen = p_strlen(name);
    if (nlen >= PROP_NAME_MAX) nlen = PROP_NAME_MAX - 1;
    p_memcpy(pi->name, name, nlen);
    pi->name[nlen] = 0;
    p_memcpy(pi->value, value, len);
    pi->value[len] = 0;
    pi->serial = (len << 24) | 1;
    ++g_serial;
    return 0;
}

int ws1_impl___system_property_add(const char *name, unsigned namelen,
                                   const char *value, unsigned valuelen)
{
    if (g_count >= PROP_MAX_ENTRIES) return -1;
    if (namelen >= PROP_NAME_MAX) namelen = PROP_NAME_MAX - 1;
    if (valuelen >= PROP_VALUE_MAX) valuelen = PROP_VALUE_MAX - 1;
    struct prop_info *pi = &g_props[g_count++];
    p_memcpy(pi->name, name, namelen);
    pi->name[namelen] = 0;
    p_memcpy(pi->value, value, valuelen);
    pi->value[valuelen] = 0;
    pi->serial = (valuelen << 24) | 1;
    ++g_serial;
    return 0;
}

int ws1_impl___system_property_update(struct prop_info *pi,
                                      const char *value, unsigned valuelen)
{
    if (!pi) return -1;
    if (valuelen >= PROP_VALUE_MAX) valuelen = PROP_VALUE_MAX - 1;
    p_memcpy(pi->value, value, valuelen);
    pi->value[valuelen] = 0;
    pi->serial = ((pi->serial + 1) & 0x00ffffff) | (valuelen << 24);
    ++g_serial;
    return 0;
}

int ws1_impl___system_property_foreach(
    void (*callback)(const struct prop_info *pi, void *cookie), void *cookie)
{
    unsigned i;
    for (i = 0; i < g_count; ++i)
        callback(&g_props[i], cookie);
    return 0;
}

int ws1_impl___system_property_read_callback(const struct prop_info *pi,
    void (*callback)(void *cookie, const char *name, const char *value, uint32_t serial),
    void *cookie)
{
    if (!pi || !callback) return -1;
    callback(cookie, pi->name, pi->value, pi->serial & 0x00ffffff);
    return 0;
}

int ws1_impl___system_property_set_filename(const char *filename)
{
    (void)filename;
    return 0;
}

extern void sched_yield(void);
uint32_t ws1_impl___system_property_wait_any(uint32_t old_serial)
{
    while (g_serial == old_serial) sched_yield();
    return g_serial;
}

/* ---- registration ---- */
struct ws1_glue_impl { const char *name; void *fn; };

struct ws1_glue_impl __attribute__((visibility("hidden"))) ws1_prop_impls[] = {
    { "__system_property_area_init",        (void *)ws1_impl___system_property_area_init },
    { "__system_property_area_serial",      (void *)ws1_impl___system_property_area_serial },
    { "__system_property_find",             (void *)ws1_impl___system_property_find },
    { "__system_property_get",              (void *)ws1_impl___system_property_get },
    { "__system_property_read",             (void *)ws1_impl___system_property_read },
    { "__system_property_set",              (void *)ws1_impl___system_property_set },
    { "__system_property_add",              (void *)ws1_impl___system_property_add },
    { "__system_property_update",           (void *)ws1_impl___system_property_update },
    { "__system_property_serial",           (void *)ws1_impl___system_property_serial },
    { "__system_property_foreach",          (void *)ws1_impl___system_property_foreach },
    { "__system_property_read_callback",    (void *)ws1_impl___system_property_read_callback },
    { "__system_property_set_filename",     (void *)ws1_impl___system_property_set_filename },
    { "__system_property_wait_any",         (void *)ws1_impl___system_property_wait_any },
    { 0, 0 },
};
