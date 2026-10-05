/*
 * probe_binder_step.c — Step-by-step binder driver probe.
 *
 * Isolates each step of ProcessState::open_driver() to find the exact hang point.
 * C/Freestanding, links libc.so.3 + ws1 shim only.
 *
 * Steps:
 * 1. Print UID/EUID/GID/EGID
 * 2. open("/dev/binder", O_RDWR | O_CLOEXEC)
 * 3. ioctl(fd, BINDER_VERSION, &version)
 * 4. ioctl(fd, BINDER_SET_MAX_THREADS, &max_threads)
 * 5. mmap(NULL, 1024*1024, PROT_READ, MAP_PRIVATE | MAP_NORESERVE, fd, 0)
 *
 * Each step writes synchronously to stdout via write(1, ...) so we see exact hang point.
 *
 * If run as root (uid 0), drops to uid 1000 / gid 10011 to match /dev/binder owner.
 */

#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdint.h>

/* Missing QNX/POSIX definitions for freestanding compile */
#ifndef O_CLOEXEC
#define O_CLOEXEC 0x80000
#endif
#ifndef MAP_PRIVATE
#define MAP_PRIVATE 0x02
#endif
#ifndef MAP_NORESERVE
#define MAP_NORESERVE 0x0400
#endif

/* These are in libc.so.3 but not in qnx_compat.h */
extern int getuid(void);
extern int geteuid(void);
extern int getgid(void);
extern int getegid(void);
extern int ioctl(int fd, unsigned long request, ...);
extern int setuid(uid_t uid);
extern int setgid(gid_t gid);

#include <binder_a11.h>

#define SAY(s) write(1, (s), sizeof(s) - 1)
#define SAY_HEX(n) do { \
    char buf[32]; \
    int len = 0; \
    unsigned long v = (unsigned long)(n); \
    if (v == 0) { write(1, "0", 1); } \
    else { \
        char rev[32]; \
        int i = 0; \
        while (v > 0) { \
            int d = v & 0xF; \
            rev[i++] = (d < 10) ? '0' + d : 'a' + (d - 10); \
            v >>= 4; \
        } \
        write(1, "0x", 2); \
        while (i > 0) { write(1, &rev[--i], 1); } \
    } \
    write(1, "\n", 1); \
} while(0)

#define SAY_DEC(n) do { \
    char buf[32]; \
    int len = 0; \
    long v = (long)(n); \
    if (v == 0) { write(1, "0", 1); } \
    else if (v < 0) { write(1, "-", 1); v = -v; } \
    char rev[32]; \
    int i = 0; \
    while (v > 0) { \
        rev[i++] = '0' + (v % 10); \
        v /= 10; \
    } \
    while (i > 0) { write(1, &rev[--i], 1); } \
    write(1, "\n", 1); \
} while(0)

#define SAY_ERRNO() do { \
    write(1, " errno=", 7); \
    SAY_DEC(errno); \
} while(0)

#define SAY_STR(s) write(1, (s), sizeof(s) - 1)

int main(int argc, char **argv)
{
    (void)argc; (void)argv;

    /* Step 1: Print UID/EUID/GID/EGID */
    SAY_STR("STEP 1: Credentials\n");
    SAY_STR("  uid=");  SAY_DEC(getuid());
    SAY_STR("  euid="); SAY_DEC(geteuid());
    SAY_STR("  gid=");  SAY_DEC(getgid());
    SAY_STR("  egid="); SAY_DEC(getegid());
    SAY_STR("\n");

    /* If running as root, drop to android_system (uid 1000:10011) to match /dev/binder owner */
    if (getuid() == 0) {
        SAY_STR("  [root detected] dropping to uid 1000, gid 10011\n");
        if (setgid(10011) != 0) {
            SAY_STR("  setgid(10011) failed"); SAY_ERRNO(); SAY_STR("\n");
            return 1;
        }
        if (setuid(1000) != 0) {
            SAY_STR("  setuid(1000) failed"); SAY_ERRNO(); SAY_STR("\n");
            return 1;
        }
        SAY_STR("  [dropped] uid="); SAY_DEC(getuid());
        SAY_STR("  gid="); SAY_DEC(getgid());
        SAY_STR("  egid="); SAY_DEC(getegid());
        SAY_STR("\n");
    }

    /* Step 2: open("/dev/binder", O_RDWR | O_CLOEXEC) */
    SAY_STR("STEP 2: open(\"/dev/binder\", O_RDWR | O_CLOEXEC)\n");
    int fd = open("/dev/binder", O_RDWR | O_CLOEXEC);
    SAY_STR("  fd="); SAY_DEC(fd);
    if (fd < 0) {
        SAY_ERRNO();
        SAY_STR("\n");
        return 1;
    }
    SAY_STR("\n");

    /* Step 3: ioctl(fd, BINDER_VERSION, &version) */
    SAY_STR("STEP 3: ioctl(fd, BINDER_VERSION, &version)\n");
    int version = 0;
    int rc = ioctl(fd, BINDER_VERSION, &version);
    SAY_STR("  rc="); SAY_DEC(rc);
    SAY_STR("  version="); SAY_DEC(version);
    if (rc < 0) {
        SAY_ERRNO();
        SAY_STR("\n");
        close(fd);
        return 2;
    }
    SAY_STR("\n");

    /* Step 4: ioctl(fd, BINDER_SET_MAX_THREADS, &max_threads) */
    SAY_STR("STEP 4: ioctl(fd, BINDER_SET_MAX_THREADS, &max_threads)\n");
    int max_threads = 15;
    rc = ioctl(fd, BINDER_SET_MAX_THREADS, &max_threads);
    SAY_STR("  rc="); SAY_DEC(rc);
    if (rc < 0) {
        SAY_ERRNO();
        SAY_STR("\n");
        close(fd);
        return 3;
    }
    SAY_STR("\n");

    /* Step 5: mmap(NULL, 1024*1024, PROT_READ, MAP_PRIVATE | MAP_NORESERVE, fd, 0) */
    SAY_STR("STEP 5: mmap(NULL, 1048576, PROT_READ, MAP_PRIVATE | MAP_NORESERVE, fd, 0)\n");
    void *addr = mmap(NULL, 1024 * 1024, PROT_READ, MAP_PRIVATE | MAP_NORESERVE, fd, 0);
    SAY_STR("  addr="); SAY_HEX(addr);
    if (addr == MAP_FAILED) {
        SAY_ERRNO();
        SAY_STR("\n");
        close(fd);
        return 4;
    }
    SAY_STR("\n");

    SAY_STR("ALL STEPS PASSED\n");
    close(fd);
    return 0;
}