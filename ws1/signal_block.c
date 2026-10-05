/* Signal setup constructor - runs before dynamic linking.
 *
 * NOTE (session71): this used to call sigprocmask(SIG_SETMASK, sigfillset())
 * which blocked EVERY signal process-wide.  That makes faults undeliverable
 * (SIGSEGV handlers never run; the kernel just kills the process) and breaks
 * normal Android userland signal use.  The blanket block is removed. */
#include <signal.h>

__attribute__((constructor(101)))  /* Run early, before .init_array */
void ws1_block_signals(void)
{
    /* Ignore common signals that might interrupt dynamic linking */
    struct sigaction sa = {0};
    sa.sa_handler = SIG_IGN;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    
    sigaction(SIGCHLD, &sa, NULL);
    sigaction(SIGPIPE, &sa, NULL);
    sigaction(SIGALRM, &sa, NULL);
    sigaction(SIGHUP, &sa, NULL);
    sigaction(SIGINT, &sa, NULL);
    sigaction(SIGTERM, &sa, NULL);
    sigaction(SIGUSR1, &sa, NULL);
    sigaction(SIGUSR2, &sa, NULL);
}
