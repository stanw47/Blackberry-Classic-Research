/* ws1/glue_core.c — minimal with write() debug */
typedef unsigned long size_t;
typedef long ssize_t;

typedef struct __sFILE22 FILE;

extern int write(int, const void *, size_t);

/* Simple errno */
static int shim_errno = 0;
int *__errno(void) { return &shim_errno; }

/* ---- Debug write at load time ---- */
static void __attribute__((constructor)) shim_debug_init(void)
{
    static const char msg[] = "[SHIM] init\n";
    write(1, msg, sizeof(msg) - 1);
}

/* ---- small helpers ---- */
void *mempcpy(void *dst, const void *src, size_t n)
{
    const char *s = (const char *)src;
    char *d = (char *)dst;
    while (n--) *d++ = *s++;
    return d;
}

size_t __strlen_chk(const char *s, size_t maxlen)
{
    size_t len = 0;
    while (s[len] && len < maxlen) len++;
    return len;
}

/* ---- core libc glue QNX libc.so.3 does not provide (glue_core_impl.txt) ----
 * Implemented here (not as trampolines) so the shim exports them; otherwise the
 * QNX loader reports "Unresolved symbol" for A11 libs that need them. */
void *memrchr(const void *s, int c, size_t n)
{
    const unsigned char *p = (const unsigned char *)s + n;
    while (n--) { if (*--p == (unsigned char)c) return (void *)p; }
    return 0;
}

char *stpcpy(char *dst, const char *src)
{
    while ((*dst = *src) != 0) { ++dst; ++src; }
    return dst;
}

char *stpncpy(char *dst, const char *src, size_t n)
{
    size_t i = 0;
    while (i < n && src[i] != 0) { dst[i] = src[i]; ++i; }
    if (i == n) return dst + n;
    {
        char *ret = dst + i;
        while (i < n) dst[i++] = 0;
        return ret;
    }
}

long readlinkat(int dirfd, const char *path, char *buf, size_t bufsiz)
{
    extern long readlink(const char *, char *, size_t);
    (void)dirfd;
    return readlink(path, buf, bufsiz);
}

/* bionic fortify __*_chk wrappers: forward to the base call (ignore buflen). */
void *__memchr_chk(const void *s, int c, size_t n, size_t buflen)
{
    extern void *memchr(const void *, int, size_t);
    (void)buflen; return memchr(s, c, n);
}
char *__strchr_chk(const char *s, int c, size_t n)
{
    size_t i;
    for (i = 0; i < n; ++i) { if (s[i] == (char)c) return (char *)(s + i); if (!s[i]) break; }
    return 0;
}
char *__strrchr_chk(const char *s, int c, size_t n)
{
    char *last = 0; size_t i;
    for (i = 0; i < n; ++i) { if (s[i] == (char)c) last = (char *)(s + i); if (!s[i]) break; }
    return last;
}
void *__mempcpy_chk(void *d, const void *s, size_t n, size_t buflen)
{
    (void)buflen; return mempcpy(d, s, n);
}
char *__stpcpy_chk(char *d, const char *s, size_t buflen)
{
    (void)buflen; return stpcpy(d, s);
}
char *__stpncpy_chk(char *d, const char *s, size_t n, size_t buflen)
{
    (void)buflen; return stpncpy(d, s, n);
}
