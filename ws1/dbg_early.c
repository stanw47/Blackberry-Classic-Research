/* ws1/dbg_early.c — early debug DSO for the A11 pre-ctor crash hunt.
 *
 * Links against QNX libc.so.3 directly (no shim: write/sigaction/dladdr bind
 * straight to libc.so.3), so its constructor can arm a SIGSEGV handler before
 * any libc++.so constructor runs.  Linked FIRST in the probe's NEEDED list.
 */
typedef unsigned long size_t;

extern int write(int, const void *, size_t);
extern int sigaction(int, const void *, void *);
extern int dladdr(const void *, void *);

typedef struct {
    const char *dli_fname;
    void       *dli_fbase;
    const char *dli_sname;
    void       *dli_saddr;
} Dl_info;

#define SAY(s) write(1, (s), sizeof(s) - 1)

static void ph(unsigned long v)
{
    static const char hx[] = "0123456789abcdef";
    char b[11];
    int i;
    b[0] = '0'; b[1] = 'x';
    for (i = 0; i < 8; ++i) b[2 + i] = hx[(v >> ((7 - i) * 4)) & 0xf];
    b[10] = ' ';
    write(1, b, 11);
}

static void pstr(const char *s)
{
    unsigned n = 0;
    if (!s) { pstr("(null)"); return; }
    while (s[n]) n++;
    write(1, s, n);
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
    static const char hx[] = "0123456789abcdef";
    (void)sig;
    pstr("\n[EARLY] SIG addr="); ph(si ? (unsigned long)si->__addr : 0);
    pstr("pc="); ph(g[15]);
    pstr("lr="); ph(g[14]);
    pstr("sp="); ph(g[13]);
    pstr("spsr="); ph(uc->cpu.spsr); pstr("\n");
    for (r = 0; r < 13; ++r) {
        char c[2];
        pstr("r");
        if (r < 10) { c[0] = '0' + r; c[1] = '='; write(1, c, 2); }
        else { c[0] = '1'; c[1] = '0' + (r - 10); write(1, c, 2); write(1, "=", 1); }
        ph(g[r]);
        if ((r & 3) == 3) pstr("\n");
    }
    {
        Dl_info di;
        unsigned long addrs[2]; int k;
        addrs[0] = g[14]; addrs[1] = g[15];
        for (k = 0; k < 2; ++k) {
            di.dli_fname = 0; di.dli_sname = 0; di.dli_fbase = 0; di.dli_saddr = 0;
            pstr(k ? "pc in " : "lr in ");
            if (dladdr((void *)addrs[k], &di)) {
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
        for (n = 0; n < 96; ++n) {
            unsigned v;
            if (((unsigned)sp & 3) || (unsigned)sp < 0x1000) break;
            v = sp[n];
            ph(v);
            if ((n & 7) == 7) pstr("\n");
        }
        pstr("\n");
    }
    (void)hx;
    for (;;) ;
}

void __attribute__((constructor(50))) dbg_early_arm(void)
{
    struct sigaction_ sa;
    unsigned *raw = (unsigned *)&sa;
    int i;
    for (i = 0; i < (int)(sizeof sa / sizeof raw[0]); ++i) raw[i] = 0;
    sa.sa_sigaction = handler;
    sa.sa_flags = 0x0002; /* SA_SIGINFO */
    sigaction(11, &sa, 0);
    sigaction(7, &sa, 0);
    sigaction(4, &sa, 0);
    SAY("[EARLY] armed\n");
}
