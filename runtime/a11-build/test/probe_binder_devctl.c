/* probe_binder_devctl — v11: is the CFG writeback token a valid address IN OUR
 * PROCESS (driver mmap_peer'ing the shm into the client)?  Crash-tolerant: the
 * token dereference happens first, everything else after.
 */
#include <unistd.h>
#include <fcntl.h>
#include <stdint.h>

extern int devctl(int fd, int dcmd, void *data, size_t nbytes, int *info);
extern void *mmap(void *addr, size_t len, int prot, int flags, int fd, long long off);
extern int munmap(void *addr, size_t len);

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

int main(void)
{
    unsigned char buf[0x120];
    int info = 0;
    int i, fd;
    int rc;
    unsigned token;

    for (i = 0; i < (int)sizeof(buf); ++i) buf[i] = 0;

    fd = open("/dev/binder", 2 /*O_RDWR*/);
    SAY("open: "); ph(fd); SAY("\n");
    if (fd < 0) return 1;

    rc = devctl(fd, (int)0xC0046209, buf, 4, &info);
    SAY("VERSION rc="); ph(rc); SAY("ver="); ph(*(unsigned *)buf); SAY("\n");

    *(unsigned *)buf = 15;
    rc = devctl(fd, (int)0x80046205, buf, 4, &info);
    SAY("SET_MAX_THREADS rc="); ph(rc); SAY("\n");

    for (i = 0; i < 0x108; ++i) buf[i] = 0;
    *(unsigned *)(buf + 0x104) = 0xfe000;
    rc = devctl(fd, (int)0xC108620C, buf, 0x108, &info);
    token = *(unsigned *)(buf + 0x100);
    SAY("CFG rc="); ph(rc); SAY("token="); ph(token); SAY("\n");

    /* THE TEST: is the token mapped in our address space? */
    {
        volatile unsigned *tp = (volatile unsigned *)token;
        unsigned v0 = *tp;
        SAY("token[0] = "); ph(v0); SAY("\n");
        *tp = 0xA5A5A5A5u;
        SAY("token write+read = "); ph(*tp); SAY("\n");
        *tp = v0;
    }

    /* TXN with more candidate keys */
    for (i = 0; i < 0x40; ++i) buf[i] = 0;
    *(unsigned *)buf = (unsigned)getpid();
    rc = devctl(fd, (int)0xC03C620B, buf, 0x3C, &info);
    SAY("TXN(pid) rc="); ph(rc); SAY("\n");

    /* retry mmap on fd with every plausible prot/flag combo */
    void *m;
    m = mmap(0, 0xfe000, 0x300, 1, fd, 0);  SAY("mmap 0x300/1: "); ph((unsigned long)m); SAY("\n");
    m = mmap(0, 0xfe000, 0x3, 1, fd, 0);    SAY("mmap 0x3/1: ");   ph((unsigned long)m); SAY("\n");
    m = mmap(0, 0xfe000, 0x300, 0, fd, 0);  SAY("mmap 0x300/0: "); ph((unsigned long)m); SAY("\n");

    for (i = 0; i < 0x18; ++i) buf[i] = 0;
    rc = devctl(fd, (int)0xC0186201, buf, 0x18, &info);
    SAY("WR rc="); ph(rc); SAY("\n");

    close(fd);
    return 0;
}
