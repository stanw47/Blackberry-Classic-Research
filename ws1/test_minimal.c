/* Minimal test - just write+exit via shim */
typedef unsigned long size_t;

extern size_t strlen(const char *);
extern int write(int, const void *, size_t);
extern void _exit(int);

static void says(const char *s) {
    write(1, s, strlen(s));
}

int main(void) {
    static const char hello[] = "Minimal test\n";
    write(1, hello, sizeof(hello) - 1);
    says("write() works\n");
    _exit(0);
}
