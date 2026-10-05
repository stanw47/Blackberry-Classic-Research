/* Minimal test with debug output */
typedef unsigned long size_t;
typedef void *dlhandle;

extern size_t strlen(const char *);
extern int write(int, const void *, size_t);
extern dlhandle dlopen(const char *, int);
extern void *dlsym(dlhandle, const char *);
extern int dlclose(dlhandle);
extern void exit(int);

static void says(const char *s) { write(1, s, strlen(s)); }

int main(void) {
    static const char hello[] = "WS1 smoke: start\n";
    write(1, hello, sizeof(hello) - 1);
    says("Before dlopen\n");
    dlhandle h = dlopen("libz.so", 1);
    says(h ? "dlopen ok\n" : "dlopen FAILED\n");
    if (h) {
        char *(*p)(void) = (char *(*)(void))dlsym(h, "zlibVersion");
        char *v = p ? p() : 0;
        says("zlibVersion=");
        says(v ? v : "(null)");
        says("\n");
        dlclose(h);
    }
    says("WS1 smoke: done\n");
    exit(0);
}
