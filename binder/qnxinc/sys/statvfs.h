#ifndef _SYS_STATVFS_H
#define _SYS_STATVFS_H
struct statvfs { unsigned long f_bsize, f_frsize, f_blocks, f_bfree, f_bavail, f_files, f_ffree, f_favail; unsigned long f_fsid, f_flag, f_namemax; };
#endif
