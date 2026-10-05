/* tb_a11 — load the A11 native chain and, on fault, print a poor-man's
 * backtrace: fault registers (from the QNX ucontext) plus the frame-pointer
 * chain, each return address symbolized with dladdr.  Lets us see *who* calls
 * into the crashing code without a debugger/core file. */
typedef unsigned long size_t;
extern int write(int, const void *, size_t);
extern void _exit(int);
extern void *dlopen(const char *, int);
extern void *dlsym(void *, const char *);
extern int sigaction(int, const void *, void *);
extern int sigemptyset(void *);
extern void (*signal(int, void (*)(int)))(int);

#define SA_SIGINFO 0x0002
#define SIGILL  4
#define SIGBUS  7
#define SIGSEGV 11

#define SAY(s) write(1, (s), sizeof(s) - 1)

typedef struct {
    const char *dli_fname;
    void       *dli_fbase;
    const char *dli_sname;
    void       *dli_saddr;
} Dl_info;

/* QNX ARM layouts (from /opt/qnx650/target/qnx6/usr/include):
 *   arm/context.h  : ARM_CPU_REGISTERS = { unsigned gpr[16]; unsigned spsr; }
 *                    FP=11 SP=13 LR=14 PC=15
 *   sys/target_nto.h: sigset_t = { long __bits[2] };
 *                     stack_t  = { void *ss_sp; size_t ss_size; int ss_flags; };
 *   ucontext.h     : { ucontext_t *uc_link; sigset_t; stack_t; mcontext_t; }
 *   sys/siginfo.h  : si_addr = __data.__fault.__addr  (offset 20)
 */
typedef struct { unsigned gpr[16]; unsigned spsr; } arm_cpu_regs;

typedef struct {
    void       *uc_link;        /*  0 */
    long        uc_sigmask[2];  /*  4 */
    void       *ss_sp;          /* 12 */
    unsigned    ss_size;        /* 16 */
    int         ss_flags;       /* 20 */
    arm_cpu_regs cpu;           /* 24: gpr[] starts here */
} ucontext_t_;

typedef struct {
    int  si_signo; int si_code; int si_errno;   /*  0,4,8   */
    int  __fltno; void *__fltip; void *__addr; int __bdslot; /* 12.. */
} siginfo_t_;   /* si_addr == __addr @ offset 20 */

struct sigaction_ {
    void (*sa_sigaction)(int, siginfo_t_ *, void *);
    int   sa_flags;
    long  sa_mask[2];
};

static int (*p_dladdr)(void *, Dl_info *);

static void puthex(unsigned long v)
{
    static const char hx[] = "0123456789abcdef";
    char b[11];
    int i;
    b[0] = '0'; b[1] = 'x';
    for (i = 0; i < 8; ++i) b[2 + i] = hx[(v >> ((7 - i) * 4)) & 0xf];
    b[10] = ' ';
    write(1, b, 11);
}

static void putstr(const char *s)
{
    unsigned n = 0;
    if (!s) { putstr("(null)"); return; }
    while (s[n]) n++;
    write(1, s, n);
}

static void handler(int sig, siginfo_t_ *si, void *ctx)
{
    ucontext_t_ *uc = (ucontext_t_ *)ctx;
    unsigned *g = uc->cpu.gpr;
    int r;
    (void)sig;
    putstr("\n== SIGSEGV addr="); puthex(si ? (unsigned long)si->__addr : 0);
    putstr(" pc="); puthex(g[15]);
    putstr(" lr="); puthex(g[14]);
    putstr(" sp="); puthex(g[13]);
    putstr(" r7(fp)="); puthex(g[7]);
    putstr(" r11="); puthex(g[11]); putstr("\n");
    for (r = 0; r < 13; ++r) {
        putstr("r"); if (r < 10) { char c[2]; c[0] = '0'+r; c[1]='='; write(1,c,2); } else { char c[2]; c[0]='1'; c[1]='0'+(r-10); write(1,c,2); write(1,"=",1);} puthex(g[r]);
        if ((r & 3) == 3) putstr("\n");
    }

    /* symbolize lr/pc via dladdr */
    {
        Dl_info di;
        unsigned long addrs[2]; int k;
        addrs[0] = g[14]; addrs[1] = g[15];
        for (k = 0; k < 2; ++k) {
            di.dli_fname = 0; di.dli_sname = 0; di.dli_fbase = 0; di.dli_saddr = 0;
            putstr(k ? "pc in " : "lr in ");
            if (p_dladdr && p_dladdr((void *)addrs[k], &di)) {
                putstr(di.dli_fname ? di.dli_fname : "?");
                putstr(" "); putstr(di.dli_sname ? di.dli_sname : "?");
                putstr(" +"); puthex(addrs[k] - (unsigned long)di.dli_saddr);
            } else puthex(addrs[k]);
            putstr("\n");
        }
    }

    /* raw stack words (find return addresses) */
    putstr("stack@sp:\n");
    {
        unsigned *sp = (unsigned *)g[13];
        int n;
        for (n = 0; n < 96; ++n) {
            unsigned v;
            if (((unsigned)sp & 3) || (unsigned)sp < 0x1000) break;
            v = sp[n];
            puthex(v);
            if ((n & 7) == 7) putstr("\n");
        }
        putstr("\n");
    }
    _exit(139);
}

static void simple_handler(int sig)
{
    (void)sig;
    putstr("\nSIMPLE HANDLER FIRED\n");
    _exit(139);
}

int main(void)
{
    struct sigaction_ sa;
    int rc, i;
    unsigned *raw = (unsigned *)&sa;
    for (i = 0; i < (int)(sizeof sa / sizeof raw[0]); ++i) raw[i] = 0;
    sa.sa_sigaction = handler;
    sa.sa_flags = SA_SIGINFO;
    rc = sigaction(SIGSEGV, &sa, 0);
    sigaction(SIGILL, &sa, 0);
    sigaction(SIGBUS, &sa, 0);
    SAY("tb_a11: sigaction rc=");
    puthex((unsigned long)(long)rc);
    SAY("\n");

    p_dladdr = (int (*)(void *, Dl_info *))dlsym(dlopen("libc.so.3", 0), "dladdr");

    /* Unambiguous markers: U/u = libutils ok/fail, B/b = libbinder ok/fail. */
    void *u = dlopen("libutils.so", 0);
    write(1, u ? "U" : "u", 1);
    void *h = u ? dlopen("libbinder.so", 0) : 0;
    write(1, h ? "B" : "b", 1);
    void *p = h ? dlsym(h, "_ZN7android12ProcessState4selfEv") : 0;
    write(1, p ? "S" : "s", 1);

    /* Does operator new (libc++) work?  Call _Znwj(20) and print the pointer. */
    {
        extern void *znwj(unsigned) __asm__("_Znwj");
        void *q = 0;
        if (h) q = znwj(20);
        write(1, " N=", 3);
        puthex((unsigned long)q);
    }
    write(1, "\n", 1);
    _exit(0);
    return 0;
}
