/* ws1/test_futex.c — exercise the shim's __futex_wait/__futex_wake glue
 * and the abort-message + h_errno glue, then exit. Proves WS1b glue runs.
 */
typedef unsigned long size_t;
typedef long ssize_t;

extern int write(int, const void *, size_t);
extern size_t strlen(const char *);
extern void _exit(int);

extern int __futex_wait(volatile int *, int, const void *);
extern int __futex_wake(volatile int *, int);
extern void android_set_abort_message(const char *);
extern int *__get_h_errno(void);

static void say(const char *s) { write(1, s, strlen(s)); }

static void sayn(const char *s, int n)
{
    char b[16]; int i = 0, neg = 0;
    say(s);
    if (n < 0) { neg = 1; n = -n; }
    do { b[i++] = '0' + (n % 10); n /= 10; } while (n);
    if (neg) b[i++] = '-';
    while (i > 0) { char c = b[--i]; write(1, &c, 1); }
    write(1, "\n", 1);
}

static volatile int word = 0;

int main(void)
{
    say("futex test: set word=1\n");
    word = 1;
    int w = __futex_wake(&word, 1);
    sayn("wake(no waiters) rc=", w);
    int r = __futex_wait(&word, 0, (void *)0);
    sayn("wait(value mismatch) rc=", r);
    android_set_abort_message("hello-abort");
    say("abort msg set ok\n");
    int *he = __get_h_errno();
    *he = 42;
    he = __get_h_errno();
    sayn("h_errno=", *he);
    say("GLUE OK\n");
    _exit(0);
    return 0;
}
