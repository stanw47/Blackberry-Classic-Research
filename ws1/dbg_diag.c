/* ws1/dbg_diag.c — debug-only shim diagnostics (build with WS1_TRACE).
 *
 * ctor(50) runs before ws1_onload (ctor(200)): arms a SIGSEGV/SIGBUS/SIGILL
 * handler that dumps the QNX ucontext registers and raw stack via the real
 * QNX libc write(), so a fault during load-time slot pre-fill is visible. */
typedef unsigned long size_t;

static long (*W)(int, const void *, unsigned long);
extern void *dlopen(const char *, int);
extern void *dlsym(void *, const char *);
extern int sigaction(int, const void *, void *);

#define SA_SIGINFO 0x0002
#define SIGILL  4
#define SIGBUS  7
#define SIGSEGV 11

typedef struct {
    const char *dli_fname;
    void       *dli_fbase;
    const char *dli_sname;
    void       *dli_saddr;
} Dl_info;

static int (*p_dladdr)(void *, Dl_info *);

static void ph(unsigned long v)
{
    static const char hx[] = "0123456789abcdef";
    char b[11];
    int i;
    if (!W) return;
    b[0] = '0'; b[1] = 'x';
    for (i = 0; i < 8; ++i) b[2 + i] = hx[(v >> ((7 - i) * 4)) & 0xf];
    b[10] = ' ';
    W(1, b, 11);
}

static void pstr(const char *s)
{
    unsigned n = 0;
    if (!W) return;
    if (!s) { pstr("(null)"); return; }
    while (s[n]) n++;
    W(1, s, n);
}

typedef struct { unsigned gpr[16]; unsigned spsr; } arm_cpu_regs;

typedef struct {
    void       *uc_link;
    long        uc_sigmask[2];
    void       *ss_sp;
    unsigned    ss_size;
    int         ss_flags;
    arm_cpu_regs cpu;
} ucontext_t_;

typedef struct {
    int  si_signo; int si_code; int si_errno;
    int  __fltno; void *__fltip; void *__addr; int __bdslot;
} siginfo_t_;

struct sigaction_ {
    void (*sa_sigaction)(int, siginfo_t_ *, void *);
    int   sa_flags;
    long  sa_mask[2];
};

static void handler(int sig, siginfo_t_ *si, void *ctx)
{
    ucontext_t_ *uc = (ucontext_t_ *)ctx;
    unsigned *g = uc->cpu.gpr;
    int r;
    if (!W) { for (;;) ; }
    pstr("\n[DBG] SIG "); ph((unsigned long)sig);
    pstr("addr="); ph(si ? (unsigned long)si->__addr : 0);
    pstr("pc="); ph(g[15]);
    pstr("lr="); ph(g[14]);
    pstr("sp="); ph(g[13]);
    pstr("spsr="); ph(uc->cpu.spsr); pstr("\n");
    for (r = 0; r < 13; ++r) {
        static const char hx[] = "0123456789abcdef";
        char c[2];
        pstr("r");
        if (r < 10) { c[0] = '0' + r; c[1] = '='; W(1, c, 2); }
        else { c[0] = '1'; c[1] = '0' + (r - 10); W(1, c, 2); W(1, "=", 1); }
        ph(g[r]);
        if ((r & 3) == 3) pstr("\n");
    }
    {
        Dl_info di;
        unsigned long addrs[2];
        int k;
        addrs[0] = g[14]; addrs[1] = g[15];
        for (k = 0; k < 2; ++k) {
            di.dli_fname = 0; di.dli_sname = 0; di.dli_fbase = 0; di.dli_saddr = 0;
            pstr(k ? "pc in " : "lr in ");
            if (p_dladdr && p_dladdr((void *)addrs[k], &di)) {
                pstr(di.dli_fname ? di.dli_fname : "?");
                pstr(" "); pstr(di.dli_sname ? di.dli_sname : "?");
                pstr(" +"); ph(addrs[k] - (unsigned long)di.dli_saddr);
            } else ph(addrs[k]);
            pstr("\n");
        }
    }
    pstr("stack@sp:\n");
    {
        unsigned *sp = (unsigned *)g[13];
        int n;
        for (n = 0; n < 128; ++n) {
            unsigned v;
            if (((unsigned)sp & 3) || (unsigned)sp < 0x1000) break;
            v = sp[n];
            ph(v);
            if ((n & 7) == 7) pstr("\n");
        }
        pstr("\n");
    }
    for (;;) ;
}

void __attribute__((constructor(50))) ws1_dbg_arm(void)
{
    struct sigaction_ sa;
    unsigned *raw = (unsigned *)&sa;
    void *h;
    int i;
    h = dlopen("libc.so.3", 0);
    if (h) W = (long (*)(int, const void *, unsigned long))dlsym(h, "write");
    if (!W) return;
    pstr("[DBG] armed\n");
    if (h) p_dladdr = (int (*)(void *, Dl_info *))dlsym(h, "dladdr");
    for (i = 0; i < (int)(sizeof sa / sizeof raw[0]); ++i) raw[i] = 0;
    sa.sa_sigaction = handler;
    sa.sa_flags = SA_SIGINFO;
    sigaction(SIGSEGV, &sa, 0);
    sigaction(SIGBUS, &sa, 0);
    sigaction(SIGILL, &sa, 0);
    pstr("[DBG] handler ok\n");
}
