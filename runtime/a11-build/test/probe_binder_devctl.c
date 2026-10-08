/* probe_binder_devctl — try the BB10 binder driver via QNX devctl with the
 * request numbers discovered in RIM's libbionic.so ioctl_binder:
 *   0xC0186201 BINDER_WRITE_READ (24-byte arg)
 *   0xC108620C ProcessState ctor config (size 8; RIM sets a 0xfe000 field)
 *   0xC0046209 BINDER_VERSION (4-byte arg)
 *   0xC03C620B binder_qnx_fd transaction-memory (60-byte arg)
 */
#include <unistd.h>
#include <fcntl.h>
#include <stdint.h>

extern int devctl(int fd, int dcmd, void *data, size_t nbytes, int *info);

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

    for (i = 0; i < (int)sizeof(buf); ++i) buf[i] = 0;

    fd = open("/dev/binder", 2 /*O_RDWR*/);
    SAY("open: "); ph(fd); SAY("\n");
    if (fd < 0) return 1;

    /* BINDER_VERSION (4-byte arg) */
    buf[0] = buf[1] = buf[2] = buf[3] = 0;
    int rc = devctl(fd, (int)0xC0046209, buf, 4, &info);
    SAY("devctl VERSION rc="); ph(rc); SAY("info="); ph(info);
    SAY("ver="); ph(*(unsigned *)buf); SAY("\n");

    /* ProcessState ctor config: size field at +0x104 = 0xfe000 */
    *(unsigned *)(buf + 0x104) = 0xfe000;
    info = 0;
    rc = devctl(fd, (int)0xC108620C, buf, 8, &info);
    SAY("devctl CFG rc="); ph(rc); SAY("info="); ph(info); SAY("\n");

    /* transaction memory (60-byte arg) */
    info = 0;
    rc = devctl(fd, (int)0xC03C620B, buf, 0x3C, &info);
    SAY("devctl TXN rc="); ph(rc); SAY("info="); ph(info); SAY("\n");
    for (i = 0; i < 0x3C; i += 4) { ph(*(unsigned *)(buf + i)); if (((i / 4) & 3) == 3) SAY("\n"); }
    SAY("\n");

    /* BINDER_WRITE_READ (24-byte arg, empty) */
    for (i = 0; i < 0x18; ++i) buf[i] = 0;
    info = 0;
    rc = devctl(fd, (int)0xC0186201, buf, 0x18, &info);
    SAY("devctl WR rc="); ph(rc); SAY("info="); ph(info); SAY("\n");

    close(fd);
    return 0;
}
