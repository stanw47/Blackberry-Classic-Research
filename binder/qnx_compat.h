/* qnx_compat.h — minimal hand-declared QNX/POSIX surface for freestanding
 * cross-compilation of the binder resmgr against QNX libc.so.3, WITHOUT the
 * QNX SDP headers.  All the *symbols* below exist in libc.so.3 (verified against
 * ref/gate_b/qnx_libc_exports.txt); only the header text is missing.
 *
 * Constants are the standard QNX/POSIX values.  Include with `-include qnx_compat.h`
 * and compile with `-nostdlib -fpic -ffreestanding`.
 */
#ifndef QNX_COMPAT_H
#define QNX_COMPAT_H

/* ---- base types ---- */
typedef unsigned long  size_t;
typedef long           ssize_t;
typedef int            int32_t;
typedef unsigned       uint32_t;
typedef long long      int64_t;
typedef unsigned long long uint64_t;
typedef unsigned long  uintptr_t;
typedef long           intptr_t;
typedef unsigned char  uint8_t;
typedef signed   char  int8_t;
typedef unsigned short uint16_t;
typedef signed   short int16_t;
typedef unsigned char  bool;   /* minimal bool for freestanding */
#define true  1
#define false 0
typedef int  pid_t;
typedef int  uid_t;
typedef int  gid_t;
typedef long off_t;
typedef long long off64_t;
typedef signed char    _Int8t;
typedef signed short   _Int16t;
typedef signed int     _Int32t;
typedef long long      _Int64t;
typedef unsigned char  _Uint8t;
typedef unsigned short _Uint16t;
typedef unsigned int   _Uint32t;
typedef unsigned long long _Uint64t;
#define __FLEXARY(t, n) t n[0]
typedef int  mode_t;
typedef int  dev_t;
typedef unsigned long long ino64_t;
typedef unsigned long ino_t;
typedef unsigned long nlink_t;
typedef long time_t;
#define NULL ((void*)0)

/* stdarg (builtin) */
typedef __builtin_va_list va_list;
#define va_start(v, l) __builtin_va_start(v, l)
#define va_end(v)      __builtin_va_end(v)
#define va_arg(v, t)   __builtin_va_arg(v, t)
#define _SC_PAGESIZE 8
extern long sysconf(int name);
extern int vfprintf(void *stream, const char *fmt, va_list ap);

/* ---- errno ---- */
extern int errno;
#define EINVAL  22
#define ENOMEM  12
#define EACCES  13
#define EEXIST  17
#define ENOSYS  89
#define EFAULT  14
#define EIO     5
#define EBADF   9
#define ENOTTY  25
#define ERANGE  34
#define EPROTO  71
#define EAGAIN  11
#define ENXIO   6
#define EBUSY   16
#define EPERM   1
#define ENOENT  2
#define EINTR   4
#define ENOSPC  28
#define ESPIPE  29

#define offsetof(type, member) __builtin_offsetof(type, member)

/* ---- fcntl / open ---- */
#define O_RDONLY 0
#define O_WRONLY 1
#define O_RDWR   2
#define O_CREAT  0x0200
#define O_EXCL   0x0800

extern int open(const char *path, int flags, ...);
extern int close(int fd);
extern ssize_t read(int fd, void *buf, size_t n);
extern ssize_t write(int fd, const void *buf, size_t n);

/* ---- memory ---- */
#define PROT_READ   0x01
#define PROT_WRITE  0x02
#define MAP_SHARED  0x01
#define MAP_FAILED  ((void*)-1)

extern void *malloc(size_t n);
extern void *calloc(size_t n, size_t sz);
extern void *realloc(void *p, size_t n);
extern void  free(void *p);
extern void *memcpy(void *d, const void *s, size_t n);
extern void *memset(void *s, int c, size_t n);
extern int   snprintf(char *buf, size_t n, const char *fmt, ...);
extern char *getenv(const char *name);
extern int   fprintf(void *stream, const char *fmt, ...);
extern void  abort(void);
extern void *_Stderr;             /* QNX: stderr is a macro for _Stderr */
#define stderr _Stderr

/* ---- mmap / munmap ---- */
extern void *mmap(void *addr, size_t len, int prot, int flags, int fd, long off);
extern int   munmap(void *addr, size_t len);

/* ---- shared memory (QNX) ---- */
#define SHM_CTL_ANON 0x0001
#define SHM_CTL_PHYS 0x0002
extern int shm_open(const char *name, int flags, int mode);
extern int shm_ctl(int fd, int flags, void *p1, size_t p2);
extern int shm_unlink(const char *name);

/* ---- pthread (all in libc.so.3) ---- */
typedef struct { unsigned w[4]; } pthread_mutex_t;
typedef struct { unsigned w[3]; } pthread_cond_t;
extern int pthread_mutex_init(pthread_mutex_t *m, const void *attr);
extern int pthread_mutex_destroy(pthread_mutex_t *m);
extern int pthread_mutex_lock(pthread_mutex_t *m);
extern int pthread_mutex_unlock(pthread_mutex_t *m);
extern int pthread_cond_init(pthread_cond_t *c, const void *attr);
extern int pthread_cond_destroy(pthread_cond_t *c);
extern int pthread_cond_wait(pthread_cond_t *c, pthread_mutex_t *m);
extern int pthread_cond_signal(pthread_cond_t *c);
extern int pthread_cond_broadcast(pthread_cond_t *c);

/* ---- exit ---- */
#define EXIT_SUCCESS 0
#define EXIT_FAILURE 1
extern void exit(int status);

/* ---- QNX resmgr / dispatch / iofunc (prototypes for libc.so.3 symbols) ---- */
/* These come from sys/resmgr.h / sys/iofunc.h / sys/dispatch.h which we DO have
 * in ../sysroot/target/include — but binder.c includes them directly, so this
 * compat header does NOT redefine them.  Kept here only to document the surface. */

/* --- iofunc.h support types --- */
#define __OFF_BITS__ 32
#define _IOFUNC_OFFSET_BITS 64
typedef struct _iofunc_mount IOFUNC_MOUNT_T;
struct _iofunc_mmap_list;
struct _iofunc_lock_list;
typedef struct _iofunc_mmap_list iofunc_mmap_list_t;
typedef struct _iofunc_lock_list iofunc_lock_list_t;

/* struct stat (minimal) + _fdinfo */
struct stat {
    unsigned long st_dev, st_ino, st_mode, st_nlink;
    int st_uid, st_gid;
    unsigned long st_size;
    long st_atime, st_mtime, st_ctime;
};
struct _fdinfo { int fd; unsigned flags; };


#endif /* QNX_COMPAT_H */
