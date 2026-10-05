	.syntax unified
	.arch armv7-a
	.thumb
	.fpu softvfp
	.text

	.global _Exit
	.type _Exit, %function
	.thumb_func
_Exit:
	movw r12, #0
	b ws1_resolver
	.align 2

	.global _Unwind_Backtrace
	.type _Unwind_Backtrace, %function
	.thumb_func
_Unwind_Backtrace:
	movw r12, #1
	b ws1_resolver
	.align 2

	.global _Unwind_Complete
	.type _Unwind_Complete, %function
	.thumb_func
_Unwind_Complete:
	movw r12, #2
	b ws1_resolver
	.align 2

	.global _Unwind_DeleteException
	.type _Unwind_DeleteException, %function
	.thumb_func
_Unwind_DeleteException:
	movw r12, #3
	b ws1_resolver
	.align 2

	.global _Unwind_GetCFA
	.type _Unwind_GetCFA, %function
	.thumb_func
_Unwind_GetCFA:
	movw r12, #4
	b ws1_resolver
	.align 2

	.global _Unwind_GetDataRelBase
	.type _Unwind_GetDataRelBase, %function
	.thumb_func
_Unwind_GetDataRelBase:
	movw r12, #5
	b ws1_resolver
	.align 2

	.global _Unwind_GetLanguageSpecificData
	.type _Unwind_GetLanguageSpecificData, %function
	.thumb_func
_Unwind_GetLanguageSpecificData:
	movw r12, #6
	b ws1_resolver
	.align 2

	.global _Unwind_GetRegionStart
	.type _Unwind_GetRegionStart, %function
	.thumb_func
_Unwind_GetRegionStart:
	movw r12, #7
	b ws1_resolver
	.align 2

	.global _Unwind_GetTextRelBase
	.type _Unwind_GetTextRelBase, %function
	.thumb_func
_Unwind_GetTextRelBase:
	movw r12, #8
	b ws1_resolver
	.align 2

	.global _Unwind_RaiseException
	.type _Unwind_RaiseException, %function
	.thumb_func
_Unwind_RaiseException:
	movw r12, #9
	b ws1_resolver
	.align 2

	.global _Unwind_Resume
	.type _Unwind_Resume, %function
	.thumb_func
_Unwind_Resume:
	movw r12, #10
	b ws1_resolver
	.align 2

	.global _Unwind_Resume_or_Rethrow
	.type _Unwind_Resume_or_Rethrow, %function
	.thumb_func
_Unwind_Resume_or_Rethrow:
	movw r12, #11
	b ws1_resolver
	.align 2

	.global _Unwind_VRS_Get
	.type _Unwind_VRS_Get, %function
	.thumb_func
_Unwind_VRS_Get:
	movw r12, #12
	b ws1_resolver
	.align 2

	.global _Unwind_VRS_Pop
	.type _Unwind_VRS_Pop, %function
	.thumb_func
_Unwind_VRS_Pop:
	movw r12, #13
	b ws1_resolver
	.align 2

	.global _Unwind_VRS_Set
	.type _Unwind_VRS_Set, %function
	.thumb_func
_Unwind_VRS_Set:
	movw r12, #14
	b ws1_resolver
	.align 2

	.global __aeabi_idiv
	.type __aeabi_idiv, %function
	.thumb_func
__aeabi_idiv:
	movw r12, #15
	b ws1_resolver
	.align 2

	.global __aeabi_idivmod
	.type __aeabi_idivmod, %function
	.thumb_func
__aeabi_idivmod:
	movw r12, #16
	b ws1_resolver
	.align 2

	.global __aeabi_ldivmod
	.type __aeabi_ldivmod, %function
	.thumb_func
__aeabi_ldivmod:
	movw r12, #17
	b ws1_resolver
	.align 2

	.global __aeabi_uidiv
	.type __aeabi_uidiv, %function
	.thumb_func
__aeabi_uidiv:
	movw r12, #18
	b ws1_resolver
	.align 2

	.global __aeabi_uidivmod
	.type __aeabi_uidivmod, %function
	.thumb_func
__aeabi_uidivmod:
	movw r12, #19
	b ws1_resolver
	.align 2

	.global __aeabi_uldivmod
	.type __aeabi_uldivmod, %function
	.thumb_func
__aeabi_uldivmod:
	movw r12, #20
	b ws1_resolver
	.align 2

	.global __aeabi_unwind_cpp_pr0
	.type __aeabi_unwind_cpp_pr0, %function
	.thumb_func
__aeabi_unwind_cpp_pr0:
	movw r12, #21
	b ws1_resolver
	.align 2

	.global __aeabi_unwind_cpp_pr1
	.type __aeabi_unwind_cpp_pr1, %function
	.thumb_func
__aeabi_unwind_cpp_pr1:
	movw r12, #22
	b ws1_resolver
	.align 2

	.global __aeabi_unwind_cpp_pr2
	.type __aeabi_unwind_cpp_pr2, %function
	.thumb_func
__aeabi_unwind_cpp_pr2:
	movw r12, #23
	b ws1_resolver
	.align 2

	.global __assert
	.type __assert, %function
	.thumb_func
__assert:
	movw r12, #24
	b ws1_resolver
	.align 2

	.global __cxa_atexit
	.type __cxa_atexit, %function
	.thumb_func
__cxa_atexit:
	movw r12, #25
	b ws1_resolver
	.align 2

	.global __cxa_finalize
	.type __cxa_finalize, %function
	.thumb_func
__cxa_finalize:
	movw r12, #26
	b ws1_resolver
	.align 2

	.global __divdi3
	.type __divdi3, %function
	.thumb_func
__divdi3:
	movw r12, #27
	b ws1_resolver
	.align 2

	.global __divsi3
	.type __divsi3, %function
	.thumb_func
__divsi3:
	movw r12, #28
	b ws1_resolver
	.align 2

	.global __exit
	.type __exit, %function
	.thumb_func
__exit:
	movw r12, #29
	b ws1_resolver
	.align 2

	.global __gnu_Unwind_Find_exidx
	.type __gnu_Unwind_Find_exidx, %function
	.thumb_func
__gnu_Unwind_Find_exidx:
	movw r12, #30
	b ws1_resolver
	.align 2

	.global __gnu_ldivmod_helper
	.type __gnu_ldivmod_helper, %function
	.thumb_func
__gnu_ldivmod_helper:
	movw r12, #31
	b ws1_resolver
	.align 2

	.global __gnu_uldivmod_helper
	.type __gnu_uldivmod_helper, %function
	.thumb_func
__gnu_uldivmod_helper:
	movw r12, #32
	b ws1_resolver
	.align 2

	.global __gnu_unwind_frame
	.type __gnu_unwind_frame, %function
	.thumb_func
__gnu_unwind_frame:
	movw r12, #33
	b ws1_resolver
	.align 2

	.global __memcpy_chk
	.type __memcpy_chk, %function
	.thumb_func
__memcpy_chk:
	movw r12, #34
	b ws1_resolver
	.align 2

	.global __memmove_chk
	.type __memmove_chk, %function
	.thumb_func
__memmove_chk:
	movw r12, #35
	b ws1_resolver
	.align 2

	.global __memset_chk
	.type __memset_chk, %function
	.thumb_func
__memset_chk:
	movw r12, #36
	b ws1_resolver
	.align 2

	.global __popcount_tab
	.type __popcount_tab, %function
	.thumb_func
__popcount_tab:
	movw r12, #37
	b ws1_resolver
	.align 2

	.global __popcountsi2
	.type __popcountsi2, %function
	.thumb_func
__popcountsi2:
	movw r12, #38
	b ws1_resolver
	.align 2

	.global __progname
	.type __progname, %function
	.thumb_func
__progname:
	movw r12, #39
	b ws1_resolver
	.align 2

	.global __snprintf_chk
	.type __snprintf_chk, %function
	.thumb_func
__snprintf_chk:
	movw r12, #40
	b ws1_resolver
	.align 2

	.global __sprintf_chk
	.type __sprintf_chk, %function
	.thumb_func
__sprintf_chk:
	movw r12, #41
	b ws1_resolver
	.align 2

	.global __stack_chk_fail
	.type __stack_chk_fail, %function
	.thumb_func
__stack_chk_fail:
	movw r12, #42
	b ws1_resolver
	.align 2

	.global __stack_chk_guard
	.type __stack_chk_guard, %function
	.thumb_func
__stack_chk_guard:
	movw r12, #43
	b ws1_resolver
	.align 2

	.global __strcat_chk
	.type __strcat_chk, %function
	.thumb_func
__strcat_chk:
	movw r12, #44
	b ws1_resolver
	.align 2

	.global __strcpy_chk
	.type __strcpy_chk, %function
	.thumb_func
__strcpy_chk:
	movw r12, #45
	b ws1_resolver
	.align 2

	.global __strncat_chk
	.type __strncat_chk, %function
	.thumb_func
__strncat_chk:
	movw r12, #46
	b ws1_resolver
	.align 2

	.global __strncpy_chk
	.type __strncpy_chk, %function
	.thumb_func
__strncpy_chk:
	movw r12, #47
	b ws1_resolver
	.align 2

	.global __udivdi3
	.type __udivdi3, %function
	.thumb_func
__udivdi3:
	movw r12, #48
	b ws1_resolver
	.align 2

	.global __udivsi3
	.type __udivsi3, %function
	.thumb_func
__udivsi3:
	movw r12, #49
	b ws1_resolver
	.align 2

	.global __vsnprintf_chk
	.type __vsnprintf_chk, %function
	.thumb_func
__vsnprintf_chk:
	movw r12, #50
	b ws1_resolver
	.align 2

	.global __vsprintf_chk
	.type __vsprintf_chk, %function
	.thumb_func
__vsprintf_chk:
	movw r12, #51
	b ws1_resolver
	.align 2

	.global _exit
	.type _exit, %function
	.thumb_func
_exit:
	movw r12, #52
	b ws1_resolver
	.align 2

	.global _longjmp
	.type _longjmp, %function
	.thumb_func
_longjmp:
	movw r12, #53
	b ws1_resolver
	.align 2

	.global _setjmp
	.type _setjmp, %function
	.thumb_func
_setjmp:
	movw r12, #54
	b ws1_resolver
	.align 2

	.global _tolower
	.type _tolower, %function
	.thumb_func
_tolower:
	movw r12, #55
	b ws1_resolver
	.align 2

	.global _toupper
	.type _toupper, %function
	.thumb_func
_toupper:
	movw r12, #56
	b ws1_resolver
	.align 2

	.global abort
	.type abort, %function
	.thumb_func
abort:
	movw r12, #57
	b ws1_resolver
	.align 2

	.global abs
	.type abs, %function
	.thumb_func
abs:
	movw r12, #58
	b ws1_resolver
	.align 2

	.global access
	.type access, %function
	.thumb_func
access:
	movw r12, #59
	b ws1_resolver
	.align 2

	.global alarm
	.type alarm, %function
	.thumb_func
alarm:
	movw r12, #60
	b ws1_resolver
	.align 2

	.global at_quick_exit
	.type at_quick_exit, %function
	.thumb_func
at_quick_exit:
	movw r12, #61
	b ws1_resolver
	.align 2

	.global atexit
	.type atexit, %function
	.thumb_func
atexit:
	movw r12, #62
	b ws1_resolver
	.align 2

	.global atof
	.type atof, %function
	.thumb_func
atof:
	movw r12, #63
	b ws1_resolver
	.align 2

	.global atoi
	.type atoi, %function
	.thumb_func
atoi:
	movw r12, #64
	b ws1_resolver
	.align 2

	.global atol
	.type atol, %function
	.thumb_func
atol:
	movw r12, #65
	b ws1_resolver
	.align 2

	.global atoll
	.type atoll, %function
	.thumb_func
atoll:
	movw r12, #66
	b ws1_resolver
	.align 2

	.global basename
	.type basename, %function
	.thumb_func
basename:
	movw r12, #67
	b ws1_resolver
	.align 2

	.global bcopy
	.type bcopy, %function
	.thumb_func
bcopy:
	movw r12, #68
	b ws1_resolver
	.align 2

	.global bsearch
	.type bsearch, %function
	.thumb_func
bsearch:
	movw r12, #69
	b ws1_resolver
	.align 2

	.global btowc
	.type btowc, %function
	.thumb_func
btowc:
	movw r12, #70
	b ws1_resolver
	.align 2

	.global bzero
	.type bzero, %function
	.thumb_func
bzero:
	movw r12, #71
	b ws1_resolver
	.align 2

	.global c16rtomb
	.type c16rtomb, %function
	.thumb_func
c16rtomb:
	movw r12, #72
	b ws1_resolver
	.align 2

	.global c32rtomb
	.type c32rtomb, %function
	.thumb_func
c32rtomb:
	movw r12, #73
	b ws1_resolver
	.align 2

	.global calloc
	.type calloc, %function
	.thumb_func
calloc:
	movw r12, #74
	b ws1_resolver
	.align 2

	.global cfgetispeed
	.type cfgetispeed, %function
	.thumb_func
cfgetispeed:
	movw r12, #75
	b ws1_resolver
	.align 2

	.global cfgetospeed
	.type cfgetospeed, %function
	.thumb_func
cfgetospeed:
	movw r12, #76
	b ws1_resolver
	.align 2

	.global cfmakeraw
	.type cfmakeraw, %function
	.thumb_func
cfmakeraw:
	movw r12, #77
	b ws1_resolver
	.align 2

	.global cfsetispeed
	.type cfsetispeed, %function
	.thumb_func
cfsetispeed:
	movw r12, #78
	b ws1_resolver
	.align 2

	.global cfsetospeed
	.type cfsetospeed, %function
	.thumb_func
cfsetospeed:
	movw r12, #79
	b ws1_resolver
	.align 2

	.global chmod
	.type chmod, %function
	.thumb_func
chmod:
	movw r12, #80
	b ws1_resolver
	.align 2

	.global chroot
	.type chroot, %function
	.thumb_func
chroot:
	movw r12, #81
	b ws1_resolver
	.align 2

	.global clearenv
	.type clearenv, %function
	.thumb_func
clearenv:
	movw r12, #82
	b ws1_resolver
	.align 2

	.global clearerr
	.type clearerr, %function
	.thumb_func
clearerr:
	movw r12, #83
	b ws1_resolver
	.align 2

	.global clock
	.type clock, %function
	.thumb_func
clock:
	movw r12, #84
	b ws1_resolver
	.align 2

	.global clock_getcpuclockid
	.type clock_getcpuclockid, %function
	.thumb_func
clock_getcpuclockid:
	movw r12, #85
	b ws1_resolver
	.align 2

	.global clock_getres
	.type clock_getres, %function
	.thumb_func
clock_getres:
	movw r12, #86
	b ws1_resolver
	.align 2

	.global clock_gettime
	.type clock_gettime, %function
	.thumb_func
clock_gettime:
	movw r12, #87
	b ws1_resolver
	.align 2

	.global clock_nanosleep
	.type clock_nanosleep, %function
	.thumb_func
clock_nanosleep:
	movw r12, #88
	b ws1_resolver
	.align 2

	.global clock_settime
	.type clock_settime, %function
	.thumb_func
clock_settime:
	movw r12, #89
	b ws1_resolver
	.align 2

	.global closedir
	.type closedir, %function
	.thumb_func
closedir:
	movw r12, #90
	b ws1_resolver
	.align 2

	.global closelog
	.type closelog, %function
	.thumb_func
closelog:
	movw r12, #91
	b ws1_resolver
	.align 2

	.global ctermid
	.type ctermid, %function
	.thumb_func
ctermid:
	movw r12, #92
	b ws1_resolver
	.align 2

	.global daemon
	.type daemon, %function
	.thumb_func
daemon:
	movw r12, #93
	b ws1_resolver
	.align 2

	.global dirfd
	.type dirfd, %function
	.thumb_func
dirfd:
	movw r12, #94
	b ws1_resolver
	.align 2

	.global dirname
	.type dirname, %function
	.thumb_func
dirname:
	movw r12, #95
	b ws1_resolver
	.align 2

	.global div
	.type div, %function
	.thumb_func
div:
	movw r12, #96
	b ws1_resolver
	.align 2

	.global dladdr
	.type dladdr, %function
	.thumb_func
dladdr:
	movw r12, #97
	b ws1_resolver
	.align 2

	.global dlclose
	.type dlclose, %function
	.thumb_func
dlclose:
	movw r12, #98
	b ws1_resolver
	.align 2

	.global dlerror
	.type dlerror, %function
	.thumb_func
dlerror:
	movw r12, #99
	b ws1_resolver
	.align 2

	.global drand48
	.type drand48, %function
	.thumb_func
drand48:
	movw r12, #100
	b ws1_resolver
	.align 2

	.global dup
	.type dup, %function
	.thumb_func
dup:
	movw r12, #101
	b ws1_resolver
	.align 2

	.global dup2
	.type dup2, %function
	.thumb_func
dup2:
	movw r12, #102
	b ws1_resolver
	.align 2

	.global endgrent
	.type endgrent, %function
	.thumb_func
endgrent:
	movw r12, #103
	b ws1_resolver
	.align 2

	.global environ
	.type environ, %function
	.thumb_func
environ:
	movw r12, #104
	b ws1_resolver
	.align 2

	.global erand48
	.type erand48, %function
	.thumb_func
erand48:
	movw r12, #105
	b ws1_resolver
	.align 2

	.global err
	.type err, %function
	.thumb_func
err:
	movw r12, #106
	b ws1_resolver
	.align 2

	.global errx
	.type errx, %function
	.thumb_func
errx:
	movw r12, #107
	b ws1_resolver
	.align 2

	.global exit
	.type exit, %function
	.thumb_func
exit:
	movw r12, #108
	b ws1_resolver
	.align 2

	.global fchdir
	.type fchdir, %function
	.thumb_func
fchdir:
	movw r12, #109
	b ws1_resolver
	.align 2

	.global fchmod
	.type fchmod, %function
	.thumb_func
fchmod:
	movw r12, #110
	b ws1_resolver
	.align 2

	.global fclose
	.type fclose, %function
	.thumb_func
fclose:
	movw r12, #111
	b ws1_resolver
	.align 2

	.global fcntl
	.type fcntl, %function
	.thumb_func
fcntl:
	movw r12, #112
	b ws1_resolver
	.align 2

	.global fdatasync
	.type fdatasync, %function
	.thumb_func
fdatasync:
	movw r12, #113
	b ws1_resolver
	.align 2

	.global fdopen
	.type fdopen, %function
	.thumb_func
fdopen:
	movw r12, #114
	b ws1_resolver
	.align 2

	.global feof
	.type feof, %function
	.thumb_func
feof:
	movw r12, #115
	b ws1_resolver
	.align 2

	.global ferror
	.type ferror, %function
	.thumb_func
ferror:
	movw r12, #116
	b ws1_resolver
	.align 2

	.global fflush
	.type fflush, %function
	.thumb_func
fflush:
	movw r12, #117
	b ws1_resolver
	.align 2

	.global ffs
	.type ffs, %function
	.thumb_func
ffs:
	movw r12, #118
	b ws1_resolver
	.align 2

	.global fgetc
	.type fgetc, %function
	.thumb_func
fgetc:
	movw r12, #119
	b ws1_resolver
	.align 2

	.global fgetpos
	.type fgetpos, %function
	.thumb_func
fgetpos:
	movw r12, #120
	b ws1_resolver
	.align 2

	.global fgets
	.type fgets, %function
	.thumb_func
fgets:
	movw r12, #121
	b ws1_resolver
	.align 2

	.global fgetwc
	.type fgetwc, %function
	.thumb_func
fgetwc:
	movw r12, #122
	b ws1_resolver
	.align 2

	.global fgetws
	.type fgetws, %function
	.thumb_func
fgetws:
	movw r12, #123
	b ws1_resolver
	.align 2

	.global fileno
	.type fileno, %function
	.thumb_func
fileno:
	movw r12, #124
	b ws1_resolver
	.align 2

	.global flock
	.type flock, %function
	.thumb_func
flock:
	movw r12, #125
	b ws1_resolver
	.align 2

	.global flockfile
	.type flockfile, %function
	.thumb_func
flockfile:
	movw r12, #126
	b ws1_resolver
	.align 2

	.global fnmatch
	.type fnmatch, %function
	.thumb_func
fnmatch:
	movw r12, #127
	b ws1_resolver
	.align 2

	.global fopen
	.type fopen, %function
	.thumb_func
fopen:
	movw r12, #128
	b ws1_resolver
	.align 2

	.global fopen64
	.type fopen64, %function
	.thumb_func
fopen64:
	movw r12, #129
	b ws1_resolver
	.align 2

	.global fpathconf
	.type fpathconf, %function
	.thumb_func
fpathconf:
	movw r12, #130
	b ws1_resolver
	.align 2

	.global fprintf
	.type fprintf, %function
	.thumb_func
fprintf:
	movw r12, #131
	b ws1_resolver
	.align 2

	.global fputc
	.type fputc, %function
	.thumb_func
fputc:
	movw r12, #132
	b ws1_resolver
	.align 2

	.global fputs
	.type fputs, %function
	.thumb_func
fputs:
	movw r12, #133
	b ws1_resolver
	.align 2

	.global fputwc
	.type fputwc, %function
	.thumb_func
fputwc:
	movw r12, #134
	b ws1_resolver
	.align 2

	.global fputws
	.type fputws, %function
	.thumb_func
fputws:
	movw r12, #135
	b ws1_resolver
	.align 2

	.global fread
	.type fread, %function
	.thumb_func
fread:
	movw r12, #136
	b ws1_resolver
	.align 2

	.global free
	.type free, %function
	.thumb_func
free:
	movw r12, #137
	b ws1_resolver
	.align 2

	.global freopen
	.type freopen, %function
	.thumb_func
freopen:
	movw r12, #138
	b ws1_resolver
	.align 2

	.global freopen64
	.type freopen64, %function
	.thumb_func
freopen64:
	movw r12, #139
	b ws1_resolver
	.align 2

	.global fscanf
	.type fscanf, %function
	.thumb_func
fscanf:
	movw r12, #140
	b ws1_resolver
	.align 2

	.global fseek
	.type fseek, %function
	.thumb_func
fseek:
	movw r12, #141
	b ws1_resolver
	.align 2

	.global fseeko
	.type fseeko, %function
	.thumb_func
fseeko:
	movw r12, #142
	b ws1_resolver
	.align 2

	.global fseeko64
	.type fseeko64, %function
	.thumb_func
fseeko64:
	movw r12, #143
	b ws1_resolver
	.align 2

	.global fsetpos
	.type fsetpos, %function
	.thumb_func
fsetpos:
	movw r12, #144
	b ws1_resolver
	.align 2

	.global fstatvfs
	.type fstatvfs, %function
	.thumb_func
fstatvfs:
	movw r12, #145
	b ws1_resolver
	.align 2

	.global fstatvfs64
	.type fstatvfs64, %function
	.thumb_func
fstatvfs64:
	movw r12, #146
	b ws1_resolver
	.align 2

	.global fsync
	.type fsync, %function
	.thumb_func
fsync:
	movw r12, #147
	b ws1_resolver
	.align 2

	.global ftell
	.type ftell, %function
	.thumb_func
ftell:
	movw r12, #148
	b ws1_resolver
	.align 2

	.global ftello
	.type ftello, %function
	.thumb_func
ftello:
	movw r12, #149
	b ws1_resolver
	.align 2

	.global ftello64
	.type ftello64, %function
	.thumb_func
ftello64:
	movw r12, #150
	b ws1_resolver
	.align 2

	.global ftime
	.type ftime, %function
	.thumb_func
ftime:
	movw r12, #151
	b ws1_resolver
	.align 2

	.global ftok
	.type ftok, %function
	.thumb_func
ftok:
	movw r12, #152
	b ws1_resolver
	.align 2

	.global ftruncate
	.type ftruncate, %function
	.thumb_func
ftruncate:
	movw r12, #153
	b ws1_resolver
	.align 2

	.global ftruncate64
	.type ftruncate64, %function
	.thumb_func
ftruncate64:
	movw r12, #154
	b ws1_resolver
	.align 2

	.global ftrylockfile
	.type ftrylockfile, %function
	.thumb_func
ftrylockfile:
	movw r12, #155
	b ws1_resolver
	.align 2

	.global ftw
	.type ftw, %function
	.thumb_func
ftw:
	movw r12, #156
	b ws1_resolver
	.align 2

	.global ftw64
	.type ftw64, %function
	.thumb_func
ftw64:
	movw r12, #157
	b ws1_resolver
	.align 2

	.global funlockfile
	.type funlockfile, %function
	.thumb_func
funlockfile:
	movw r12, #158
	b ws1_resolver
	.align 2

	.global fwide
	.type fwide, %function
	.thumb_func
fwide:
	movw r12, #159
	b ws1_resolver
	.align 2

	.global fwprintf
	.type fwprintf, %function
	.thumb_func
fwprintf:
	movw r12, #160
	b ws1_resolver
	.align 2

	.global fwrite
	.type fwrite, %function
	.thumb_func
fwrite:
	movw r12, #161
	b ws1_resolver
	.align 2

	.global fwscanf
	.type fwscanf, %function
	.thumb_func
fwscanf:
	movw r12, #162
	b ws1_resolver
	.align 2

	.global getc
	.type getc, %function
	.thumb_func
getc:
	movw r12, #163
	b ws1_resolver
	.align 2

	.global getc_unlocked
	.type getc_unlocked, %function
	.thumb_func
getc_unlocked:
	movw r12, #164
	b ws1_resolver
	.align 2

	.global getchar
	.type getchar, %function
	.thumb_func
getchar:
	movw r12, #165
	b ws1_resolver
	.align 2

	.global getchar_unlocked
	.type getchar_unlocked, %function
	.thumb_func
getchar_unlocked:
	movw r12, #166
	b ws1_resolver
	.align 2

	.global getcwd
	.type getcwd, %function
	.thumb_func
getcwd:
	movw r12, #167
	b ws1_resolver
	.align 2

	.global getdtablesize
	.type getdtablesize, %function
	.thumb_func
getdtablesize:
	movw r12, #168
	b ws1_resolver
	.align 2

	.global getenv
	.type getenv, %function
	.thumb_func
getenv:
	movw r12, #169
	b ws1_resolver
	.align 2

	.global getgrent
	.type getgrent, %function
	.thumb_func
getgrent:
	movw r12, #170
	b ws1_resolver
	.align 2

	.global getgrgid_r
	.type getgrgid_r, %function
	.thumb_func
getgrgid_r:
	movw r12, #171
	b ws1_resolver
	.align 2

	.global getgrnam_r
	.type getgrnam_r, %function
	.thumb_func
getgrnam_r:
	movw r12, #172
	b ws1_resolver
	.align 2

	.global gethostname
	.type gethostname, %function
	.thumb_func
gethostname:
	movw r12, #173
	b ws1_resolver
	.align 2

	.global getitimer
	.type getitimer, %function
	.thumb_func
getitimer:
	movw r12, #174
	b ws1_resolver
	.align 2

	.global getopt
	.type getopt, %function
	.thumb_func
getopt:
	movw r12, #175
	b ws1_resolver
	.align 2

	.global getopt_long
	.type getopt_long, %function
	.thumb_func
getopt_long:
	movw r12, #176
	b ws1_resolver
	.align 2

	.global getopt_long_only
	.type getopt_long_only, %function
	.thumb_func
getopt_long_only:
	movw r12, #177
	b ws1_resolver
	.align 2

	.global getpagesize
	.type getpagesize, %function
	.thumb_func
getpagesize:
	movw r12, #178
	b ws1_resolver
	.align 2

	.global getpgid
	.type getpgid, %function
	.thumb_func
getpgid:
	movw r12, #179
	b ws1_resolver
	.align 2

	.global getpgrp
	.type getpgrp, %function
	.thumb_func
getpgrp:
	movw r12, #180
	b ws1_resolver
	.align 2

	.global getpid
	.type getpid, %function
	.thumb_func
getpid:
	movw r12, #181
	b ws1_resolver
	.align 2

	.global getppid
	.type getppid, %function
	.thumb_func
getppid:
	movw r12, #182
	b ws1_resolver
	.align 2

	.global getpwent
	.type getpwent, %function
	.thumb_func
getpwent:
	movw r12, #183
	b ws1_resolver
	.align 2

	.global getrlimit
	.type getrlimit, %function
	.thumb_func
getrlimit:
	movw r12, #184
	b ws1_resolver
	.align 2

	.global getrlimit64
	.type getrlimit64, %function
	.thumb_func
getrlimit64:
	movw r12, #185
	b ws1_resolver
	.align 2

	.global getrusage
	.type getrusage, %function
	.thumb_func
getrusage:
	movw r12, #186
	b ws1_resolver
	.align 2

	.global gets
	.type gets, %function
	.thumb_func
gets:
	movw r12, #187
	b ws1_resolver
	.align 2

	.global getsid
	.type getsid, %function
	.thumb_func
getsid:
	movw r12, #188
	b ws1_resolver
	.align 2

	.global getsubopt
	.type getsubopt, %function
	.thumb_func
getsubopt:
	movw r12, #189
	b ws1_resolver
	.align 2

	.global gettid
	.type gettid, %function
	.thumb_func
gettid:
	movw r12, #190
	b ws1_resolver
	.align 2

	.global gettimeofday
	.type gettimeofday, %function
	.thumb_func
gettimeofday:
	movw r12, #191
	b ws1_resolver
	.align 2

	.global getwc
	.type getwc, %function
	.thumb_func
getwc:
	movw r12, #192
	b ws1_resolver
	.align 2

	.global getwchar
	.type getwchar, %function
	.thumb_func
getwchar:
	movw r12, #193
	b ws1_resolver
	.align 2

	.global hcreate
	.type hcreate, %function
	.thumb_func
hcreate:
	movw r12, #194
	b ws1_resolver
	.align 2

	.global hdestroy
	.type hdestroy, %function
	.thumb_func
hdestroy:
	movw r12, #195
	b ws1_resolver
	.align 2

	.global hsearch
	.type hsearch, %function
	.thumb_func
hsearch:
	movw r12, #196
	b ws1_resolver
	.align 2

	.global htonl
	.type htonl, %function
	.thumb_func
htonl:
	movw r12, #197
	b ws1_resolver
	.align 2

	.global htons
	.type htons, %function
	.thumb_func
htons:
	movw r12, #198
	b ws1_resolver
	.align 2

	.global index
	.type index, %function
	.thumb_func
index:
	movw r12, #199
	b ws1_resolver
	.align 2

	.global inet_addr
	.type inet_addr, %function
	.thumb_func
inet_addr:
	movw r12, #200
	b ws1_resolver
	.align 2

	.global inet_aton
	.type inet_aton, %function
	.thumb_func
inet_aton:
	movw r12, #201
	b ws1_resolver
	.align 2

	.global inet_ntop
	.type inet_ntop, %function
	.thumb_func
inet_ntop:
	movw r12, #202
	b ws1_resolver
	.align 2

	.global inet_pton
	.type inet_pton, %function
	.thumb_func
inet_pton:
	movw r12, #203
	b ws1_resolver
	.align 2

	.global initgroups
	.type initgroups, %function
	.thumb_func
initgroups:
	movw r12, #204
	b ws1_resolver
	.align 2

	.global inotify_add_watch
	.type inotify_add_watch, %function
	.thumb_func
inotify_add_watch:
	movw r12, #205
	b ws1_resolver
	.align 2

	.global inotify_init
	.type inotify_init, %function
	.thumb_func
inotify_init:
	movw r12, #206
	b ws1_resolver
	.align 2

	.global inotify_rm_watch
	.type inotify_rm_watch, %function
	.thumb_func
inotify_rm_watch:
	movw r12, #207
	b ws1_resolver
	.align 2

	.global ioctl
	.type ioctl, %function
	.thumb_func
ioctl:
	movw r12, #208
	b ws1_resolver
	.align 2

	.global isalnum
	.type isalnum, %function
	.thumb_func
isalnum:
	movw r12, #209
	b ws1_resolver
	.align 2

	.global isalpha
	.type isalpha, %function
	.thumb_func
isalpha:
	movw r12, #210
	b ws1_resolver
	.align 2

	.global isascii
	.type isascii, %function
	.thumb_func
isascii:
	movw r12, #211
	b ws1_resolver
	.align 2

	.global isatty
	.type isatty, %function
	.thumb_func
isatty:
	movw r12, #212
	b ws1_resolver
	.align 2

	.global isblank
	.type isblank, %function
	.thumb_func
isblank:
	movw r12, #213
	b ws1_resolver
	.align 2

	.global iscntrl
	.type iscntrl, %function
	.thumb_func
iscntrl:
	movw r12, #214
	b ws1_resolver
	.align 2

	.global isdigit
	.type isdigit, %function
	.thumb_func
isdigit:
	movw r12, #215
	b ws1_resolver
	.align 2

	.global isgraph
	.type isgraph, %function
	.thumb_func
isgraph:
	movw r12, #216
	b ws1_resolver
	.align 2

	.global islower
	.type islower, %function
	.thumb_func
islower:
	movw r12, #217
	b ws1_resolver
	.align 2

	.global isprint
	.type isprint, %function
	.thumb_func
isprint:
	movw r12, #218
	b ws1_resolver
	.align 2

	.global ispunct
	.type ispunct, %function
	.thumb_func
ispunct:
	movw r12, #219
	b ws1_resolver
	.align 2

	.global isspace
	.type isspace, %function
	.thumb_func
isspace:
	movw r12, #220
	b ws1_resolver
	.align 2

	.global isupper
	.type isupper, %function
	.thumb_func
isupper:
	movw r12, #221
	b ws1_resolver
	.align 2

	.global iswalnum
	.type iswalnum, %function
	.thumb_func
iswalnum:
	movw r12, #222
	b ws1_resolver
	.align 2

	.global iswalpha
	.type iswalpha, %function
	.thumb_func
iswalpha:
	movw r12, #223
	b ws1_resolver
	.align 2

	.global iswblank
	.type iswblank, %function
	.thumb_func
iswblank:
	movw r12, #224
	b ws1_resolver
	.align 2

	.global iswcntrl
	.type iswcntrl, %function
	.thumb_func
iswcntrl:
	movw r12, #225
	b ws1_resolver
	.align 2

	.global iswctype
	.type iswctype, %function
	.thumb_func
iswctype:
	movw r12, #226
	b ws1_resolver
	.align 2

	.global iswdigit
	.type iswdigit, %function
	.thumb_func
iswdigit:
	movw r12, #227
	b ws1_resolver
	.align 2

	.global iswgraph
	.type iswgraph, %function
	.thumb_func
iswgraph:
	movw r12, #228
	b ws1_resolver
	.align 2

	.global iswlower
	.type iswlower, %function
	.thumb_func
iswlower:
	movw r12, #229
	b ws1_resolver
	.align 2

	.global iswprint
	.type iswprint, %function
	.thumb_func
iswprint:
	movw r12, #230
	b ws1_resolver
	.align 2

	.global iswpunct
	.type iswpunct, %function
	.thumb_func
iswpunct:
	movw r12, #231
	b ws1_resolver
	.align 2

	.global iswspace
	.type iswspace, %function
	.thumb_func
iswspace:
	movw r12, #232
	b ws1_resolver
	.align 2

	.global iswupper
	.type iswupper, %function
	.thumb_func
iswupper:
	movw r12, #233
	b ws1_resolver
	.align 2

	.global iswxdigit
	.type iswxdigit, %function
	.thumb_func
iswxdigit:
	movw r12, #234
	b ws1_resolver
	.align 2

	.global isxdigit
	.type isxdigit, %function
	.thumb_func
isxdigit:
	movw r12, #235
	b ws1_resolver
	.align 2

	.global jrand48
	.type jrand48, %function
	.thumb_func
jrand48:
	movw r12, #236
	b ws1_resolver
	.align 2

	.global kill
	.type kill, %function
	.thumb_func
kill:
	movw r12, #237
	b ws1_resolver
	.align 2

	.global killpg
	.type killpg, %function
	.thumb_func
killpg:
	movw r12, #238
	b ws1_resolver
	.align 2

	.global labs
	.type labs, %function
	.thumb_func
labs:
	movw r12, #239
	b ws1_resolver
	.align 2

	.global lcong48
	.type lcong48, %function
	.thumb_func
lcong48:
	movw r12, #240
	b ws1_resolver
	.align 2

	.global ldiv
	.type ldiv, %function
	.thumb_func
ldiv:
	movw r12, #241
	b ws1_resolver
	.align 2

	.global lfind
	.type lfind, %function
	.thumb_func
lfind:
	movw r12, #242
	b ws1_resolver
	.align 2

	.global link
	.type link, %function
	.thumb_func
link:
	movw r12, #243
	b ws1_resolver
	.align 2

	.global llabs
	.type llabs, %function
	.thumb_func
llabs:
	movw r12, #244
	b ws1_resolver
	.align 2

	.global lldiv
	.type lldiv, %function
	.thumb_func
lldiv:
	movw r12, #245
	b ws1_resolver
	.align 2

	.global localeconv
	.type localeconv, %function
	.thumb_func
localeconv:
	movw r12, #246
	b ws1_resolver
	.align 2

	.global lockf
	.type lockf, %function
	.thumb_func
lockf:
	movw r12, #247
	b ws1_resolver
	.align 2

	.global lockf64
	.type lockf64, %function
	.thumb_func
lockf64:
	movw r12, #248
	b ws1_resolver
	.align 2

	.global longjmp
	.type longjmp, %function
	.thumb_func
longjmp:
	movw r12, #249
	b ws1_resolver
	.align 2

	.global lrand48
	.type lrand48, %function
	.thumb_func
lrand48:
	movw r12, #250
	b ws1_resolver
	.align 2

	.global lsearch
	.type lsearch, %function
	.thumb_func
lsearch:
	movw r12, #251
	b ws1_resolver
	.align 2

	.global lseek
	.type lseek, %function
	.thumb_func
lseek:
	movw r12, #252
	b ws1_resolver
	.align 2

	.global lseek64
	.type lseek64, %function
	.thumb_func
lseek64:
	movw r12, #253
	b ws1_resolver
	.align 2

	.global mallinfo
	.type mallinfo, %function
	.thumb_func
mallinfo:
	movw r12, #254
	b ws1_resolver
	.align 2

	.global malloc
	.type malloc, %function
	.thumb_func
malloc:
	movw r12, #255
	b ws1_resolver
	.align 2

	.global mallopt
	.type mallopt, %function
	.thumb_func
mallopt:
	movw r12, #256
	b ws1_resolver
	.align 2

	.global mblen
	.type mblen, %function
	.thumb_func
mblen:
	movw r12, #257
	b ws1_resolver
	.align 2

	.global mbrlen
	.type mbrlen, %function
	.thumb_func
mbrlen:
	movw r12, #258
	b ws1_resolver
	.align 2

	.global mbrtoc16
	.type mbrtoc16, %function
	.thumb_func
mbrtoc16:
	movw r12, #259
	b ws1_resolver
	.align 2

	.global mbrtoc32
	.type mbrtoc32, %function
	.thumb_func
mbrtoc32:
	movw r12, #260
	b ws1_resolver
	.align 2

	.global mbrtowc
	.type mbrtowc, %function
	.thumb_func
mbrtowc:
	movw r12, #261
	b ws1_resolver
	.align 2

	.global mbsinit
	.type mbsinit, %function
	.thumb_func
mbsinit:
	movw r12, #262
	b ws1_resolver
	.align 2

	.global mbsrtowcs
	.type mbsrtowcs, %function
	.thumb_func
mbsrtowcs:
	movw r12, #263
	b ws1_resolver
	.align 2

	.global mbstowcs
	.type mbstowcs, %function
	.thumb_func
mbstowcs:
	movw r12, #264
	b ws1_resolver
	.align 2

	.global mbtowc
	.type mbtowc, %function
	.thumb_func
mbtowc:
	movw r12, #265
	b ws1_resolver
	.align 2

	.global memalign
	.type memalign, %function
	.thumb_func
memalign:
	movw r12, #266
	b ws1_resolver
	.align 2

	.global memccpy
	.type memccpy, %function
	.thumb_func
memccpy:
	movw r12, #267
	b ws1_resolver
	.align 2

	.global memchr
	.type memchr, %function
	.thumb_func
memchr:
	movw r12, #268
	b ws1_resolver
	.align 2

	.global memcpy
	.type memcpy, %function
	.thumb_func
memcpy:
	movw r12, #269
	b ws1_resolver
	.align 2

	.global memmove
	.type memmove, %function
	.thumb_func
memmove:
	movw r12, #270
	b ws1_resolver
	.align 2

	.global memset
	.type memset, %function
	.thumb_func
memset:
	movw r12, #271
	b ws1_resolver
	.align 2

	.global mkfifo
	.type mkfifo, %function
	.thumb_func
mkfifo:
	movw r12, #272
	b ws1_resolver
	.align 2

	.global mkstemp
	.type mkstemp, %function
	.thumb_func
mkstemp:
	movw r12, #273
	b ws1_resolver
	.align 2

	.global mktemp
	.type mktemp, %function
	.thumb_func
mktemp:
	movw r12, #274
	b ws1_resolver
	.align 2

	.global mlock
	.type mlock, %function
	.thumb_func
mlock:
	movw r12, #275
	b ws1_resolver
	.align 2

	.global mlockall
	.type mlockall, %function
	.thumb_func
mlockall:
	movw r12, #276
	b ws1_resolver
	.align 2

	.global mmap
	.type mmap, %function
	.thumb_func
mmap:
	movw r12, #277
	b ws1_resolver
	.align 2

	.global mmap64
	.type mmap64, %function
	.thumb_func
mmap64:
	movw r12, #278
	b ws1_resolver
	.align 2

	.global mount
	.type mount, %function
	.thumb_func
mount:
	movw r12, #279
	b ws1_resolver
	.align 2

	.global mprotect
	.type mprotect, %function
	.thumb_func
mprotect:
	movw r12, #280
	b ws1_resolver
	.align 2

	.global mrand48
	.type mrand48, %function
	.thumb_func
mrand48:
	movw r12, #281
	b ws1_resolver
	.align 2

	.global msync
	.type msync, %function
	.thumb_func
msync:
	movw r12, #282
	b ws1_resolver
	.align 2

	.global munlock
	.type munlock, %function
	.thumb_func
munlock:
	movw r12, #283
	b ws1_resolver
	.align 2

	.global munlockall
	.type munlockall, %function
	.thumb_func
munlockall:
	movw r12, #284
	b ws1_resolver
	.align 2

	.global munmap
	.type munmap, %function
	.thumb_func
munmap:
	movw r12, #285
	b ws1_resolver
	.align 2

	.global nanosleep
	.type nanosleep, %function
	.thumb_func
nanosleep:
	movw r12, #286
	b ws1_resolver
	.align 2

	.global nftw
	.type nftw, %function
	.thumb_func
nftw:
	movw r12, #287
	b ws1_resolver
	.align 2

	.global nftw64
	.type nftw64, %function
	.thumb_func
nftw64:
	movw r12, #288
	b ws1_resolver
	.align 2

	.global nice
	.type nice, %function
	.thumb_func
nice:
	movw r12, #289
	b ws1_resolver
	.align 2

	.global nrand48
	.type nrand48, %function
	.thumb_func
nrand48:
	movw r12, #290
	b ws1_resolver
	.align 2

	.global ntohl
	.type ntohl, %function
	.thumb_func
ntohl:
	movw r12, #291
	b ws1_resolver
	.align 2

	.global ntohs
	.type ntohs, %function
	.thumb_func
ntohs:
	movw r12, #292
	b ws1_resolver
	.align 2

	.global openlog
	.type openlog, %function
	.thumb_func
openlog:
	movw r12, #293
	b ws1_resolver
	.align 2

	.global optarg
	.type optarg, %function
	.thumb_func
optarg:
	movw r12, #294
	b ws1_resolver
	.align 2

	.global opterr
	.type opterr, %function
	.thumb_func
opterr:
	movw r12, #295
	b ws1_resolver
	.align 2

	.global optind
	.type optind, %function
	.thumb_func
optind:
	movw r12, #296
	b ws1_resolver
	.align 2

	.global optopt
	.type optopt, %function
	.thumb_func
optopt:
	movw r12, #297
	b ws1_resolver
	.align 2

	.global optreset
	.type optreset, %function
	.thumb_func
optreset:
	movw r12, #298
	b ws1_resolver
	.align 2

	.global pathconf
	.type pathconf, %function
	.thumb_func
pathconf:
	movw r12, #299
	b ws1_resolver
	.align 2

	.global pause
	.type pause, %function
	.thumb_func
pause:
	movw r12, #300
	b ws1_resolver
	.align 2

	.global perror
	.type perror, %function
	.thumb_func
perror:
	movw r12, #301
	b ws1_resolver
	.align 2

	.global pipe
	.type pipe, %function
	.thumb_func
pipe:
	movw r12, #302
	b ws1_resolver
	.align 2

	.global posix_fadvise
	.type posix_fadvise, %function
	.thumb_func
posix_fadvise:
	movw r12, #303
	b ws1_resolver
	.align 2

	.global posix_fadvise64
	.type posix_fadvise64, %function
	.thumb_func
posix_fadvise64:
	movw r12, #304
	b ws1_resolver
	.align 2

	.global posix_fallocate
	.type posix_fallocate, %function
	.thumb_func
posix_fallocate:
	movw r12, #305
	b ws1_resolver
	.align 2

	.global posix_fallocate64
	.type posix_fallocate64, %function
	.thumb_func
posix_fallocate64:
	movw r12, #306
	b ws1_resolver
	.align 2

	.global posix_madvise
	.type posix_madvise, %function
	.thumb_func
posix_madvise:
	movw r12, #307
	b ws1_resolver
	.align 2

	.global posix_memalign
	.type posix_memalign, %function
	.thumb_func
posix_memalign:
	movw r12, #308
	b ws1_resolver
	.align 2

	.global posix_spawn
	.type posix_spawn, %function
	.thumb_func
posix_spawn:
	movw r12, #309
	b ws1_resolver
	.align 2

	.global posix_spawn_file_actions_addclose
	.type posix_spawn_file_actions_addclose, %function
	.thumb_func
posix_spawn_file_actions_addclose:
	movw r12, #310
	b ws1_resolver
	.align 2

	.global posix_spawn_file_actions_adddup2
	.type posix_spawn_file_actions_adddup2, %function
	.thumb_func
posix_spawn_file_actions_adddup2:
	movw r12, #311
	b ws1_resolver
	.align 2

	.global posix_spawn_file_actions_addopen
	.type posix_spawn_file_actions_addopen, %function
	.thumb_func
posix_spawn_file_actions_addopen:
	movw r12, #312
	b ws1_resolver
	.align 2

	.global posix_spawn_file_actions_destroy
	.type posix_spawn_file_actions_destroy, %function
	.thumb_func
posix_spawn_file_actions_destroy:
	movw r12, #313
	b ws1_resolver
	.align 2

	.global posix_spawn_file_actions_init
	.type posix_spawn_file_actions_init, %function
	.thumb_func
posix_spawn_file_actions_init:
	movw r12, #314
	b ws1_resolver
	.align 2

	.global posix_spawnattr_destroy
	.type posix_spawnattr_destroy, %function
	.thumb_func
posix_spawnattr_destroy:
	movw r12, #315
	b ws1_resolver
	.align 2

	.global posix_spawnattr_getflags
	.type posix_spawnattr_getflags, %function
	.thumb_func
posix_spawnattr_getflags:
	movw r12, #316
	b ws1_resolver
	.align 2

	.global posix_spawnattr_getpgroup
	.type posix_spawnattr_getpgroup, %function
	.thumb_func
posix_spawnattr_getpgroup:
	movw r12, #317
	b ws1_resolver
	.align 2

	.global posix_spawnattr_getschedparam
	.type posix_spawnattr_getschedparam, %function
	.thumb_func
posix_spawnattr_getschedparam:
	movw r12, #318
	b ws1_resolver
	.align 2

	.global posix_spawnattr_getschedpolicy
	.type posix_spawnattr_getschedpolicy, %function
	.thumb_func
posix_spawnattr_getschedpolicy:
	movw r12, #319
	b ws1_resolver
	.align 2

	.global posix_spawnattr_getsigdefault
	.type posix_spawnattr_getsigdefault, %function
	.thumb_func
posix_spawnattr_getsigdefault:
	movw r12, #320
	b ws1_resolver
	.align 2

	.global posix_spawnattr_getsigmask
	.type posix_spawnattr_getsigmask, %function
	.thumb_func
posix_spawnattr_getsigmask:
	movw r12, #321
	b ws1_resolver
	.align 2

	.global posix_spawnattr_init
	.type posix_spawnattr_init, %function
	.thumb_func
posix_spawnattr_init:
	movw r12, #322
	b ws1_resolver
	.align 2

	.global posix_spawnattr_setflags
	.type posix_spawnattr_setflags, %function
	.thumb_func
posix_spawnattr_setflags:
	movw r12, #323
	b ws1_resolver
	.align 2

	.global posix_spawnattr_setpgroup
	.type posix_spawnattr_setpgroup, %function
	.thumb_func
posix_spawnattr_setpgroup:
	movw r12, #324
	b ws1_resolver
	.align 2

	.global posix_spawnattr_setschedparam
	.type posix_spawnattr_setschedparam, %function
	.thumb_func
posix_spawnattr_setschedparam:
	movw r12, #325
	b ws1_resolver
	.align 2

	.global posix_spawnattr_setschedpolicy
	.type posix_spawnattr_setschedpolicy, %function
	.thumb_func
posix_spawnattr_setschedpolicy:
	movw r12, #326
	b ws1_resolver
	.align 2

	.global posix_spawnattr_setsigdefault
	.type posix_spawnattr_setsigdefault, %function
	.thumb_func
posix_spawnattr_setsigdefault:
	movw r12, #327
	b ws1_resolver
	.align 2

	.global posix_spawnattr_setsigmask
	.type posix_spawnattr_setsigmask, %function
	.thumb_func
posix_spawnattr_setsigmask:
	movw r12, #328
	b ws1_resolver
	.align 2

	.global posix_spawnp
	.type posix_spawnp, %function
	.thumb_func
posix_spawnp:
	movw r12, #329
	b ws1_resolver
	.align 2

	.global pread
	.type pread, %function
	.thumb_func
pread:
	movw r12, #330
	b ws1_resolver
	.align 2

	.global pread64
	.type pread64, %function
	.thumb_func
pread64:
	movw r12, #331
	b ws1_resolver
	.align 2

	.global printf
	.type printf, %function
	.thumb_func
printf:
	movw r12, #332
	b ws1_resolver
	.align 2

	.global pthread_atfork
	.type pthread_atfork, %function
	.thumb_func
pthread_atfork:
	movw r12, #333
	b ws1_resolver
	.align 2

	.global pthread_attr_destroy
	.type pthread_attr_destroy, %function
	.thumb_func
pthread_attr_destroy:
	movw r12, #334
	b ws1_resolver
	.align 2

	.global pthread_attr_getdetachstate
	.type pthread_attr_getdetachstate, %function
	.thumb_func
pthread_attr_getdetachstate:
	movw r12, #335
	b ws1_resolver
	.align 2

	.global pthread_attr_getguardsize
	.type pthread_attr_getguardsize, %function
	.thumb_func
pthread_attr_getguardsize:
	movw r12, #336
	b ws1_resolver
	.align 2

	.global pthread_attr_getinheritsched
	.type pthread_attr_getinheritsched, %function
	.thumb_func
pthread_attr_getinheritsched:
	movw r12, #337
	b ws1_resolver
	.align 2

	.global pthread_attr_getschedparam
	.type pthread_attr_getschedparam, %function
	.thumb_func
pthread_attr_getschedparam:
	movw r12, #338
	b ws1_resolver
	.align 2

	.global pthread_attr_getschedpolicy
	.type pthread_attr_getschedpolicy, %function
	.thumb_func
pthread_attr_getschedpolicy:
	movw r12, #339
	b ws1_resolver
	.align 2

	.global pthread_attr_getscope
	.type pthread_attr_getscope, %function
	.thumb_func
pthread_attr_getscope:
	movw r12, #340
	b ws1_resolver
	.align 2

	.global pthread_attr_getstack
	.type pthread_attr_getstack, %function
	.thumb_func
pthread_attr_getstack:
	movw r12, #341
	b ws1_resolver
	.align 2

	.global pthread_attr_getstackaddr
	.type pthread_attr_getstackaddr, %function
	.thumb_func
pthread_attr_getstackaddr:
	movw r12, #342
	b ws1_resolver
	.align 2

	.global pthread_attr_getstacksize
	.type pthread_attr_getstacksize, %function
	.thumb_func
pthread_attr_getstacksize:
	movw r12, #343
	b ws1_resolver
	.align 2

	.global pthread_attr_setdetachstate
	.type pthread_attr_setdetachstate, %function
	.thumb_func
pthread_attr_setdetachstate:
	movw r12, #344
	b ws1_resolver
	.align 2

	.global pthread_attr_setguardsize
	.type pthread_attr_setguardsize, %function
	.thumb_func
pthread_attr_setguardsize:
	movw r12, #345
	b ws1_resolver
	.align 2

	.global pthread_attr_setinheritsched
	.type pthread_attr_setinheritsched, %function
	.thumb_func
pthread_attr_setinheritsched:
	movw r12, #346
	b ws1_resolver
	.align 2

	.global pthread_attr_setschedparam
	.type pthread_attr_setschedparam, %function
	.thumb_func
pthread_attr_setschedparam:
	movw r12, #347
	b ws1_resolver
	.align 2

	.global pthread_attr_setschedpolicy
	.type pthread_attr_setschedpolicy, %function
	.thumb_func
pthread_attr_setschedpolicy:
	movw r12, #348
	b ws1_resolver
	.align 2

	.global pthread_attr_setscope
	.type pthread_attr_setscope, %function
	.thumb_func
pthread_attr_setscope:
	movw r12, #349
	b ws1_resolver
	.align 2

	.global pthread_attr_setstack
	.type pthread_attr_setstack, %function
	.thumb_func
pthread_attr_setstack:
	movw r12, #350
	b ws1_resolver
	.align 2

	.global pthread_attr_setstackaddr
	.type pthread_attr_setstackaddr, %function
	.thumb_func
pthread_attr_setstackaddr:
	movw r12, #351
	b ws1_resolver
	.align 2

	.global pthread_attr_setstacksize
	.type pthread_attr_setstacksize, %function
	.thumb_func
pthread_attr_setstacksize:
	movw r12, #352
	b ws1_resolver
	.align 2

	.global pthread_barrier_destroy
	.type pthread_barrier_destroy, %function
	.thumb_func
pthread_barrier_destroy:
	movw r12, #353
	b ws1_resolver
	.align 2

	.global pthread_barrier_init
	.type pthread_barrier_init, %function
	.thumb_func
pthread_barrier_init:
	movw r12, #354
	b ws1_resolver
	.align 2

	.global pthread_barrier_wait
	.type pthread_barrier_wait, %function
	.thumb_func
pthread_barrier_wait:
	movw r12, #355
	b ws1_resolver
	.align 2

	.global pthread_barrierattr_destroy
	.type pthread_barrierattr_destroy, %function
	.thumb_func
pthread_barrierattr_destroy:
	movw r12, #356
	b ws1_resolver
	.align 2

	.global pthread_barrierattr_getpshared
	.type pthread_barrierattr_getpshared, %function
	.thumb_func
pthread_barrierattr_getpshared:
	movw r12, #357
	b ws1_resolver
	.align 2

	.global pthread_barrierattr_init
	.type pthread_barrierattr_init, %function
	.thumb_func
pthread_barrierattr_init:
	movw r12, #358
	b ws1_resolver
	.align 2

	.global pthread_barrierattr_setpshared
	.type pthread_barrierattr_setpshared, %function
	.thumb_func
pthread_barrierattr_setpshared:
	movw r12, #359
	b ws1_resolver
	.align 2

	.global pthread_cond_broadcast
	.type pthread_cond_broadcast, %function
	.thumb_func
pthread_cond_broadcast:
	movw r12, #360
	b ws1_resolver
	.align 2

	.global pthread_cond_destroy
	.type pthread_cond_destroy, %function
	.thumb_func
pthread_cond_destroy:
	movw r12, #361
	b ws1_resolver
	.align 2

	.global pthread_cond_init
	.type pthread_cond_init, %function
	.thumb_func
pthread_cond_init:
	movw r12, #362
	b ws1_resolver
	.align 2

	.global pthread_cond_signal
	.type pthread_cond_signal, %function
	.thumb_func
pthread_cond_signal:
	movw r12, #363
	b ws1_resolver
	.align 2

	.global pthread_cond_timedwait
	.type pthread_cond_timedwait, %function
	.thumb_func
pthread_cond_timedwait:
	movw r12, #364
	b ws1_resolver
	.align 2

	.global pthread_cond_wait
	.type pthread_cond_wait, %function
	.thumb_func
pthread_cond_wait:
	movw r12, #365
	b ws1_resolver
	.align 2

	.global pthread_condattr_destroy
	.type pthread_condattr_destroy, %function
	.thumb_func
pthread_condattr_destroy:
	movw r12, #366
	b ws1_resolver
	.align 2

	.global pthread_condattr_getclock
	.type pthread_condattr_getclock, %function
	.thumb_func
pthread_condattr_getclock:
	movw r12, #367
	b ws1_resolver
	.align 2

	.global pthread_condattr_getpshared
	.type pthread_condattr_getpshared, %function
	.thumb_func
pthread_condattr_getpshared:
	movw r12, #368
	b ws1_resolver
	.align 2

	.global pthread_condattr_init
	.type pthread_condattr_init, %function
	.thumb_func
pthread_condattr_init:
	movw r12, #369
	b ws1_resolver
	.align 2

	.global pthread_condattr_setclock
	.type pthread_condattr_setclock, %function
	.thumb_func
pthread_condattr_setclock:
	movw r12, #370
	b ws1_resolver
	.align 2

	.global pthread_condattr_setpshared
	.type pthread_condattr_setpshared, %function
	.thumb_func
pthread_condattr_setpshared:
	movw r12, #371
	b ws1_resolver
	.align 2

	.global pthread_detach
	.type pthread_detach, %function
	.thumb_func
pthread_detach:
	movw r12, #372
	b ws1_resolver
	.align 2

	.global pthread_equal
	.type pthread_equal, %function
	.thumb_func
pthread_equal:
	movw r12, #373
	b ws1_resolver
	.align 2

	.global pthread_exit
	.type pthread_exit, %function
	.thumb_func
pthread_exit:
	movw r12, #374
	b ws1_resolver
	.align 2

	.global pthread_getcpuclockid
	.type pthread_getcpuclockid, %function
	.thumb_func
pthread_getcpuclockid:
	movw r12, #375
	b ws1_resolver
	.align 2

	.global pthread_getname_np
	.type pthread_getname_np, %function
	.thumb_func
pthread_getname_np:
	movw r12, #376
	b ws1_resolver
	.align 2

	.global pthread_getschedparam
	.type pthread_getschedparam, %function
	.thumb_func
pthread_getschedparam:
	movw r12, #377
	b ws1_resolver
	.align 2

	.global pthread_getspecific
	.type pthread_getspecific, %function
	.thumb_func
pthread_getspecific:
	movw r12, #378
	b ws1_resolver
	.align 2

	.global pthread_join
	.type pthread_join, %function
	.thumb_func
pthread_join:
	movw r12, #379
	b ws1_resolver
	.align 2

	.global pthread_key_create
	.type pthread_key_create, %function
	.thumb_func
pthread_key_create:
	movw r12, #380
	b ws1_resolver
	.align 2

	.global pthread_key_delete
	.type pthread_key_delete, %function
	.thumb_func
pthread_key_delete:
	movw r12, #381
	b ws1_resolver
	.align 2

	.global pthread_kill
	.type pthread_kill, %function
	.thumb_func
pthread_kill:
	movw r12, #382
	b ws1_resolver
	.align 2

	.global pthread_mutex_destroy
	.type pthread_mutex_destroy, %function
	.thumb_func
pthread_mutex_destroy:
	movw r12, #383
	b ws1_resolver
	.align 2

	.global pthread_mutex_init
	.type pthread_mutex_init, %function
	.thumb_func
pthread_mutex_init:
	movw r12, #384
	b ws1_resolver
	.align 2

	.global pthread_mutex_lock
	.type pthread_mutex_lock, %function
	.thumb_func
pthread_mutex_lock:
	movw r12, #385
	b ws1_resolver
	.align 2

	.global pthread_mutex_timedlock
	.type pthread_mutex_timedlock, %function
	.thumb_func
pthread_mutex_timedlock:
	movw r12, #386
	b ws1_resolver
	.align 2

	.global pthread_mutex_trylock
	.type pthread_mutex_trylock, %function
	.thumb_func
pthread_mutex_trylock:
	movw r12, #387
	b ws1_resolver
	.align 2

	.global pthread_mutex_unlock
	.type pthread_mutex_unlock, %function
	.thumb_func
pthread_mutex_unlock:
	movw r12, #388
	b ws1_resolver
	.align 2

	.global pthread_mutexattr_destroy
	.type pthread_mutexattr_destroy, %function
	.thumb_func
pthread_mutexattr_destroy:
	movw r12, #389
	b ws1_resolver
	.align 2

	.global pthread_mutexattr_getprotocol
	.type pthread_mutexattr_getprotocol, %function
	.thumb_func
pthread_mutexattr_getprotocol:
	movw r12, #390
	b ws1_resolver
	.align 2

	.global pthread_mutexattr_getpshared
	.type pthread_mutexattr_getpshared, %function
	.thumb_func
pthread_mutexattr_getpshared:
	movw r12, #391
	b ws1_resolver
	.align 2

	.global pthread_mutexattr_gettype
	.type pthread_mutexattr_gettype, %function
	.thumb_func
pthread_mutexattr_gettype:
	movw r12, #392
	b ws1_resolver
	.align 2

	.global pthread_mutexattr_init
	.type pthread_mutexattr_init, %function
	.thumb_func
pthread_mutexattr_init:
	movw r12, #393
	b ws1_resolver
	.align 2

	.global pthread_mutexattr_setprotocol
	.type pthread_mutexattr_setprotocol, %function
	.thumb_func
pthread_mutexattr_setprotocol:
	movw r12, #394
	b ws1_resolver
	.align 2

	.global pthread_mutexattr_setpshared
	.type pthread_mutexattr_setpshared, %function
	.thumb_func
pthread_mutexattr_setpshared:
	movw r12, #395
	b ws1_resolver
	.align 2

	.global pthread_mutexattr_settype
	.type pthread_mutexattr_settype, %function
	.thumb_func
pthread_mutexattr_settype:
	movw r12, #396
	b ws1_resolver
	.align 2

	.global pthread_once
	.type pthread_once, %function
	.thumb_func
pthread_once:
	movw r12, #397
	b ws1_resolver
	.align 2

	.global pthread_rwlock_destroy
	.type pthread_rwlock_destroy, %function
	.thumb_func
pthread_rwlock_destroy:
	movw r12, #398
	b ws1_resolver
	.align 2

	.global pthread_rwlock_init
	.type pthread_rwlock_init, %function
	.thumb_func
pthread_rwlock_init:
	movw r12, #399
	b ws1_resolver
	.align 2

	.global pthread_rwlock_rdlock
	.type pthread_rwlock_rdlock, %function
	.thumb_func
pthread_rwlock_rdlock:
	movw r12, #400
	b ws1_resolver
	.align 2

	.global pthread_rwlock_timedrdlock
	.type pthread_rwlock_timedrdlock, %function
	.thumb_func
pthread_rwlock_timedrdlock:
	movw r12, #401
	b ws1_resolver
	.align 2

	.global pthread_rwlock_timedwrlock
	.type pthread_rwlock_timedwrlock, %function
	.thumb_func
pthread_rwlock_timedwrlock:
	movw r12, #402
	b ws1_resolver
	.align 2

	.global pthread_rwlock_tryrdlock
	.type pthread_rwlock_tryrdlock, %function
	.thumb_func
pthread_rwlock_tryrdlock:
	movw r12, #403
	b ws1_resolver
	.align 2

	.global pthread_rwlock_trywrlock
	.type pthread_rwlock_trywrlock, %function
	.thumb_func
pthread_rwlock_trywrlock:
	movw r12, #404
	b ws1_resolver
	.align 2

	.global pthread_rwlock_unlock
	.type pthread_rwlock_unlock, %function
	.thumb_func
pthread_rwlock_unlock:
	movw r12, #405
	b ws1_resolver
	.align 2

	.global pthread_rwlock_wrlock
	.type pthread_rwlock_wrlock, %function
	.thumb_func
pthread_rwlock_wrlock:
	movw r12, #406
	b ws1_resolver
	.align 2

	.global pthread_rwlockattr_destroy
	.type pthread_rwlockattr_destroy, %function
	.thumb_func
pthread_rwlockattr_destroy:
	movw r12, #407
	b ws1_resolver
	.align 2

	.global pthread_rwlockattr_getpshared
	.type pthread_rwlockattr_getpshared, %function
	.thumb_func
pthread_rwlockattr_getpshared:
	movw r12, #408
	b ws1_resolver
	.align 2

	.global pthread_rwlockattr_init
	.type pthread_rwlockattr_init, %function
	.thumb_func
pthread_rwlockattr_init:
	movw r12, #409
	b ws1_resolver
	.align 2

	.global pthread_rwlockattr_setpshared
	.type pthread_rwlockattr_setpshared, %function
	.thumb_func
pthread_rwlockattr_setpshared:
	movw r12, #410
	b ws1_resolver
	.align 2

	.global pthread_self
	.type pthread_self, %function
	.thumb_func
pthread_self:
	movw r12, #411
	b ws1_resolver
	.align 2

	.global pthread_setname_np
	.type pthread_setname_np, %function
	.thumb_func
pthread_setname_np:
	movw r12, #412
	b ws1_resolver
	.align 2

	.global pthread_setschedparam
	.type pthread_setschedparam, %function
	.thumb_func
pthread_setschedparam:
	movw r12, #413
	b ws1_resolver
	.align 2

	.global pthread_setschedprio
	.type pthread_setschedprio, %function
	.thumb_func
pthread_setschedprio:
	movw r12, #414
	b ws1_resolver
	.align 2

	.global pthread_setspecific
	.type pthread_setspecific, %function
	.thumb_func
pthread_setspecific:
	movw r12, #415
	b ws1_resolver
	.align 2

	.global pthread_sigmask
	.type pthread_sigmask, %function
	.thumb_func
pthread_sigmask:
	movw r12, #416
	b ws1_resolver
	.align 2

	.global pthread_spin_destroy
	.type pthread_spin_destroy, %function
	.thumb_func
pthread_spin_destroy:
	movw r12, #417
	b ws1_resolver
	.align 2

	.global pthread_spin_init
	.type pthread_spin_init, %function
	.thumb_func
pthread_spin_init:
	movw r12, #418
	b ws1_resolver
	.align 2

	.global pthread_spin_lock
	.type pthread_spin_lock, %function
	.thumb_func
pthread_spin_lock:
	movw r12, #419
	b ws1_resolver
	.align 2

	.global pthread_spin_trylock
	.type pthread_spin_trylock, %function
	.thumb_func
pthread_spin_trylock:
	movw r12, #420
	b ws1_resolver
	.align 2

	.global pthread_spin_unlock
	.type pthread_spin_unlock, %function
	.thumb_func
pthread_spin_unlock:
	movw r12, #421
	b ws1_resolver
	.align 2

	.global putc
	.type putc, %function
	.thumb_func
putc:
	movw r12, #422
	b ws1_resolver
	.align 2

	.global putc_unlocked
	.type putc_unlocked, %function
	.thumb_func
putc_unlocked:
	movw r12, #423
	b ws1_resolver
	.align 2

	.global putchar
	.type putchar, %function
	.thumb_func
putchar:
	movw r12, #424
	b ws1_resolver
	.align 2

	.global putchar_unlocked
	.type putchar_unlocked, %function
	.thumb_func
putchar_unlocked:
	movw r12, #425
	b ws1_resolver
	.align 2

	.global putenv
	.type putenv, %function
	.thumb_func
putenv:
	movw r12, #426
	b ws1_resolver
	.align 2

	.global puts
	.type puts, %function
	.thumb_func
puts:
	movw r12, #427
	b ws1_resolver
	.align 2

	.global putwc
	.type putwc, %function
	.thumb_func
putwc:
	movw r12, #428
	b ws1_resolver
	.align 2

	.global putwchar
	.type putwchar, %function
	.thumb_func
putwchar:
	movw r12, #429
	b ws1_resolver
	.align 2

	.global pwrite
	.type pwrite, %function
	.thumb_func
pwrite:
	movw r12, #430
	b ws1_resolver
	.align 2

	.global pwrite64
	.type pwrite64, %function
	.thumb_func
pwrite64:
	movw r12, #431
	b ws1_resolver
	.align 2

	.global qsort
	.type qsort, %function
	.thumb_func
qsort:
	movw r12, #432
	b ws1_resolver
	.align 2

	.global quick_exit
	.type quick_exit, %function
	.thumb_func
quick_exit:
	movw r12, #433
	b ws1_resolver
	.align 2

	.global raise
	.type raise, %function
	.thumb_func
raise:
	movw r12, #434
	b ws1_resolver
	.align 2

	.global rand
	.type rand, %function
	.thumb_func
rand:
	movw r12, #435
	b ws1_resolver
	.align 2

	.global rand_r
	.type rand_r, %function
	.thumb_func
rand_r:
	movw r12, #436
	b ws1_resolver
	.align 2

	.global read
	.type read, %function
	.thumb_func
read:
	movw r12, #437
	b ws1_resolver
	.align 2

	.global readdir
	.type readdir, %function
	.thumb_func
readdir:
	movw r12, #438
	b ws1_resolver
	.align 2

	.global readdir64
	.type readdir64, %function
	.thumb_func
readdir64:
	movw r12, #439
	b ws1_resolver
	.align 2

	.global readdir64_r
	.type readdir64_r, %function
	.thumb_func
readdir64_r:
	movw r12, #440
	b ws1_resolver
	.align 2

	.global readdir_r
	.type readdir_r, %function
	.thumb_func
readdir_r:
	movw r12, #441
	b ws1_resolver
	.align 2

	.global readlink
	.type readlink, %function
	.thumb_func
readlink:
	movw r12, #442
	b ws1_resolver
	.align 2

	.global readv
	.type readv, %function
	.thumb_func
readv:
	movw r12, #443
	b ws1_resolver
	.align 2

	.global realloc
	.type realloc, %function
	.thumb_func
realloc:
	movw r12, #444
	b ws1_resolver
	.align 2

	.global realpath
	.type realpath, %function
	.thumb_func
realpath:
	movw r12, #445
	b ws1_resolver
	.align 2

	.global remove
	.type remove, %function
	.thumb_func
remove:
	movw r12, #446
	b ws1_resolver
	.align 2

	.global rename
	.type rename, %function
	.thumb_func
rename:
	movw r12, #447
	b ws1_resolver
	.align 2

	.global rewind
	.type rewind, %function
	.thumb_func
rewind:
	movw r12, #448
	b ws1_resolver
	.align 2

	.global rewinddir
	.type rewinddir, %function
	.thumb_func
rewinddir:
	movw r12, #449
	b ws1_resolver
	.align 2

	.global scanf
	.type scanf, %function
	.thumb_func
scanf:
	movw r12, #450
	b ws1_resolver
	.align 2

	.global sched_get_priority_max
	.type sched_get_priority_max, %function
	.thumb_func
sched_get_priority_max:
	movw r12, #451
	b ws1_resolver
	.align 2

	.global sched_get_priority_min
	.type sched_get_priority_min, %function
	.thumb_func
sched_get_priority_min:
	movw r12, #452
	b ws1_resolver
	.align 2

	.global sched_getparam
	.type sched_getparam, %function
	.thumb_func
sched_getparam:
	movw r12, #453
	b ws1_resolver
	.align 2

	.global sched_getscheduler
	.type sched_getscheduler, %function
	.thumb_func
sched_getscheduler:
	movw r12, #454
	b ws1_resolver
	.align 2

	.global sched_rr_get_interval
	.type sched_rr_get_interval, %function
	.thumb_func
sched_rr_get_interval:
	movw r12, #455
	b ws1_resolver
	.align 2

	.global sched_setparam
	.type sched_setparam, %function
	.thumb_func
sched_setparam:
	movw r12, #456
	b ws1_resolver
	.align 2

	.global sched_setscheduler
	.type sched_setscheduler, %function
	.thumb_func
sched_setscheduler:
	movw r12, #457
	b ws1_resolver
	.align 2

	.global sched_yield
	.type sched_yield, %function
	.thumb_func
sched_yield:
	movw r12, #458
	b ws1_resolver
	.align 2

	.global seed48
	.type seed48, %function
	.thumb_func
seed48:
	movw r12, #459
	b ws1_resolver
	.align 2

	.global seekdir
	.type seekdir, %function
	.thumb_func
seekdir:
	movw r12, #460
	b ws1_resolver
	.align 2

	.global select
	.type select, %function
	.thumb_func
select:
	movw r12, #461
	b ws1_resolver
	.align 2

	.global sem_close
	.type sem_close, %function
	.thumb_func
sem_close:
	movw r12, #462
	b ws1_resolver
	.align 2

	.global sem_destroy
	.type sem_destroy, %function
	.thumb_func
sem_destroy:
	movw r12, #463
	b ws1_resolver
	.align 2

	.global sem_getvalue
	.type sem_getvalue, %function
	.thumb_func
sem_getvalue:
	movw r12, #464
	b ws1_resolver
	.align 2

	.global sem_init
	.type sem_init, %function
	.thumb_func
sem_init:
	movw r12, #465
	b ws1_resolver
	.align 2

	.global sem_open
	.type sem_open, %function
	.thumb_func
sem_open:
	movw r12, #466
	b ws1_resolver
	.align 2

	.global sem_post
	.type sem_post, %function
	.thumb_func
sem_post:
	movw r12, #467
	b ws1_resolver
	.align 2

	.global sem_timedwait
	.type sem_timedwait, %function
	.thumb_func
sem_timedwait:
	movw r12, #468
	b ws1_resolver
	.align 2

	.global sem_trywait
	.type sem_trywait, %function
	.thumb_func
sem_trywait:
	movw r12, #469
	b ws1_resolver
	.align 2

	.global sem_unlink
	.type sem_unlink, %function
	.thumb_func
sem_unlink:
	movw r12, #470
	b ws1_resolver
	.align 2

	.global sem_wait
	.type sem_wait, %function
	.thumb_func
sem_wait:
	movw r12, #471
	b ws1_resolver
	.align 2

	.global setbuf
	.type setbuf, %function
	.thumb_func
setbuf:
	movw r12, #472
	b ws1_resolver
	.align 2

	.global setbuffer
	.type setbuffer, %function
	.thumb_func
setbuffer:
	movw r12, #473
	b ws1_resolver
	.align 2

	.global setenv
	.type setenv, %function
	.thumb_func
setenv:
	movw r12, #474
	b ws1_resolver
	.align 2

	.global setgrent
	.type setgrent, %function
	.thumb_func
setgrent:
	movw r12, #475
	b ws1_resolver
	.align 2

	.global sethostname
	.type sethostname, %function
	.thumb_func
sethostname:
	movw r12, #476
	b ws1_resolver
	.align 2

	.global setitimer
	.type setitimer, %function
	.thumb_func
setitimer:
	movw r12, #477
	b ws1_resolver
	.align 2

	.global setlinebuf
	.type setlinebuf, %function
	.thumb_func
setlinebuf:
	movw r12, #478
	b ws1_resolver
	.align 2

	.global setlocale
	.type setlocale, %function
	.thumb_func
setlocale:
	movw r12, #479
	b ws1_resolver
	.align 2

	.global setlogmask
	.type setlogmask, %function
	.thumb_func
setlogmask:
	movw r12, #480
	b ws1_resolver
	.align 2

	.global setpgid
	.type setpgid, %function
	.thumb_func
setpgid:
	movw r12, #481
	b ws1_resolver
	.align 2

	.global setpgrp
	.type setpgrp, %function
	.thumb_func
setpgrp:
	movw r12, #482
	b ws1_resolver
	.align 2

	.global setpwent
	.type setpwent, %function
	.thumb_func
setpwent:
	movw r12, #483
	b ws1_resolver
	.align 2

	.global setrlimit
	.type setrlimit, %function
	.thumb_func
setrlimit:
	movw r12, #484
	b ws1_resolver
	.align 2

	.global setrlimit64
	.type setrlimit64, %function
	.thumb_func
setrlimit64:
	movw r12, #485
	b ws1_resolver
	.align 2

	.global setsid
	.type setsid, %function
	.thumb_func
setsid:
	movw r12, #486
	b ws1_resolver
	.align 2

	.global settimeofday
	.type settimeofday, %function
	.thumb_func
settimeofday:
	movw r12, #487
	b ws1_resolver
	.align 2

	.global setvbuf
	.type setvbuf, %function
	.thumb_func
setvbuf:
	movw r12, #488
	b ws1_resolver
	.align 2

	.global sigaction
	.type sigaction, %function
	.thumb_func
sigaction:
	movw r12, #489
	b ws1_resolver
	.align 2

	.global sigaddset
	.type sigaddset, %function
	.thumb_func
sigaddset:
	movw r12, #490
	b ws1_resolver
	.align 2

	.global sigblock
	.type sigblock, %function
	.thumb_func
sigblock:
	movw r12, #491
	b ws1_resolver
	.align 2

	.global sigdelset
	.type sigdelset, %function
	.thumb_func
sigdelset:
	movw r12, #492
	b ws1_resolver
	.align 2

	.global sigemptyset
	.type sigemptyset, %function
	.thumb_func
sigemptyset:
	movw r12, #493
	b ws1_resolver
	.align 2

	.global sigfillset
	.type sigfillset, %function
	.thumb_func
sigfillset:
	movw r12, #494
	b ws1_resolver
	.align 2

	.global sigismember
	.type sigismember, %function
	.thumb_func
sigismember:
	movw r12, #495
	b ws1_resolver
	.align 2

	.global siglongjmp
	.type siglongjmp, %function
	.thumb_func
siglongjmp:
	movw r12, #496
	b ws1_resolver
	.align 2

	.global signal
	.type signal, %function
	.thumb_func
signal:
	movw r12, #497
	b ws1_resolver
	.align 2

	.global sigpause
	.type sigpause, %function
	.thumb_func
sigpause:
	movw r12, #498
	b ws1_resolver
	.align 2

	.global sigpending
	.type sigpending, %function
	.thumb_func
sigpending:
	movw r12, #499
	b ws1_resolver
	.align 2

	.global sigprocmask
	.type sigprocmask, %function
	.thumb_func
sigprocmask:
	movw r12, #500
	b ws1_resolver
	.align 2

	.global sigqueue
	.type sigqueue, %function
	.thumb_func
sigqueue:
	movw r12, #501
	b ws1_resolver
	.align 2

	.global sigsetjmp
	.type sigsetjmp, %function
	.thumb_func
sigsetjmp:
	movw r12, #502
	b ws1_resolver
	.align 2

	.global sigsetmask
	.type sigsetmask, %function
	.thumb_func
sigsetmask:
	movw r12, #503
	b ws1_resolver
	.align 2

	.global sigsuspend
	.type sigsuspend, %function
	.thumb_func
sigsuspend:
	movw r12, #504
	b ws1_resolver
	.align 2

	.global sigtimedwait
	.type sigtimedwait, %function
	.thumb_func
sigtimedwait:
	movw r12, #505
	b ws1_resolver
	.align 2

	.global sigwait
	.type sigwait, %function
	.thumb_func
sigwait:
	movw r12, #506
	b ws1_resolver
	.align 2

	.global sigwaitinfo
	.type sigwaitinfo, %function
	.thumb_func
sigwaitinfo:
	movw r12, #507
	b ws1_resolver
	.align 2

	.global sleep
	.type sleep, %function
	.thumb_func
sleep:
	movw r12, #508
	b ws1_resolver
	.align 2

	.global snprintf
	.type snprintf, %function
	.thumb_func
snprintf:
	movw r12, #509
	b ws1_resolver
	.align 2

	.global sprintf
	.type sprintf, %function
	.thumb_func
sprintf:
	movw r12, #510
	b ws1_resolver
	.align 2

	.global srand
	.type srand, %function
	.thumb_func
srand:
	movw r12, #511
	b ws1_resolver
	.align 2

	.global srand48
	.type srand48, %function
	.thumb_func
srand48:
	movw r12, #512
	b ws1_resolver
	.align 2

	.global sscanf
	.type sscanf, %function
	.thumb_func
sscanf:
	movw r12, #513
	b ws1_resolver
	.align 2

	.global statvfs64
	.type statvfs64, %function
	.thumb_func
statvfs64:
	movw r12, #514
	b ws1_resolver
	.align 2

	.global stderr
	.type stderr, %function
	.thumb_func
stderr:
	movw r12, #515
	b ws1_resolver
	.align 2

	.global stdin
	.type stdin, %function
	.thumb_func
stdin:
	movw r12, #516
	b ws1_resolver
	.align 2

	.global stdout
	.type stdout, %function
	.thumb_func
stdout:
	movw r12, #517
	b ws1_resolver
	.align 2

	.global strcasecmp
	.type strcasecmp, %function
	.thumb_func
strcasecmp:
	movw r12, #518
	b ws1_resolver
	.align 2

	.global strcat
	.type strcat, %function
	.thumb_func
strcat:
	movw r12, #519
	b ws1_resolver
	.align 2

	.global strchr
	.type strchr, %function
	.thumb_func
strchr:
	movw r12, #520
	b ws1_resolver
	.align 2

	.global strcmp
	.type strcmp, %function
	.thumb_func
strcmp:
	movw r12, #521
	b ws1_resolver
	.align 2

	.global strcoll
	.type strcoll, %function
	.thumb_func
strcoll:
	movw r12, #522
	b ws1_resolver
	.align 2

	.global strcpy
	.type strcpy, %function
	.thumb_func
strcpy:
	movw r12, #523
	b ws1_resolver
	.align 2

	.global strcspn
	.type strcspn, %function
	.thumb_func
strcspn:
	movw r12, #524
	b ws1_resolver
	.align 2

	.global strdup
	.type strdup, %function
	.thumb_func
strdup:
	movw r12, #525
	b ws1_resolver
	.align 2

	.global strerror
	.type strerror, %function
	.thumb_func
strerror:
	movw r12, #526
	b ws1_resolver
	.align 2

	.global strerror_r
	.type strerror_r, %function
	.thumb_func
strerror_r:
	movw r12, #527
	b ws1_resolver
	.align 2

	.global strlcat
	.type strlcat, %function
	.thumb_func
strlcat:
	movw r12, #528
	b ws1_resolver
	.align 2

	.global strlcpy
	.type strlcpy, %function
	.thumb_func
strlcpy:
	movw r12, #529
	b ws1_resolver
	.align 2

	.global strlen
	.type strlen, %function
	.thumb_func
strlen:
	movw r12, #530
	b ws1_resolver
	.align 2

	.global strncasecmp
	.type strncasecmp, %function
	.thumb_func
strncasecmp:
	movw r12, #531
	b ws1_resolver
	.align 2

	.global strncat
	.type strncat, %function
	.thumb_func
strncat:
	movw r12, #532
	b ws1_resolver
	.align 2

	.global strncmp
	.type strncmp, %function
	.thumb_func
strncmp:
	movw r12, #533
	b ws1_resolver
	.align 2

	.global strncpy
	.type strncpy, %function
	.thumb_func
strncpy:
	movw r12, #534
	b ws1_resolver
	.align 2

	.global strnlen
	.type strnlen, %function
	.thumb_func
strnlen:
	movw r12, #535
	b ws1_resolver
	.align 2

	.global strpbrk
	.type strpbrk, %function
	.thumb_func
strpbrk:
	movw r12, #536
	b ws1_resolver
	.align 2

	.global strrchr
	.type strrchr, %function
	.thumb_func
strrchr:
	movw r12, #537
	b ws1_resolver
	.align 2

	.global strsep
	.type strsep, %function
	.thumb_func
strsep:
	movw r12, #538
	b ws1_resolver
	.align 2

	.global strsignal
	.type strsignal, %function
	.thumb_func
strsignal:
	movw r12, #539
	b ws1_resolver
	.align 2

	.global strspn
	.type strspn, %function
	.thumb_func
strspn:
	movw r12, #540
	b ws1_resolver
	.align 2

	.global strstr
	.type strstr, %function
	.thumb_func
strstr:
	movw r12, #541
	b ws1_resolver
	.align 2

	.global strtod
	.type strtod, %function
	.thumb_func
strtod:
	movw r12, #542
	b ws1_resolver
	.align 2

	.global strtof
	.type strtof, %function
	.thumb_func
strtof:
	movw r12, #543
	b ws1_resolver
	.align 2

	.global strtoimax
	.type strtoimax, %function
	.thumb_func
strtoimax:
	movw r12, #544
	b ws1_resolver
	.align 2

	.global strtok
	.type strtok, %function
	.thumb_func
strtok:
	movw r12, #545
	b ws1_resolver
	.align 2

	.global strtok_r
	.type strtok_r, %function
	.thumb_func
strtok_r:
	movw r12, #546
	b ws1_resolver
	.align 2

	.global strtol
	.type strtol, %function
	.thumb_func
strtol:
	movw r12, #547
	b ws1_resolver
	.align 2

	.global strtold
	.type strtold, %function
	.thumb_func
strtold:
	movw r12, #548
	b ws1_resolver
	.align 2

	.global strtoll
	.type strtoll, %function
	.thumb_func
strtoll:
	movw r12, #549
	b ws1_resolver
	.align 2

	.global strtoul
	.type strtoul, %function
	.thumb_func
strtoul:
	movw r12, #550
	b ws1_resolver
	.align 2

	.global strtoull
	.type strtoull, %function
	.thumb_func
strtoull:
	movw r12, #551
	b ws1_resolver
	.align 2

	.global strtoumax
	.type strtoumax, %function
	.thumb_func
strtoumax:
	movw r12, #552
	b ws1_resolver
	.align 2

	.global strxfrm
	.type strxfrm, %function
	.thumb_func
strxfrm:
	movw r12, #553
	b ws1_resolver
	.align 2

	.global swab
	.type swab, %function
	.thumb_func
swab:
	movw r12, #554
	b ws1_resolver
	.align 2

	.global swprintf
	.type swprintf, %function
	.thumb_func
swprintf:
	movw r12, #555
	b ws1_resolver
	.align 2

	.global swscanf
	.type swscanf, %function
	.thumb_func
swscanf:
	movw r12, #556
	b ws1_resolver
	.align 2

	.global symlink
	.type symlink, %function
	.thumb_func
symlink:
	movw r12, #557
	b ws1_resolver
	.align 2

	.global sync
	.type sync, %function
	.thumb_func
sync:
	movw r12, #558
	b ws1_resolver
	.align 2

	.global sys_siglist
	.type sys_siglist, %function
	.thumb_func
sys_siglist:
	movw r12, #559
	b ws1_resolver
	.align 2

	.global sysconf
	.type sysconf, %function
	.thumb_func
sysconf:
	movw r12, #560
	b ws1_resolver
	.align 2

	.global syslog
	.type syslog, %function
	.thumb_func
syslog:
	movw r12, #561
	b ws1_resolver
	.align 2

	.global system
	.type system, %function
	.thumb_func
system:
	movw r12, #562
	b ws1_resolver
	.align 2

	.global tcdrain
	.type tcdrain, %function
	.thumb_func
tcdrain:
	movw r12, #563
	b ws1_resolver
	.align 2

	.global tcflow
	.type tcflow, %function
	.thumb_func
tcflow:
	movw r12, #564
	b ws1_resolver
	.align 2

	.global tcflush
	.type tcflush, %function
	.thumb_func
tcflush:
	movw r12, #565
	b ws1_resolver
	.align 2

	.global tcgetattr
	.type tcgetattr, %function
	.thumb_func
tcgetattr:
	movw r12, #566
	b ws1_resolver
	.align 2

	.global tcgetpgrp
	.type tcgetpgrp, %function
	.thumb_func
tcgetpgrp:
	movw r12, #567
	b ws1_resolver
	.align 2

	.global tcgetsid
	.type tcgetsid, %function
	.thumb_func
tcgetsid:
	movw r12, #568
	b ws1_resolver
	.align 2

	.global tcsendbreak
	.type tcsendbreak, %function
	.thumb_func
tcsendbreak:
	movw r12, #569
	b ws1_resolver
	.align 2

	.global tcsetattr
	.type tcsetattr, %function
	.thumb_func
tcsetattr:
	movw r12, #570
	b ws1_resolver
	.align 2

	.global tcsetpgrp
	.type tcsetpgrp, %function
	.thumb_func
tcsetpgrp:
	movw r12, #571
	b ws1_resolver
	.align 2

	.global telldir
	.type telldir, %function
	.thumb_func
telldir:
	movw r12, #572
	b ws1_resolver
	.align 2

	.global tempnam
	.type tempnam, %function
	.thumb_func
tempnam:
	movw r12, #573
	b ws1_resolver
	.align 2

	.global time
	.type time, %function
	.thumb_func
time:
	movw r12, #574
	b ws1_resolver
	.align 2

	.global timer_create
	.type timer_create, %function
	.thumb_func
timer_create:
	movw r12, #575
	b ws1_resolver
	.align 2

	.global timer_delete
	.type timer_delete, %function
	.thumb_func
timer_delete:
	movw r12, #576
	b ws1_resolver
	.align 2

	.global timer_getoverrun
	.type timer_getoverrun, %function
	.thumb_func
timer_getoverrun:
	movw r12, #577
	b ws1_resolver
	.align 2

	.global timer_gettime
	.type timer_gettime, %function
	.thumb_func
timer_gettime:
	movw r12, #578
	b ws1_resolver
	.align 2

	.global timer_settime
	.type timer_settime, %function
	.thumb_func
timer_settime:
	movw r12, #579
	b ws1_resolver
	.align 2

	.global times
	.type times, %function
	.thumb_func
times:
	movw r12, #580
	b ws1_resolver
	.align 2

	.global tmpfile
	.type tmpfile, %function
	.thumb_func
tmpfile:
	movw r12, #581
	b ws1_resolver
	.align 2

	.global tmpfile64
	.type tmpfile64, %function
	.thumb_func
tmpfile64:
	movw r12, #582
	b ws1_resolver
	.align 2

	.global tmpnam
	.type tmpnam, %function
	.thumb_func
tmpnam:
	movw r12, #583
	b ws1_resolver
	.align 2

	.global tolower
	.type tolower, %function
	.thumb_func
tolower:
	movw r12, #584
	b ws1_resolver
	.align 2

	.global toupper
	.type toupper, %function
	.thumb_func
toupper:
	movw r12, #585
	b ws1_resolver
	.align 2

	.global towctrans
	.type towctrans, %function
	.thumb_func
towctrans:
	movw r12, #586
	b ws1_resolver
	.align 2

	.global towlower
	.type towlower, %function
	.thumb_func
towlower:
	movw r12, #587
	b ws1_resolver
	.align 2

	.global towupper
	.type towupper, %function
	.thumb_func
towupper:
	movw r12, #588
	b ws1_resolver
	.align 2

	.global truncate
	.type truncate, %function
	.thumb_func
truncate:
	movw r12, #589
	b ws1_resolver
	.align 2

	.global truncate64
	.type truncate64, %function
	.thumb_func
truncate64:
	movw r12, #590
	b ws1_resolver
	.align 2

	.global umask
	.type umask, %function
	.thumb_func
umask:
	movw r12, #591
	b ws1_resolver
	.align 2

	.global umount
	.type umount, %function
	.thumb_func
umount:
	movw r12, #592
	b ws1_resolver
	.align 2

	.global uname
	.type uname, %function
	.thumb_func
uname:
	movw r12, #593
	b ws1_resolver
	.align 2

	.global ungetc
	.type ungetc, %function
	.thumb_func
ungetc:
	movw r12, #594
	b ws1_resolver
	.align 2

	.global ungetwc
	.type ungetwc, %function
	.thumb_func
ungetwc:
	movw r12, #595
	b ws1_resolver
	.align 2

	.global unlink
	.type unlink, %function
	.thumb_func
unlink:
	movw r12, #596
	b ws1_resolver
	.align 2

	.global unsetenv
	.type unsetenv, %function
	.thumb_func
unsetenv:
	movw r12, #597
	b ws1_resolver
	.align 2

	.global usleep
	.type usleep, %function
	.thumb_func
usleep:
	movw r12, #598
	b ws1_resolver
	.align 2

	.global utime
	.type utime, %function
	.thumb_func
utime:
	movw r12, #599
	b ws1_resolver
	.align 2

	.global utimes
	.type utimes, %function
	.thumb_func
utimes:
	movw r12, #600
	b ws1_resolver
	.align 2

	.global valloc
	.type valloc, %function
	.thumb_func
valloc:
	movw r12, #601
	b ws1_resolver
	.align 2

	.global verr
	.type verr, %function
	.thumb_func
verr:
	movw r12, #602
	b ws1_resolver
	.align 2

	.global verrx
	.type verrx, %function
	.thumb_func
verrx:
	movw r12, #603
	b ws1_resolver
	.align 2

	.global vfork
	.type vfork, %function
	.thumb_func
vfork:
	movw r12, #604
	b ws1_resolver
	.align 2

	.global vfprintf
	.type vfprintf, %function
	.thumb_func
vfprintf:
	movw r12, #605
	b ws1_resolver
	.align 2

	.global vfscanf
	.type vfscanf, %function
	.thumb_func
vfscanf:
	movw r12, #606
	b ws1_resolver
	.align 2

	.global vfwprintf
	.type vfwprintf, %function
	.thumb_func
vfwprintf:
	movw r12, #607
	b ws1_resolver
	.align 2

	.global vfwscanf
	.type vfwscanf, %function
	.thumb_func
vfwscanf:
	movw r12, #608
	b ws1_resolver
	.align 2

	.global vprintf
	.type vprintf, %function
	.thumb_func
vprintf:
	movw r12, #609
	b ws1_resolver
	.align 2

	.global vscanf
	.type vscanf, %function
	.thumb_func
vscanf:
	movw r12, #610
	b ws1_resolver
	.align 2

	.global vsnprintf
	.type vsnprintf, %function
	.thumb_func
vsnprintf:
	movw r12, #611
	b ws1_resolver
	.align 2

	.global vsprintf
	.type vsprintf, %function
	.thumb_func
vsprintf:
	movw r12, #612
	b ws1_resolver
	.align 2

	.global vsscanf
	.type vsscanf, %function
	.thumb_func
vsscanf:
	movw r12, #613
	b ws1_resolver
	.align 2

	.global vswprintf
	.type vswprintf, %function
	.thumb_func
vswprintf:
	movw r12, #614
	b ws1_resolver
	.align 2

	.global vswscanf
	.type vswscanf, %function
	.thumb_func
vswscanf:
	movw r12, #615
	b ws1_resolver
	.align 2

	.global vsyslog
	.type vsyslog, %function
	.thumb_func
vsyslog:
	movw r12, #616
	b ws1_resolver
	.align 2

	.global vwarn
	.type vwarn, %function
	.thumb_func
vwarn:
	movw r12, #617
	b ws1_resolver
	.align 2

	.global vwarnx
	.type vwarnx, %function
	.thumb_func
vwarnx:
	movw r12, #618
	b ws1_resolver
	.align 2

	.global vwprintf
	.type vwprintf, %function
	.thumb_func
vwprintf:
	movw r12, #619
	b ws1_resolver
	.align 2

	.global vwscanf
	.type vwscanf, %function
	.thumb_func
vwscanf:
	movw r12, #620
	b ws1_resolver
	.align 2

	.global wait
	.type wait, %function
	.thumb_func
wait:
	movw r12, #621
	b ws1_resolver
	.align 2

	.global wait3
	.type wait3, %function
	.thumb_func
wait3:
	movw r12, #622
	b ws1_resolver
	.align 2

	.global wait4
	.type wait4, %function
	.thumb_func
wait4:
	movw r12, #623
	b ws1_resolver
	.align 2

	.global waitid
	.type waitid, %function
	.thumb_func
waitid:
	movw r12, #624
	b ws1_resolver
	.align 2

	.global waitpid
	.type waitpid, %function
	.thumb_func
waitpid:
	movw r12, #625
	b ws1_resolver
	.align 2

	.global warn
	.type warn, %function
	.thumb_func
warn:
	movw r12, #626
	b ws1_resolver
	.align 2

	.global warnx
	.type warnx, %function
	.thumb_func
warnx:
	movw r12, #627
	b ws1_resolver
	.align 2

	.global wcrtomb
	.type wcrtomb, %function
	.thumb_func
wcrtomb:
	movw r12, #628
	b ws1_resolver
	.align 2

	.global wcscat
	.type wcscat, %function
	.thumb_func
wcscat:
	movw r12, #629
	b ws1_resolver
	.align 2

	.global wcschr
	.type wcschr, %function
	.thumb_func
wcschr:
	movw r12, #630
	b ws1_resolver
	.align 2

	.global wcscmp
	.type wcscmp, %function
	.thumb_func
wcscmp:
	movw r12, #631
	b ws1_resolver
	.align 2

	.global wcscoll
	.type wcscoll, %function
	.thumb_func
wcscoll:
	movw r12, #632
	b ws1_resolver
	.align 2

	.global wcscpy
	.type wcscpy, %function
	.thumb_func
wcscpy:
	movw r12, #633
	b ws1_resolver
	.align 2

	.global wcscspn
	.type wcscspn, %function
	.thumb_func
wcscspn:
	movw r12, #634
	b ws1_resolver
	.align 2

	.global wcsftime
	.type wcsftime, %function
	.thumb_func
wcsftime:
	movw r12, #635
	b ws1_resolver
	.align 2

	.global wcslen
	.type wcslen, %function
	.thumb_func
wcslen:
	movw r12, #636
	b ws1_resolver
	.align 2

	.global wcsncat
	.type wcsncat, %function
	.thumb_func
wcsncat:
	movw r12, #637
	b ws1_resolver
	.align 2

	.global wcsncmp
	.type wcsncmp, %function
	.thumb_func
wcsncmp:
	movw r12, #638
	b ws1_resolver
	.align 2

	.global wcsncpy
	.type wcsncpy, %function
	.thumb_func
wcsncpy:
	movw r12, #639
	b ws1_resolver
	.align 2

	.global wcspbrk
	.type wcspbrk, %function
	.thumb_func
wcspbrk:
	movw r12, #640
	b ws1_resolver
	.align 2

	.global wcsrchr
	.type wcsrchr, %function
	.thumb_func
wcsrchr:
	movw r12, #641
	b ws1_resolver
	.align 2

	.global wcsrtombs
	.type wcsrtombs, %function
	.thumb_func
wcsrtombs:
	movw r12, #642
	b ws1_resolver
	.align 2

	.global wcsspn
	.type wcsspn, %function
	.thumb_func
wcsspn:
	movw r12, #643
	b ws1_resolver
	.align 2

	.global wcsstr
	.type wcsstr, %function
	.thumb_func
wcsstr:
	movw r12, #644
	b ws1_resolver
	.align 2

	.global wcstod
	.type wcstod, %function
	.thumb_func
wcstod:
	movw r12, #645
	b ws1_resolver
	.align 2

	.global wcstof
	.type wcstof, %function
	.thumb_func
wcstof:
	movw r12, #646
	b ws1_resolver
	.align 2

	.global wcstoimax
	.type wcstoimax, %function
	.thumb_func
wcstoimax:
	movw r12, #647
	b ws1_resolver
	.align 2

	.global wcstok
	.type wcstok, %function
	.thumb_func
wcstok:
	movw r12, #648
	b ws1_resolver
	.align 2

	.global wcstol
	.type wcstol, %function
	.thumb_func
wcstol:
	movw r12, #649
	b ws1_resolver
	.align 2

	.global wcstold
	.type wcstold, %function
	.thumb_func
wcstold:
	movw r12, #650
	b ws1_resolver
	.align 2

	.global wcstoll
	.type wcstoll, %function
	.thumb_func
wcstoll:
	movw r12, #651
	b ws1_resolver
	.align 2

	.global wcstombs
	.type wcstombs, %function
	.thumb_func
wcstombs:
	movw r12, #652
	b ws1_resolver
	.align 2

	.global wcstoul
	.type wcstoul, %function
	.thumb_func
wcstoul:
	movw r12, #653
	b ws1_resolver
	.align 2

	.global wcstoull
	.type wcstoull, %function
	.thumb_func
wcstoull:
	movw r12, #654
	b ws1_resolver
	.align 2

	.global wcstoumax
	.type wcstoumax, %function
	.thumb_func
wcstoumax:
	movw r12, #655
	b ws1_resolver
	.align 2

	.global wcsxfrm
	.type wcsxfrm, %function
	.thumb_func
wcsxfrm:
	movw r12, #656
	b ws1_resolver
	.align 2

	.global wctob
	.type wctob, %function
	.thumb_func
wctob:
	movw r12, #657
	b ws1_resolver
	.align 2

	.global wctomb
	.type wctomb, %function
	.thumb_func
wctomb:
	movw r12, #658
	b ws1_resolver
	.align 2

	.global wctrans
	.type wctrans, %function
	.thumb_func
wctrans:
	movw r12, #659
	b ws1_resolver
	.align 2

	.global wctype
	.type wctype, %function
	.thumb_func
wctype:
	movw r12, #660
	b ws1_resolver
	.align 2

	.global wmemchr
	.type wmemchr, %function
	.thumb_func
wmemchr:
	movw r12, #661
	b ws1_resolver
	.align 2

	.global wmemcmp
	.type wmemcmp, %function
	.thumb_func
wmemcmp:
	movw r12, #662
	b ws1_resolver
	.align 2

	.global wmemcpy
	.type wmemcpy, %function
	.thumb_func
wmemcpy:
	movw r12, #663
	b ws1_resolver
	.align 2

	.global wmemmove
	.type wmemmove, %function
	.thumb_func
wmemmove:
	movw r12, #664
	b ws1_resolver
	.align 2

	.global wmemset
	.type wmemset, %function
	.thumb_func
wmemset:
	movw r12, #665
	b ws1_resolver
	.align 2

	.global wprintf
	.type wprintf, %function
	.thumb_func
wprintf:
	movw r12, #666
	b ws1_resolver
	.align 2

	.global write
	.type write, %function
	.thumb_func
write:
	movw r12, #667
	b ws1_resolver
	.align 2

	.global writev
	.type writev, %function
	.thumb_func
writev:
	movw r12, #668
	b ws1_resolver
	.align 2

	.global wscanf
	.type wscanf, %function
	.thumb_func
wscanf:
	movw r12, #669
	b ws1_resolver
	.align 2

	.global _Unwind_FindEnclosingFunction
	.type _Unwind_FindEnclosingFunction, %function
	.thumb_func
_Unwind_FindEnclosingFunction:
	movw r12, #670
	b ws1_resolver
	.align 2

	.global _Unwind_Find_FDE
	.type _Unwind_Find_FDE, %function
	.thumb_func
_Unwind_Find_FDE:
	movw r12, #671
	b ws1_resolver
	.align 2

	.global _Unwind_GetGR
	.type _Unwind_GetGR, %function
	.thumb_func
_Unwind_GetGR:
	movw r12, #672
	b ws1_resolver
	.align 2

	.global _Unwind_GetIP
	.type _Unwind_GetIP, %function
	.thumb_func
_Unwind_GetIP:
	movw r12, #673
	b ws1_resolver
	.align 2

	.global _Unwind_GetIPInfo
	.type _Unwind_GetIPInfo, %function
	.thumb_func
_Unwind_GetIPInfo:
	movw r12, #674
	b ws1_resolver
	.align 2

	.global _Unwind_SetGR
	.type _Unwind_SetGR, %function
	.thumb_func
_Unwind_SetGR:
	movw r12, #675
	b ws1_resolver
	.align 2

	.global _Unwind_SetIP
	.type _Unwind_SetIP, %function
	.thumb_func
_Unwind_SetIP:
	movw r12, #676
	b ws1_resolver
	.align 2

	.global __FD_CLR_chk
	.type __FD_CLR_chk, %function
	.thumb_func
__FD_CLR_chk:
	movw r12, #677
	b ws1_resolver
	.align 2

	.global __FD_ISSET_chk
	.type __FD_ISSET_chk, %function
	.thumb_func
__FD_ISSET_chk:
	movw r12, #678
	b ws1_resolver
	.align 2

	.global __FD_SET_chk
	.type __FD_SET_chk, %function
	.thumb_func
__FD_SET_chk:
	movw r12, #679
	b ws1_resolver
	.align 2

	.global __accept4
	.type __accept4, %function
	.thumb_func
__accept4:
	movw r12, #680
	b ws1_resolver
	.align 2

	.global __aeabi_atexit
	.type __aeabi_atexit, %function
	.thumb_func
__aeabi_atexit:
	movw r12, #681
	b ws1_resolver
	.align 2

	.global __aeabi_read_tp
	.type __aeabi_read_tp, %function
	.thumb_func
__aeabi_read_tp:
	movw r12, #682
	b ws1_resolver
	.align 2

	.global __arm_fadvise64_64
	.type __arm_fadvise64_64, %function
	.thumb_func
__arm_fadvise64_64:
	movw r12, #683
	b ws1_resolver
	.align 2

	.global __b64_ntop
	.type __b64_ntop, %function
	.thumb_func
__b64_ntop:
	movw r12, #684
	b ws1_resolver
	.align 2

	.global __b64_pton
	.type __b64_pton, %function
	.thumb_func
__b64_pton:
	movw r12, #685
	b ws1_resolver
	.align 2

	.global __bionic_brk
	.type __bionic_brk, %function
	.thumb_func
__bionic_brk:
	movw r12, #686
	b ws1_resolver
	.align 2

	.global __bionic_libcrt_compat_symbols
	.type __bionic_libcrt_compat_symbols, %function
	.thumb_func
__bionic_libcrt_compat_symbols:
	movw r12, #687
	b ws1_resolver
	.align 2

	.global __cmsg_nxthdr
	.type __cmsg_nxthdr, %function
	.thumb_func
__cmsg_nxthdr:
	movw r12, #688
	b ws1_resolver
	.align 2

	.global __connect
	.type __connect, %function
	.thumb_func
__connect:
	movw r12, #689
	b ws1_resolver
	.align 2

	.global __ctype_get_mb_cur_max
	.type __ctype_get_mb_cur_max, %function
	.thumb_func
__ctype_get_mb_cur_max:
	movw r12, #690
	b ws1_resolver
	.align 2

	.global __cxa_thread_atexit_impl
	.type __cxa_thread_atexit_impl, %function
	.thumb_func
__cxa_thread_atexit_impl:
	movw r12, #691
	b ws1_resolver
	.align 2

	.global __dn_comp
	.type __dn_comp, %function
	.thumb_func
__dn_comp:
	movw r12, #692
	b ws1_resolver
	.align 2

	.global __dn_count_labels
	.type __dn_count_labels, %function
	.thumb_func
__dn_count_labels:
	movw r12, #693
	b ws1_resolver
	.align 2

	.global __dn_skipname
	.type __dn_skipname, %function
	.thumb_func
__dn_skipname:
	movw r12, #694
	b ws1_resolver
	.align 2

	.global __dso_handle
	.type __dso_handle, %function
	.thumb_func
__dso_handle:
	movw r12, #695
	b ws1_resolver
	.align 2

	.global __epoll_pwait
	.type __epoll_pwait, %function
	.thumb_func
__epoll_pwait:
	movw r12, #696
	b ws1_resolver
	.align 2

	.global __fbufsize
	.type __fbufsize, %function
	.thumb_func
__fbufsize:
	movw r12, #697
	b ws1_resolver
	.align 2

	.global __fcntl64
	.type __fcntl64, %function
	.thumb_func
__fcntl64:
	movw r12, #698
	b ws1_resolver
	.align 2

	.global __flbf
	.type __flbf, %function
	.thumb_func
__flbf:
	movw r12, #699
	b ws1_resolver
	.align 2

	.global __fp_nquery
	.type __fp_nquery, %function
	.thumb_func
__fp_nquery:
	movw r12, #700
	b ws1_resolver
	.align 2

	.global __fp_query
	.type __fp_query, %function
	.thumb_func
__fp_query:
	movw r12, #701
	b ws1_resolver
	.align 2

	.global __fpclassify
	.type __fpclassify, %function
	.thumb_func
__fpclassify:
	movw r12, #702
	b ws1_resolver
	.align 2

	.global __fpclassifyd
	.type __fpclassifyd, %function
	.thumb_func
__fpclassifyd:
	movw r12, #703
	b ws1_resolver
	.align 2

	.global __fpclassifyf
	.type __fpclassifyf, %function
	.thumb_func
__fpclassifyf:
	movw r12, #704
	b ws1_resolver
	.align 2

	.global __fpclassifyl
	.type __fpclassifyl, %function
	.thumb_func
__fpclassifyl:
	movw r12, #705
	b ws1_resolver
	.align 2

	.global __fpending
	.type __fpending, %function
	.thumb_func
__fpending:
	movw r12, #706
	b ws1_resolver
	.align 2

	.global __fpurge
	.type __fpurge, %function
	.thumb_func
__fpurge:
	movw r12, #707
	b ws1_resolver
	.align 2

	.global __freadable
	.type __freadable, %function
	.thumb_func
__freadable:
	movw r12, #708
	b ws1_resolver
	.align 2

	.global __freading
	.type __freading, %function
	.thumb_func
__freading:
	movw r12, #709
	b ws1_resolver
	.align 2

	.global __free_hook
	.type __free_hook, %function
	.thumb_func
__free_hook:
	movw r12, #710
	b ws1_resolver
	.align 2

	.global __fseterr
	.type __fseterr, %function
	.thumb_func
__fseterr:
	movw r12, #711
	b ws1_resolver
	.align 2

	.global __fsetlocking
	.type __fsetlocking, %function
	.thumb_func
__fsetlocking:
	movw r12, #712
	b ws1_resolver
	.align 2

	.global __fstatfs64
	.type __fstatfs64, %function
	.thumb_func
__fstatfs64:
	movw r12, #713
	b ws1_resolver
	.align 2

	.global __futex_wait
	.type __futex_wait, %function
	.thumb_func
__futex_wait:
	movw r12, #714
	b ws1_resolver
	.align 2

	.global __futex_wake
	.type __futex_wake, %function
	.thumb_func
__futex_wake:
	movw r12, #715
	b ws1_resolver
	.align 2

	.global __fwritable
	.type __fwritable, %function
	.thumb_func
__fwritable:
	movw r12, #716
	b ws1_resolver
	.align 2

	.global __fwriting
	.type __fwriting, %function
	.thumb_func
__fwriting:
	movw r12, #717
	b ws1_resolver
	.align 2

	.global __get_h_errno
	.type __get_h_errno, %function
	.thumb_func
__get_h_errno:
	movw r12, #718
	b ws1_resolver
	.align 2

	.global __get_thread
	.type __get_thread, %function
	.thumb_func
__get_thread:
	movw r12, #719
	b ws1_resolver
	.align 2

	.global __get_tls
	.type __get_tls, %function
	.thumb_func
__get_tls:
	movw r12, #720
	b ws1_resolver
	.align 2

	.global __getcpu
	.type __getcpu, %function
	.thumb_func
__getcpu:
	movw r12, #721
	b ws1_resolver
	.align 2

	.global __getcwd
	.type __getcwd, %function
	.thumb_func
__getcwd:
	movw r12, #722
	b ws1_resolver
	.align 2

	.global __getdents64
	.type __getdents64, %function
	.thumb_func
__getdents64:
	movw r12, #723
	b ws1_resolver
	.align 2

	.global __getpid
	.type __getpid, %function
	.thumb_func
__getpid:
	movw r12, #724
	b ws1_resolver
	.align 2

	.global __getpriority
	.type __getpriority, %function
	.thumb_func
__getpriority:
	movw r12, #725
	b ws1_resolver
	.align 2

	.global __gnu_basename
	.type __gnu_basename, %function
	.thumb_func
__gnu_basename:
	movw r12, #726
	b ws1_resolver
	.align 2

	.global __gnu_strerror_r
	.type __gnu_strerror_r, %function
	.thumb_func
__gnu_strerror_r:
	movw r12, #727
	b ws1_resolver
	.align 2

	.global __hostalias
	.type __hostalias, %function
	.thumb_func
__hostalias:
	movw r12, #728
	b ws1_resolver
	.align 2

	.global __ioctl
	.type __ioctl, %function
	.thumb_func
__ioctl:
	movw r12, #729
	b ws1_resolver
	.align 2

	.global __isfinite
	.type __isfinite, %function
	.thumb_func
__isfinite:
	movw r12, #730
	b ws1_resolver
	.align 2

	.global __isfinitef
	.type __isfinitef, %function
	.thumb_func
__isfinitef:
	movw r12, #731
	b ws1_resolver
	.align 2

	.global __isfinitel
	.type __isfinitel, %function
	.thumb_func
__isfinitel:
	movw r12, #732
	b ws1_resolver
	.align 2

	.global __isinf
	.type __isinf, %function
	.thumb_func
__isinf:
	movw r12, #733
	b ws1_resolver
	.align 2

	.global __isinff
	.type __isinff, %function
	.thumb_func
__isinff:
	movw r12, #734
	b ws1_resolver
	.align 2

	.global __isinfl
	.type __isinfl, %function
	.thumb_func
__isinfl:
	movw r12, #735
	b ws1_resolver
	.align 2

	.global __isnan
	.type __isnan, %function
	.thumb_func
__isnan:
	movw r12, #736
	b ws1_resolver
	.align 2

	.global __isnanf
	.type __isnanf, %function
	.thumb_func
__isnanf:
	movw r12, #737
	b ws1_resolver
	.align 2

	.global __isnanl
	.type __isnanl, %function
	.thumb_func
__isnanl:
	movw r12, #738
	b ws1_resolver
	.align 2

	.global __isnormal
	.type __isnormal, %function
	.thumb_func
__isnormal:
	movw r12, #739
	b ws1_resolver
	.align 2

	.global __isnormalf
	.type __isnormalf, %function
	.thumb_func
__isnormalf:
	movw r12, #740
	b ws1_resolver
	.align 2

	.global __isnormall
	.type __isnormall, %function
	.thumb_func
__isnormall:
	movw r12, #741
	b ws1_resolver
	.align 2

	.global __libc_current_sigrtmax
	.type __libc_current_sigrtmax, %function
	.thumb_func
__libc_current_sigrtmax:
	movw r12, #742
	b ws1_resolver
	.align 2

	.global __libc_current_sigrtmin
	.type __libc_current_sigrtmin, %function
	.thumb_func
__libc_current_sigrtmin:
	movw r12, #743
	b ws1_resolver
	.align 2

	.global __libc_init
	.type __libc_init, %function
	.thumb_func
__libc_init:
	movw r12, #744
	b ws1_resolver
	.align 2

	.global __llseek
	.type __llseek, %function
	.thumb_func
__llseek:
	movw r12, #745
	b ws1_resolver
	.align 2

	.global __loc_aton
	.type __loc_aton, %function
	.thumb_func
__loc_aton:
	movw r12, #746
	b ws1_resolver
	.align 2

	.global __loc_ntoa
	.type __loc_ntoa, %function
	.thumb_func
__loc_ntoa:
	movw r12, #747
	b ws1_resolver
	.align 2

	.global __malloc_hook
	.type __malloc_hook, %function
	.thumb_func
__malloc_hook:
	movw r12, #748
	b ws1_resolver
	.align 2

	.global __memalign_hook
	.type __memalign_hook, %function
	.thumb_func
__memalign_hook:
	movw r12, #749
	b ws1_resolver
	.align 2

	.global __memrchr_chk
	.type __memrchr_chk, %function
	.thumb_func
__memrchr_chk:
	movw r12, #750
	b ws1_resolver
	.align 2

	.global __mmap2
	.type __mmap2, %function
	.thumb_func
__mmap2:
	movw r12, #751
	b ws1_resolver
	.align 2

	.global __ns_format_ttl
	.type __ns_format_ttl, %function
	.thumb_func
__ns_format_ttl:
	movw r12, #752
	b ws1_resolver
	.align 2

	.global __ns_get16
	.type __ns_get16, %function
	.thumb_func
__ns_get16:
	movw r12, #753
	b ws1_resolver
	.align 2

	.global __ns_get32
	.type __ns_get32, %function
	.thumb_func
__ns_get32:
	movw r12, #754
	b ws1_resolver
	.align 2

	.global __ns_initparse
	.type __ns_initparse, %function
	.thumb_func
__ns_initparse:
	movw r12, #755
	b ws1_resolver
	.align 2

	.global __ns_makecanon
	.type __ns_makecanon, %function
	.thumb_func
__ns_makecanon:
	movw r12, #756
	b ws1_resolver
	.align 2

	.global __ns_msg_getflag
	.type __ns_msg_getflag, %function
	.thumb_func
__ns_msg_getflag:
	movw r12, #757
	b ws1_resolver
	.align 2

	.global __ns_name_compress
	.type __ns_name_compress, %function
	.thumb_func
__ns_name_compress:
	movw r12, #758
	b ws1_resolver
	.align 2

	.global __ns_name_ntol
	.type __ns_name_ntol, %function
	.thumb_func
__ns_name_ntol:
	movw r12, #759
	b ws1_resolver
	.align 2

	.global __ns_name_ntop
	.type __ns_name_ntop, %function
	.thumb_func
__ns_name_ntop:
	movw r12, #760
	b ws1_resolver
	.align 2

	.global __ns_name_pack
	.type __ns_name_pack, %function
	.thumb_func
__ns_name_pack:
	movw r12, #761
	b ws1_resolver
	.align 2

	.global __ns_name_pton
	.type __ns_name_pton, %function
	.thumb_func
__ns_name_pton:
	movw r12, #762
	b ws1_resolver
	.align 2

	.global __ns_name_rollback
	.type __ns_name_rollback, %function
	.thumb_func
__ns_name_rollback:
	movw r12, #763
	b ws1_resolver
	.align 2

	.global __ns_name_skip
	.type __ns_name_skip, %function
	.thumb_func
__ns_name_skip:
	movw r12, #764
	b ws1_resolver
	.align 2

	.global __ns_name_uncompress
	.type __ns_name_uncompress, %function
	.thumb_func
__ns_name_uncompress:
	movw r12, #765
	b ws1_resolver
	.align 2

	.global __ns_name_unpack
	.type __ns_name_unpack, %function
	.thumb_func
__ns_name_unpack:
	movw r12, #766
	b ws1_resolver
	.align 2

	.global __ns_parserr
	.type __ns_parserr, %function
	.thumb_func
__ns_parserr:
	movw r12, #767
	b ws1_resolver
	.align 2

	.global __ns_put16
	.type __ns_put16, %function
	.thumb_func
__ns_put16:
	movw r12, #768
	b ws1_resolver
	.align 2

	.global __ns_put32
	.type __ns_put32, %function
	.thumb_func
__ns_put32:
	movw r12, #769
	b ws1_resolver
	.align 2

	.global __ns_samename
	.type __ns_samename, %function
	.thumb_func
__ns_samename:
	movw r12, #770
	b ws1_resolver
	.align 2

	.global __ns_skiprr
	.type __ns_skiprr, %function
	.thumb_func
__ns_skiprr:
	movw r12, #771
	b ws1_resolver
	.align 2

	.global __ns_sprintrr
	.type __ns_sprintrr, %function
	.thumb_func
__ns_sprintrr:
	movw r12, #772
	b ws1_resolver
	.align 2

	.global __ns_sprintrrf
	.type __ns_sprintrrf, %function
	.thumb_func
__ns_sprintrrf:
	movw r12, #773
	b ws1_resolver
	.align 2

	.global __open
	.type __open, %function
	.thumb_func
__open:
	movw r12, #774
	b ws1_resolver
	.align 2

	.global __open_2
	.type __open_2, %function
	.thumb_func
__open_2:
	movw r12, #775
	b ws1_resolver
	.align 2

	.global __openat
	.type __openat, %function
	.thumb_func
__openat:
	movw r12, #776
	b ws1_resolver
	.align 2

	.global __openat_2
	.type __openat_2, %function
	.thumb_func
__openat_2:
	movw r12, #777
	b ws1_resolver
	.align 2

	.global __p_cdname
	.type __p_cdname, %function
	.thumb_func
__p_cdname:
	movw r12, #778
	b ws1_resolver
	.align 2

	.global __p_cdnname
	.type __p_cdnname, %function
	.thumb_func
__p_cdnname:
	movw r12, #779
	b ws1_resolver
	.align 2

	.global __p_class
	.type __p_class, %function
	.thumb_func
__p_class:
	movw r12, #780
	b ws1_resolver
	.align 2

	.global __p_class_syms
	.type __p_class_syms, %function
	.thumb_func
__p_class_syms:
	movw r12, #781
	b ws1_resolver
	.align 2

	.global __p_fqname
	.type __p_fqname, %function
	.thumb_func
__p_fqname:
	movw r12, #782
	b ws1_resolver
	.align 2

	.global __p_fqnname
	.type __p_fqnname, %function
	.thumb_func
__p_fqnname:
	movw r12, #783
	b ws1_resolver
	.align 2

	.global __p_option
	.type __p_option, %function
	.thumb_func
__p_option:
	movw r12, #784
	b ws1_resolver
	.align 2

	.global __p_query
	.type __p_query, %function
	.thumb_func
__p_query:
	movw r12, #785
	b ws1_resolver
	.align 2

	.global __p_rcode
	.type __p_rcode, %function
	.thumb_func
__p_rcode:
	movw r12, #786
	b ws1_resolver
	.align 2

	.global __p_secstodate
	.type __p_secstodate, %function
	.thumb_func
__p_secstodate:
	movw r12, #787
	b ws1_resolver
	.align 2

	.global __p_time
	.type __p_time, %function
	.thumb_func
__p_time:
	movw r12, #788
	b ws1_resolver
	.align 2

	.global __p_type
	.type __p_type, %function
	.thumb_func
__p_type:
	movw r12, #789
	b ws1_resolver
	.align 2

	.global __p_type_syms
	.type __p_type_syms, %function
	.thumb_func
__p_type_syms:
	movw r12, #790
	b ws1_resolver
	.align 2

	.global __page_shift
	.type __page_shift, %function
	.thumb_func
__page_shift:
	movw r12, #791
	b ws1_resolver
	.align 2

	.global __page_size
	.type __page_size, %function
	.thumb_func
__page_size:
	movw r12, #792
	b ws1_resolver
	.align 2

	.global __ppoll
	.type __ppoll, %function
	.thumb_func
__ppoll:
	movw r12, #793
	b ws1_resolver
	.align 2

	.global __ppoll64_chk
	.type __ppoll64_chk, %function
	.thumb_func
__ppoll64_chk:
	movw r12, #794
	b ws1_resolver
	.align 2

	.global __ppoll_chk
	.type __ppoll_chk, %function
	.thumb_func
__ppoll_chk:
	movw r12, #795
	b ws1_resolver
	.align 2

	.global __pselect6
	.type __pselect6, %function
	.thumb_func
__pselect6:
	movw r12, #796
	b ws1_resolver
	.align 2

	.global __pthread_cleanup_pop
	.type __pthread_cleanup_pop, %function
	.thumb_func
__pthread_cleanup_pop:
	movw r12, #797
	b ws1_resolver
	.align 2

	.global __pthread_cleanup_push
	.type __pthread_cleanup_push, %function
	.thumb_func
__pthread_cleanup_push:
	movw r12, #798
	b ws1_resolver
	.align 2

	.global __pthread_gettid
	.type __pthread_gettid, %function
	.thumb_func
__pthread_gettid:
	movw r12, #799
	b ws1_resolver
	.align 2

	.global __ptrace
	.type __ptrace, %function
	.thumb_func
__ptrace:
	movw r12, #800
	b ws1_resolver
	.align 2

	.global __putlong
	.type __putlong, %function
	.thumb_func
__putlong:
	movw r12, #801
	b ws1_resolver
	.align 2

	.global __putshort
	.type __putshort, %function
	.thumb_func
__putshort:
	movw r12, #802
	b ws1_resolver
	.align 2

	.global __readlinkat_chk
	.type __readlinkat_chk, %function
	.thumb_func
__readlinkat_chk:
	movw r12, #803
	b ws1_resolver
	.align 2

	.global __realloc_hook
	.type __realloc_hook, %function
	.thumb_func
__realloc_hook:
	movw r12, #804
	b ws1_resolver
	.align 2

	.global __reboot
	.type __reboot, %function
	.thumb_func
__reboot:
	movw r12, #805
	b ws1_resolver
	.align 2

	.global __recvfrom_chk
	.type __recvfrom_chk, %function
	.thumb_func
__recvfrom_chk:
	movw r12, #806
	b ws1_resolver
	.align 2

	.global __register_atfork
	.type __register_atfork, %function
	.thumb_func
__register_atfork:
	movw r12, #807
	b ws1_resolver
	.align 2

	.global __res_close
	.type __res_close, %function
	.thumb_func
__res_close:
	movw r12, #808
	b ws1_resolver
	.align 2

	.global __res_dnok
	.type __res_dnok, %function
	.thumb_func
__res_dnok:
	movw r12, #809
	b ws1_resolver
	.align 2

	.global __res_hnok
	.type __res_hnok, %function
	.thumb_func
__res_hnok:
	movw r12, #810
	b ws1_resolver
	.align 2

	.global __res_hostalias
	.type __res_hostalias, %function
	.thumb_func
__res_hostalias:
	movw r12, #811
	b ws1_resolver
	.align 2

	.global __res_isourserver
	.type __res_isourserver, %function
	.thumb_func
__res_isourserver:
	movw r12, #812
	b ws1_resolver
	.align 2

	.global __res_mailok
	.type __res_mailok, %function
	.thumb_func
__res_mailok:
	movw r12, #813
	b ws1_resolver
	.align 2

	.global __res_nameinquery
	.type __res_nameinquery, %function
	.thumb_func
__res_nameinquery:
	movw r12, #814
	b ws1_resolver
	.align 2

	.global __res_nclose
	.type __res_nclose, %function
	.thumb_func
__res_nclose:
	movw r12, #815
	b ws1_resolver
	.align 2

	.global __res_ninit
	.type __res_ninit, %function
	.thumb_func
__res_ninit:
	movw r12, #816
	b ws1_resolver
	.align 2

	.global __res_nmkquery
	.type __res_nmkquery, %function
	.thumb_func
__res_nmkquery:
	movw r12, #817
	b ws1_resolver
	.align 2

	.global __res_nquery
	.type __res_nquery, %function
	.thumb_func
__res_nquery:
	movw r12, #818
	b ws1_resolver
	.align 2

	.global __res_nquerydomain
	.type __res_nquerydomain, %function
	.thumb_func
__res_nquerydomain:
	movw r12, #819
	b ws1_resolver
	.align 2

	.global __res_nsearch
	.type __res_nsearch, %function
	.thumb_func
__res_nsearch:
	movw r12, #820
	b ws1_resolver
	.align 2

	.global __res_nsend
	.type __res_nsend, %function
	.thumb_func
__res_nsend:
	movw r12, #821
	b ws1_resolver
	.align 2

	.global __res_ownok
	.type __res_ownok, %function
	.thumb_func
__res_ownok:
	movw r12, #822
	b ws1_resolver
	.align 2

	.global __res_queriesmatch
	.type __res_queriesmatch, %function
	.thumb_func
__res_queriesmatch:
	movw r12, #823
	b ws1_resolver
	.align 2

	.global __res_querydomain
	.type __res_querydomain, %function
	.thumb_func
__res_querydomain:
	movw r12, #824
	b ws1_resolver
	.align 2

	.global __res_randomid
	.type __res_randomid, %function
	.thumb_func
__res_randomid:
	movw r12, #825
	b ws1_resolver
	.align 2

	.global __res_send
	.type __res_send, %function
	.thumb_func
__res_send:
	movw r12, #826
	b ws1_resolver
	.align 2

	.global __res_send_setqhook
	.type __res_send_setqhook, %function
	.thumb_func
__res_send_setqhook:
	movw r12, #827
	b ws1_resolver
	.align 2

	.global __res_send_setrhook
	.type __res_send_setrhook, %function
	.thumb_func
__res_send_setrhook:
	movw r12, #828
	b ws1_resolver
	.align 2

	.global __rt_sigaction
	.type __rt_sigaction, %function
	.thumb_func
__rt_sigaction:
	movw r12, #829
	b ws1_resolver
	.align 2

	.global __rt_sigpending
	.type __rt_sigpending, %function
	.thumb_func
__rt_sigpending:
	movw r12, #830
	b ws1_resolver
	.align 2

	.global __rt_sigprocmask
	.type __rt_sigprocmask, %function
	.thumb_func
__rt_sigprocmask:
	movw r12, #831
	b ws1_resolver
	.align 2

	.global __rt_sigsuspend
	.type __rt_sigsuspend, %function
	.thumb_func
__rt_sigsuspend:
	movw r12, #832
	b ws1_resolver
	.align 2

	.global __rt_sigtimedwait
	.type __rt_sigtimedwait, %function
	.thumb_func
__rt_sigtimedwait:
	movw r12, #833
	b ws1_resolver
	.align 2

	.global __sF
	.type __sF, %function
	.thumb_func
__sF:
	movw r12, #834
	b ws1_resolver
	.align 2

	.global __sched_cpualloc
	.type __sched_cpualloc, %function
	.thumb_func
__sched_cpualloc:
	movw r12, #835
	b ws1_resolver
	.align 2

	.global __sched_cpucount
	.type __sched_cpucount, %function
	.thumb_func
__sched_cpucount:
	movw r12, #836
	b ws1_resolver
	.align 2

	.global __sched_cpufree
	.type __sched_cpufree, %function
	.thumb_func
__sched_cpufree:
	movw r12, #837
	b ws1_resolver
	.align 2

	.global __sched_getaffinity
	.type __sched_getaffinity, %function
	.thumb_func
__sched_getaffinity:
	movw r12, #838
	b ws1_resolver
	.align 2

	.global __sclose
	.type __sclose, %function
	.thumb_func
__sclose:
	movw r12, #839
	b ws1_resolver
	.align 2

	.global __sdidinit
	.type __sdidinit, %function
	.thumb_func
__sdidinit:
	movw r12, #840
	b ws1_resolver
	.align 2

	.global __sendto_chk
	.type __sendto_chk, %function
	.thumb_func
__sendto_chk:
	movw r12, #841
	b ws1_resolver
	.align 2

	.global __set_errno
	.type __set_errno, %function
	.thumb_func
__set_errno:
	movw r12, #842
	b ws1_resolver
	.align 2

	.global __set_tid_address
	.type __set_tid_address, %function
	.thumb_func
__set_tid_address:
	movw r12, #843
	b ws1_resolver
	.align 2

	.global __sflags
	.type __sflags, %function
	.thumb_func
__sflags:
	movw r12, #844
	b ws1_resolver
	.align 2

	.global __sflush
	.type __sflush, %function
	.thumb_func
__sflush:
	movw r12, #845
	b ws1_resolver
	.align 2

	.global __sfp
	.type __sfp, %function
	.thumb_func
__sfp:
	movw r12, #846
	b ws1_resolver
	.align 2

	.global __sglue
	.type __sglue, %function
	.thumb_func
__sglue:
	movw r12, #847
	b ws1_resolver
	.align 2

	.global __sigaction
	.type __sigaction, %function
	.thumb_func
__sigaction:
	movw r12, #848
	b ws1_resolver
	.align 2

	.global __sinit
	.type __sinit, %function
	.thumb_func
__sinit:
	movw r12, #849
	b ws1_resolver
	.align 2

	.global __smakebuf
	.type __smakebuf, %function
	.thumb_func
__smakebuf:
	movw r12, #850
	b ws1_resolver
	.align 2

	.global __socket
	.type __socket, %function
	.thumb_func
__socket:
	movw r12, #851
	b ws1_resolver
	.align 2

	.global __sread
	.type __sread, %function
	.thumb_func
__sread:
	movw r12, #852
	b ws1_resolver
	.align 2

	.global __srefill
	.type __srefill, %function
	.thumb_func
__srefill:
	movw r12, #853
	b ws1_resolver
	.align 2

	.global __srget
	.type __srget, %function
	.thumb_func
__srget:
	movw r12, #854
	b ws1_resolver
	.align 2

	.global __sseek
	.type __sseek, %function
	.thumb_func
__sseek:
	movw r12, #855
	b ws1_resolver
	.align 2

	.global __statfs64
	.type __statfs64, %function
	.thumb_func
__statfs64:
	movw r12, #856
	b ws1_resolver
	.align 2

	.global __stpncpy_chk2
	.type __stpncpy_chk2, %function
	.thumb_func
__stpncpy_chk2:
	movw r12, #857
	b ws1_resolver
	.align 2

	.global __strlcat_chk
	.type __strlcat_chk, %function
	.thumb_func
__strlcat_chk:
	movw r12, #858
	b ws1_resolver
	.align 2

	.global __strlcpy_chk
	.type __strlcpy_chk, %function
	.thumb_func
__strlcpy_chk:
	movw r12, #859
	b ws1_resolver
	.align 2

	.global __strncpy_chk2
	.type __strncpy_chk2, %function
	.thumb_func
__strncpy_chk2:
	movw r12, #860
	b ws1_resolver
	.align 2

	.global __swbuf
	.type __swbuf, %function
	.thumb_func
__swbuf:
	movw r12, #861
	b ws1_resolver
	.align 2

	.global __swrite
	.type __swrite, %function
	.thumb_func
__swrite:
	movw r12, #862
	b ws1_resolver
	.align 2

	.global __swsetup
	.type __swsetup, %function
	.thumb_func
__swsetup:
	movw r12, #863
	b ws1_resolver
	.align 2

	.global __sym_ntop
	.type __sym_ntop, %function
	.thumb_func
__sym_ntop:
	movw r12, #864
	b ws1_resolver
	.align 2

	.global __sym_ntos
	.type __sym_ntos, %function
	.thumb_func
__sym_ntos:
	movw r12, #865
	b ws1_resolver
	.align 2

	.global __sym_ston
	.type __sym_ston, %function
	.thumb_func
__sym_ston:
	movw r12, #866
	b ws1_resolver
	.align 2

	.global __system_property_add
	.type __system_property_add, %function
	.thumb_func
__system_property_add:
	movw r12, #867
	b ws1_resolver
	.align 2

	.global __system_property_area_init
	.type __system_property_area_init, %function
	.thumb_func
__system_property_area_init:
	movw r12, #868
	b ws1_resolver
	.align 2

	.global __system_property_area_serial
	.type __system_property_area_serial, %function
	.thumb_func
__system_property_area_serial:
	movw r12, #869
	b ws1_resolver
	.align 2

	.global __system_property_foreach
	.type __system_property_foreach, %function
	.thumb_func
__system_property_foreach:
	movw r12, #870
	b ws1_resolver
	.align 2

	.global __system_property_read_callback
	.type __system_property_read_callback, %function
	.thumb_func
__system_property_read_callback:
	movw r12, #871
	b ws1_resolver
	.align 2

	.global __system_property_serial
	.type __system_property_serial, %function
	.thumb_func
__system_property_serial:
	movw r12, #872
	b ws1_resolver
	.align 2

	.global __system_property_set_filename
	.type __system_property_set_filename, %function
	.thumb_func
__system_property_set_filename:
	movw r12, #873
	b ws1_resolver
	.align 2

	.global __system_property_update
	.type __system_property_update, %function
	.thumb_func
__system_property_update:
	movw r12, #874
	b ws1_resolver
	.align 2

	.global __system_property_wait_any
	.type __system_property_wait_any, %function
	.thumb_func
__system_property_wait_any:
	movw r12, #875
	b ws1_resolver
	.align 2

	.global __timer_create
	.type __timer_create, %function
	.thumb_func
__timer_create:
	movw r12, #876
	b ws1_resolver
	.align 2

	.global __timer_delete
	.type __timer_delete, %function
	.thumb_func
__timer_delete:
	movw r12, #877
	b ws1_resolver
	.align 2

	.global __timer_getoverrun
	.type __timer_getoverrun, %function
	.thumb_func
__timer_getoverrun:
	movw r12, #878
	b ws1_resolver
	.align 2

	.global __timer_gettime
	.type __timer_gettime, %function
	.thumb_func
__timer_gettime:
	movw r12, #879
	b ws1_resolver
	.align 2

	.global __timer_settime
	.type __timer_settime, %function
	.thumb_func
__timer_settime:
	movw r12, #880
	b ws1_resolver
	.align 2

	.global __tls_get_addr
	.type __tls_get_addr, %function
	.thumb_func
__tls_get_addr:
	movw r12, #881
	b ws1_resolver
	.align 2

	.global __wait4
	.type __wait4, %function
	.thumb_func
__wait4:
	movw r12, #882
	b ws1_resolver
	.align 2

	.global __waitid
	.type __waitid, %function
	.thumb_func
__waitid:
	movw r12, #883
	b ws1_resolver
	.align 2

	.global _ctype_
	.type _ctype_, %function
	.thumb_func
_ctype_:
	movw r12, #884
	b ws1_resolver
	.align 2

	.global _flushlbf
	.type _flushlbf, %function
	.thumb_func
_flushlbf:
	movw r12, #885
	b ws1_resolver
	.align 2

	.global _fwalk
	.type _fwalk, %function
	.thumb_func
_fwalk:
	movw r12, #886
	b ws1_resolver
	.align 2

	.global _getlong
	.type _getlong, %function
	.thumb_func
_getlong:
	movw r12, #887
	b ws1_resolver
	.align 2

	.global _getshort
	.type _getshort, %function
	.thumb_func
_getshort:
	movw r12, #888
	b ws1_resolver
	.align 2

	.global _resolv_delete_cache_for_net
	.type _resolv_delete_cache_for_net, %function
	.thumb_func
_resolv_delete_cache_for_net:
	movw r12, #889
	b ws1_resolver
	.align 2

	.global _resolv_flush_cache_for_net
	.type _resolv_flush_cache_for_net, %function
	.thumb_func
_resolv_flush_cache_for_net:
	movw r12, #890
	b ws1_resolver
	.align 2

	.global _resolv_set_nameservers_for_net
	.type _resolv_set_nameservers_for_net, %function
	.thumb_func
_resolv_set_nameservers_for_net:
	movw r12, #891
	b ws1_resolver
	.align 2

	.global _tolower_tab_
	.type _tolower_tab_, %function
	.thumb_func
_tolower_tab_:
	movw r12, #892
	b ws1_resolver
	.align 2

	.global _toupper_tab_
	.type _toupper_tab_, %function
	.thumb_func
_toupper_tab_:
	movw r12, #893
	b ws1_resolver
	.align 2

	.global accept
	.type accept, %function
	.thumb_func
accept:
	movw r12, #894
	b ws1_resolver
	.align 2

	.global accept4
	.type accept4, %function
	.thumb_func
accept4:
	movw r12, #895
	b ws1_resolver
	.align 2

	.global acct
	.type acct, %function
	.thumb_func
acct:
	movw r12, #896
	b ws1_resolver
	.align 2

	.global adjtimex
	.type adjtimex, %function
	.thumb_func
adjtimex:
	movw r12, #897
	b ws1_resolver
	.align 2

	.global aligned_alloc
	.type aligned_alloc, %function
	.thumb_func
aligned_alloc:
	movw r12, #898
	b ws1_resolver
	.align 2

	.global alphasort
	.type alphasort, %function
	.thumb_func
alphasort:
	movw r12, #899
	b ws1_resolver
	.align 2

	.global alphasort64
	.type alphasort64, %function
	.thumb_func
alphasort64:
	movw r12, #900
	b ws1_resolver
	.align 2

	.global android_fdsan_close_with_tag
	.type android_fdsan_close_with_tag, %function
	.thumb_func
android_fdsan_close_with_tag:
	movw r12, #901
	b ws1_resolver
	.align 2

	.global android_fdsan_create_owner_tag
	.type android_fdsan_create_owner_tag, %function
	.thumb_func
android_fdsan_create_owner_tag:
	movw r12, #902
	b ws1_resolver
	.align 2

	.global android_fdsan_exchange_owner_tag
	.type android_fdsan_exchange_owner_tag, %function
	.thumb_func
android_fdsan_exchange_owner_tag:
	movw r12, #903
	b ws1_resolver
	.align 2

	.global android_fdsan_get_error_level
	.type android_fdsan_get_error_level, %function
	.thumb_func
android_fdsan_get_error_level:
	movw r12, #904
	b ws1_resolver
	.align 2

	.global android_fdsan_get_fd_table
	.type android_fdsan_get_fd_table, %function
	.thumb_func
android_fdsan_get_fd_table:
	movw r12, #905
	b ws1_resolver
	.align 2

	.global android_fdsan_get_owner_tag
	.type android_fdsan_get_owner_tag, %function
	.thumb_func
android_fdsan_get_owner_tag:
	movw r12, #906
	b ws1_resolver
	.align 2

	.global android_fdsan_get_tag_type
	.type android_fdsan_get_tag_type, %function
	.thumb_func
android_fdsan_get_tag_type:
	movw r12, #907
	b ws1_resolver
	.align 2

	.global android_fdsan_get_tag_value
	.type android_fdsan_get_tag_value, %function
	.thumb_func
android_fdsan_get_tag_value:
	movw r12, #908
	b ws1_resolver
	.align 2

	.global android_fdsan_set_error_level
	.type android_fdsan_set_error_level, %function
	.thumb_func
android_fdsan_set_error_level:
	movw r12, #909
	b ws1_resolver
	.align 2

	.global android_fdtrack_compare_exchange_hook
	.type android_fdtrack_compare_exchange_hook, %function
	.thumb_func
android_fdtrack_compare_exchange_hook:
	movw r12, #910
	b ws1_resolver
	.align 2

	.global android_fdtrack_get_enabled
	.type android_fdtrack_get_enabled, %function
	.thumb_func
android_fdtrack_get_enabled:
	movw r12, #911
	b ws1_resolver
	.align 2

	.global android_fdtrack_set_enabled
	.type android_fdtrack_set_enabled, %function
	.thumb_func
android_fdtrack_set_enabled:
	movw r12, #912
	b ws1_resolver
	.align 2

	.global android_get_device_api_level
	.type android_get_device_api_level, %function
	.thumb_func
android_get_device_api_level:
	movw r12, #913
	b ws1_resolver
	.align 2

	.global android_getaddrinfofornet
	.type android_getaddrinfofornet, %function
	.thumb_func
android_getaddrinfofornet:
	movw r12, #914
	b ws1_resolver
	.align 2

	.global android_getaddrinfofornetcontext
	.type android_getaddrinfofornetcontext, %function
	.thumb_func
android_getaddrinfofornetcontext:
	movw r12, #915
	b ws1_resolver
	.align 2

	.global android_gethostbyaddrfornet
	.type android_gethostbyaddrfornet, %function
	.thumb_func
android_gethostbyaddrfornet:
	movw r12, #916
	b ws1_resolver
	.align 2

	.global android_gethostbyaddrfornetcontext
	.type android_gethostbyaddrfornetcontext, %function
	.thumb_func
android_gethostbyaddrfornetcontext:
	movw r12, #917
	b ws1_resolver
	.align 2

	.global android_gethostbynamefornet
	.type android_gethostbynamefornet, %function
	.thumb_func
android_gethostbynamefornet:
	movw r12, #918
	b ws1_resolver
	.align 2

	.global android_gethostbynamefornetcontext
	.type android_gethostbynamefornetcontext, %function
	.thumb_func
android_gethostbynamefornetcontext:
	movw r12, #919
	b ws1_resolver
	.align 2

	.global android_mallopt
	.type android_mallopt, %function
	.thumb_func
android_mallopt:
	movw r12, #920
	b ws1_resolver
	.align 2

	.global android_net_res_stats_aggregate
	.type android_net_res_stats_aggregate, %function
	.thumb_func
android_net_res_stats_aggregate:
	movw r12, #921
	b ws1_resolver
	.align 2

	.global android_net_res_stats_get_info_for_net
	.type android_net_res_stats_get_info_for_net, %function
	.thumb_func
android_net_res_stats_get_info_for_net:
	movw r12, #922
	b ws1_resolver
	.align 2

	.global android_net_res_stats_get_usable_servers
	.type android_net_res_stats_get_usable_servers, %function
	.thumb_func
android_net_res_stats_get_usable_servers:
	movw r12, #923
	b ws1_resolver
	.align 2

	.global android_set_abort_message
	.type android_set_abort_message, %function
	.thumb_func
android_set_abort_message:
	movw r12, #924
	b ws1_resolver
	.align 2

	.global android_unsafe_frame_pointer_chase
	.type android_unsafe_frame_pointer_chase, %function
	.thumb_func
android_unsafe_frame_pointer_chase:
	movw r12, #925
	b ws1_resolver
	.align 2

	.global arc4random
	.type arc4random, %function
	.thumb_func
arc4random:
	movw r12, #926
	b ws1_resolver
	.align 2

	.global arc4random_addrandom
	.type arc4random_addrandom, %function
	.thumb_func
arc4random_addrandom:
	movw r12, #927
	b ws1_resolver
	.align 2

	.global arc4random_buf
	.type arc4random_buf, %function
	.thumb_func
arc4random_buf:
	movw r12, #928
	b ws1_resolver
	.align 2

	.global arc4random_stir
	.type arc4random_stir, %function
	.thumb_func
arc4random_stir:
	movw r12, #929
	b ws1_resolver
	.align 2

	.global arc4random_uniform
	.type arc4random_uniform, %function
	.thumb_func
arc4random_uniform:
	movw r12, #930
	b ws1_resolver
	.align 2

	.global asctime64
	.type asctime64, %function
	.thumb_func
asctime64:
	movw r12, #931
	b ws1_resolver
	.align 2

	.global asctime64_r
	.type asctime64_r, %function
	.thumb_func
asctime64_r:
	movw r12, #932
	b ws1_resolver
	.align 2

	.global asprintf
	.type asprintf, %function
	.thumb_func
asprintf:
	movw r12, #933
	b ws1_resolver
	.align 2

	.global basename_r
	.type basename_r, %function
	.thumb_func
basename_r:
	movw r12, #934
	b ws1_resolver
	.align 2

	.global bind
	.type bind, %function
	.thumb_func
bind:
	movw r12, #935
	b ws1_resolver
	.align 2

	.global bindresvport
	.type bindresvport, %function
	.thumb_func
bindresvport:
	movw r12, #936
	b ws1_resolver
	.align 2

	.global brk
	.type brk, %function
	.thumb_func
brk:
	movw r12, #937
	b ws1_resolver
	.align 2

	.global bsd_signal
	.type bsd_signal, %function
	.thumb_func
bsd_signal:
	movw r12, #938
	b ws1_resolver
	.align 2

	.global call_once
	.type call_once, %function
	.thumb_func
call_once:
	movw r12, #939
	b ws1_resolver
	.align 2

	.global capget
	.type capget, %function
	.thumb_func
capget:
	movw r12, #940
	b ws1_resolver
	.align 2

	.global capset
	.type capset, %function
	.thumb_func
capset:
	movw r12, #941
	b ws1_resolver
	.align 2

	.global catclose
	.type catclose, %function
	.thumb_func
catclose:
	movw r12, #942
	b ws1_resolver
	.align 2

	.global catgets
	.type catgets, %function
	.thumb_func
catgets:
	movw r12, #943
	b ws1_resolver
	.align 2

	.global catopen
	.type catopen, %function
	.thumb_func
catopen:
	movw r12, #944
	b ws1_resolver
	.align 2

	.global cfsetspeed
	.type cfsetspeed, %function
	.thumb_func
cfsetspeed:
	movw r12, #945
	b ws1_resolver
	.align 2

	.global clearerr_unlocked
	.type clearerr_unlocked, %function
	.thumb_func
clearerr_unlocked:
	movw r12, #946
	b ws1_resolver
	.align 2

	.global clock_adjtime
	.type clock_adjtime, %function
	.thumb_func
clock_adjtime:
	movw r12, #947
	b ws1_resolver
	.align 2

	.global clone
	.type clone, %function
	.thumb_func
clone:
	movw r12, #948
	b ws1_resolver
	.align 2

	.global cnd_broadcast
	.type cnd_broadcast, %function
	.thumb_func
cnd_broadcast:
	movw r12, #949
	b ws1_resolver
	.align 2

	.global cnd_destroy
	.type cnd_destroy, %function
	.thumb_func
cnd_destroy:
	movw r12, #950
	b ws1_resolver
	.align 2

	.global cnd_init
	.type cnd_init, %function
	.thumb_func
cnd_init:
	movw r12, #951
	b ws1_resolver
	.align 2

	.global cnd_signal
	.type cnd_signal, %function
	.thumb_func
cnd_signal:
	movw r12, #952
	b ws1_resolver
	.align 2

	.global cnd_timedwait
	.type cnd_timedwait, %function
	.thumb_func
cnd_timedwait:
	movw r12, #953
	b ws1_resolver
	.align 2

	.global cnd_wait
	.type cnd_wait, %function
	.thumb_func
cnd_wait:
	movw r12, #954
	b ws1_resolver
	.align 2

	.global connect
	.type connect, %function
	.thumb_func
connect:
	movw r12, #955
	b ws1_resolver
	.align 2

	.global ctime64
	.type ctime64, %function
	.thumb_func
ctime64:
	movw r12, #956
	b ws1_resolver
	.align 2

	.global ctime64_r
	.type ctime64_r, %function
	.thumb_func
ctime64_r:
	movw r12, #957
	b ws1_resolver
	.align 2

	.global delete_module
	.type delete_module, %function
	.thumb_func
delete_module:
	movw r12, #958
	b ws1_resolver
	.align 2

	.global dirname_r
	.type dirname_r, %function
	.thumb_func
dirname_r:
	movw r12, #959
	b ws1_resolver
	.align 2

	.global dlmalloc
	.type dlmalloc, %function
	.thumb_func
dlmalloc:
	movw r12, #960
	b ws1_resolver
	.align 2

	.global dlmalloc_inspect_all
	.type dlmalloc_inspect_all, %function
	.thumb_func
dlmalloc_inspect_all:
	movw r12, #961
	b ws1_resolver
	.align 2

	.global dlmalloc_trim
	.type dlmalloc_trim, %function
	.thumb_func
dlmalloc_trim:
	movw r12, #962
	b ws1_resolver
	.align 2

	.global dlmalloc_usable_size
	.type dlmalloc_usable_size, %function
	.thumb_func
dlmalloc_usable_size:
	movw r12, #963
	b ws1_resolver
	.align 2

	.global dn_expand
	.type dn_expand, %function
	.thumb_func
dn_expand:
	movw r12, #964
	b ws1_resolver
	.align 2

	.global dprintf
	.type dprintf, %function
	.thumb_func
dprintf:
	movw r12, #965
	b ws1_resolver
	.align 2

	.global dup3
	.type dup3, %function
	.thumb_func
dup3:
	movw r12, #966
	b ws1_resolver
	.align 2

	.global duplocale
	.type duplocale, %function
	.thumb_func
duplocale:
	movw r12, #967
	b ws1_resolver
	.align 2

	.global endhostent
	.type endhostent, %function
	.thumb_func
endhostent:
	movw r12, #968
	b ws1_resolver
	.align 2

	.global endmntent
	.type endmntent, %function
	.thumb_func
endmntent:
	movw r12, #969
	b ws1_resolver
	.align 2

	.global endnetent
	.type endnetent, %function
	.thumb_func
endnetent:
	movw r12, #970
	b ws1_resolver
	.align 2

	.global endprotoent
	.type endprotoent, %function
	.thumb_func
endprotoent:
	movw r12, #971
	b ws1_resolver
	.align 2

	.global endservent
	.type endservent, %function
	.thumb_func
endservent:
	movw r12, #972
	b ws1_resolver
	.align 2

	.global endutent
	.type endutent, %function
	.thumb_func
endutent:
	movw r12, #973
	b ws1_resolver
	.align 2

	.global epoll_create1
	.type epoll_create1, %function
	.thumb_func
epoll_create1:
	movw r12, #974
	b ws1_resolver
	.align 2

	.global epoll_pwait
	.type epoll_pwait, %function
	.thumb_func
epoll_pwait:
	movw r12, #975
	b ws1_resolver
	.align 2

	.global epoll_pwait64
	.type epoll_pwait64, %function
	.thumb_func
epoll_pwait64:
	movw r12, #976
	b ws1_resolver
	.align 2

	.global error
	.type error, %function
	.thumb_func
error:
	movw r12, #977
	b ws1_resolver
	.align 2

	.global error_at_line
	.type error_at_line, %function
	.thumb_func
error_at_line:
	movw r12, #978
	b ws1_resolver
	.align 2

	.global error_message_count
	.type error_message_count, %function
	.thumb_func
error_message_count:
	movw r12, #979
	b ws1_resolver
	.align 2

	.global error_one_per_line
	.type error_one_per_line, %function
	.thumb_func
error_one_per_line:
	movw r12, #980
	b ws1_resolver
	.align 2

	.global error_print_progname
	.type error_print_progname, %function
	.thumb_func
error_print_progname:
	movw r12, #981
	b ws1_resolver
	.align 2

	.global ether_aton
	.type ether_aton, %function
	.thumb_func
ether_aton:
	movw r12, #982
	b ws1_resolver
	.align 2

	.global ether_aton_r
	.type ether_aton_r, %function
	.thumb_func
ether_aton_r:
	movw r12, #983
	b ws1_resolver
	.align 2

	.global ether_ntoa
	.type ether_ntoa, %function
	.thumb_func
ether_ntoa:
	movw r12, #984
	b ws1_resolver
	.align 2

	.global ether_ntoa_r
	.type ether_ntoa_r, %function
	.thumb_func
ether_ntoa_r:
	movw r12, #985
	b ws1_resolver
	.align 2

	.global fallocate
	.type fallocate, %function
	.thumb_func
fallocate:
	movw r12, #986
	b ws1_resolver
	.align 2

	.global fallocate64
	.type fallocate64, %function
	.thumb_func
fallocate64:
	movw r12, #987
	b ws1_resolver
	.align 2

	.global feof_unlocked
	.type feof_unlocked, %function
	.thumb_func
feof_unlocked:
	movw r12, #988
	b ws1_resolver
	.align 2

	.global ferror_unlocked
	.type ferror_unlocked, %function
	.thumb_func
ferror_unlocked:
	movw r12, #989
	b ws1_resolver
	.align 2

	.global fexecve
	.type fexecve, %function
	.thumb_func
fexecve:
	movw r12, #990
	b ws1_resolver
	.align 2

	.global fflush_unlocked
	.type fflush_unlocked, %function
	.thumb_func
fflush_unlocked:
	movw r12, #991
	b ws1_resolver
	.align 2

	.global fgetc_unlocked
	.type fgetc_unlocked, %function
	.thumb_func
fgetc_unlocked:
	movw r12, #992
	b ws1_resolver
	.align 2

	.global fgetln
	.type fgetln, %function
	.thumb_func
fgetln:
	movw r12, #993
	b ws1_resolver
	.align 2

	.global fgetpos64
	.type fgetpos64, %function
	.thumb_func
fgetpos64:
	movw r12, #994
	b ws1_resolver
	.align 2

	.global fgets_unlocked
	.type fgets_unlocked, %function
	.thumb_func
fgets_unlocked:
	movw r12, #995
	b ws1_resolver
	.align 2

	.global fgetxattr
	.type fgetxattr, %function
	.thumb_func
fgetxattr:
	movw r12, #996
	b ws1_resolver
	.align 2

	.global fileno_unlocked
	.type fileno_unlocked, %function
	.thumb_func
fileno_unlocked:
	movw r12, #997
	b ws1_resolver
	.align 2

	.global flistxattr
	.type flistxattr, %function
	.thumb_func
flistxattr:
	movw r12, #998
	b ws1_resolver
	.align 2

	.global fmemopen
	.type fmemopen, %function
	.thumb_func
fmemopen:
	movw r12, #999
	b ws1_resolver
	.align 2

	.global forkpty
	.type forkpty, %function
	.thumb_func
forkpty:
	movw r12, #1000
	b ws1_resolver
	.align 2

	.global fpurge
	.type fpurge, %function
	.thumb_func
fpurge:
	movw r12, #1001
	b ws1_resolver
	.align 2

	.global fputc_unlocked
	.type fputc_unlocked, %function
	.thumb_func
fputc_unlocked:
	movw r12, #1002
	b ws1_resolver
	.align 2

	.global fputs_unlocked
	.type fputs_unlocked, %function
	.thumb_func
fputs_unlocked:
	movw r12, #1003
	b ws1_resolver
	.align 2

	.global fread_unlocked
	.type fread_unlocked, %function
	.thumb_func
fread_unlocked:
	movw r12, #1004
	b ws1_resolver
	.align 2

	.global free_malloc_leak_info
	.type free_malloc_leak_info, %function
	.thumb_func
free_malloc_leak_info:
	movw r12, #1005
	b ws1_resolver
	.align 2

	.global freeaddrinfo
	.type freeaddrinfo, %function
	.thumb_func
freeaddrinfo:
	movw r12, #1006
	b ws1_resolver
	.align 2

	.global freeifaddrs
	.type freeifaddrs, %function
	.thumb_func
freeifaddrs:
	movw r12, #1007
	b ws1_resolver
	.align 2

	.global freelocale
	.type freelocale, %function
	.thumb_func
freelocale:
	movw r12, #1008
	b ws1_resolver
	.align 2

	.global fremovexattr
	.type fremovexattr, %function
	.thumb_func
fremovexattr:
	movw r12, #1009
	b ws1_resolver
	.align 2

	.global fsetpos64
	.type fsetpos64, %function
	.thumb_func
fsetpos64:
	movw r12, #1010
	b ws1_resolver
	.align 2

	.global fsetxattr
	.type fsetxattr, %function
	.thumb_func
fsetxattr:
	movw r12, #1011
	b ws1_resolver
	.align 2

	.global fstatfs
	.type fstatfs, %function
	.thumb_func
fstatfs:
	movw r12, #1012
	b ws1_resolver
	.align 2

	.global fstatfs64
	.type fstatfs64, %function
	.thumb_func
fstatfs64:
	movw r12, #1013
	b ws1_resolver
	.align 2

	.global fts_children
	.type fts_children, %function
	.thumb_func
fts_children:
	movw r12, #1014
	b ws1_resolver
	.align 2

	.global fts_close
	.type fts_close, %function
	.thumb_func
fts_close:
	movw r12, #1015
	b ws1_resolver
	.align 2

	.global fts_open
	.type fts_open, %function
	.thumb_func
fts_open:
	movw r12, #1016
	b ws1_resolver
	.align 2

	.global fts_read
	.type fts_read, %function
	.thumb_func
fts_read:
	movw r12, #1017
	b ws1_resolver
	.align 2

	.global fts_set
	.type fts_set, %function
	.thumb_func
fts_set:
	movw r12, #1018
	b ws1_resolver
	.align 2

	.global funopen
	.type funopen, %function
	.thumb_func
funopen:
	movw r12, #1019
	b ws1_resolver
	.align 2

	.global funopen64
	.type funopen64, %function
	.thumb_func
funopen64:
	movw r12, #1020
	b ws1_resolver
	.align 2

	.global futimens
	.type futimens, %function
	.thumb_func
futimens:
	movw r12, #1021
	b ws1_resolver
	.align 2

	.global futimes
	.type futimes, %function
	.thumb_func
futimes:
	movw r12, #1022
	b ws1_resolver
	.align 2

	.global futimesat
	.type futimesat, %function
	.thumb_func
futimesat:
	movw r12, #1023
	b ws1_resolver
	.align 2

	.global fwrite_unlocked
	.type fwrite_unlocked, %function
	.thumb_func
fwrite_unlocked:
	movw r12, #1024
	b ws1_resolver
	.align 2

	.global gai_strerror
	.type gai_strerror, %function
	.thumb_func
gai_strerror:
	movw r12, #1025
	b ws1_resolver
	.align 2

	.global get_avphys_pages
	.type get_avphys_pages, %function
	.thumb_func
get_avphys_pages:
	movw r12, #1026
	b ws1_resolver
	.align 2

	.global get_malloc_leak_info
	.type get_malloc_leak_info, %function
	.thumb_func
get_malloc_leak_info:
	movw r12, #1027
	b ws1_resolver
	.align 2

	.global get_nprocs
	.type get_nprocs, %function
	.thumb_func
get_nprocs:
	movw r12, #1028
	b ws1_resolver
	.align 2

	.global get_nprocs_conf
	.type get_nprocs_conf, %function
	.thumb_func
get_nprocs_conf:
	movw r12, #1029
	b ws1_resolver
	.align 2

	.global get_phys_pages
	.type get_phys_pages, %function
	.thumb_func
get_phys_pages:
	movw r12, #1030
	b ws1_resolver
	.align 2

	.global getaddrinfo
	.type getaddrinfo, %function
	.thumb_func
getaddrinfo:
	movw r12, #1031
	b ws1_resolver
	.align 2

	.global getauxval
	.type getauxval, %function
	.thumb_func
getauxval:
	movw r12, #1032
	b ws1_resolver
	.align 2

	.global getdelim
	.type getdelim, %function
	.thumb_func
getdelim:
	movw r12, #1033
	b ws1_resolver
	.align 2

	.global getdents
	.type getdents, %function
	.thumb_func
getdents:
	movw r12, #1034
	b ws1_resolver
	.align 2

	.global getdomainname
	.type getdomainname, %function
	.thumb_func
getdomainname:
	movw r12, #1035
	b ws1_resolver
	.align 2

	.global getentropy
	.type getentropy, %function
	.thumb_func
getentropy:
	movw r12, #1036
	b ws1_resolver
	.align 2

	.global gethostbyaddr
	.type gethostbyaddr, %function
	.thumb_func
gethostbyaddr:
	movw r12, #1037
	b ws1_resolver
	.align 2

	.global gethostbyaddr_r
	.type gethostbyaddr_r, %function
	.thumb_func
gethostbyaddr_r:
	movw r12, #1038
	b ws1_resolver
	.align 2

	.global gethostbyname
	.type gethostbyname, %function
	.thumb_func
gethostbyname:
	movw r12, #1039
	b ws1_resolver
	.align 2

	.global gethostbyname2
	.type gethostbyname2, %function
	.thumb_func
gethostbyname2:
	movw r12, #1040
	b ws1_resolver
	.align 2

	.global gethostbyname2_r
	.type gethostbyname2_r, %function
	.thumb_func
gethostbyname2_r:
	movw r12, #1041
	b ws1_resolver
	.align 2

	.global gethostbyname_r
	.type gethostbyname_r, %function
	.thumb_func
gethostbyname_r:
	movw r12, #1042
	b ws1_resolver
	.align 2

	.global gethostent
	.type gethostent, %function
	.thumb_func
gethostent:
	movw r12, #1043
	b ws1_resolver
	.align 2

	.global getifaddrs
	.type getifaddrs, %function
	.thumb_func
getifaddrs:
	movw r12, #1044
	b ws1_resolver
	.align 2

	.global getline
	.type getline, %function
	.thumb_func
getline:
	movw r12, #1045
	b ws1_resolver
	.align 2

	.global getloadavg
	.type getloadavg, %function
	.thumb_func
getloadavg:
	movw r12, #1046
	b ws1_resolver
	.align 2

	.global getlogin_r
	.type getlogin_r, %function
	.thumb_func
getlogin_r:
	movw r12, #1047
	b ws1_resolver
	.align 2

	.global getmntent_r
	.type getmntent_r, %function
	.thumb_func
getmntent_r:
	movw r12, #1048
	b ws1_resolver
	.align 2

	.global getnameinfo
	.type getnameinfo, %function
	.thumb_func
getnameinfo:
	movw r12, #1049
	b ws1_resolver
	.align 2

	.global getnetent
	.type getnetent, %function
	.thumb_func
getnetent:
	movw r12, #1050
	b ws1_resolver
	.align 2

	.global getpeername
	.type getpeername, %function
	.thumb_func
getpeername:
	movw r12, #1051
	b ws1_resolver
	.align 2

	.global getprogname
	.type getprogname, %function
	.thumb_func
getprogname:
	movw r12, #1052
	b ws1_resolver
	.align 2

	.global getprotoent
	.type getprotoent, %function
	.thumb_func
getprotoent:
	movw r12, #1053
	b ws1_resolver
	.align 2

	.global getpt
	.type getpt, %function
	.thumb_func
getpt:
	movw r12, #1054
	b ws1_resolver
	.align 2

	.global getrandom
	.type getrandom, %function
	.thumb_func
getrandom:
	movw r12, #1055
	b ws1_resolver
	.align 2

	.global getservbyname
	.type getservbyname, %function
	.thumb_func
getservbyname:
	movw r12, #1056
	b ws1_resolver
	.align 2

	.global getservbyport
	.type getservbyport, %function
	.thumb_func
getservbyport:
	movw r12, #1057
	b ws1_resolver
	.align 2

	.global getservent
	.type getservent, %function
	.thumb_func
getservent:
	movw r12, #1058
	b ws1_resolver
	.align 2

	.global getsockname
	.type getsockname, %function
	.thumb_func
getsockname:
	movw r12, #1059
	b ws1_resolver
	.align 2

	.global getsockopt
	.type getsockopt, %function
	.thumb_func
getsockopt:
	movw r12, #1060
	b ws1_resolver
	.align 2

	.global getutent
	.type getutent, %function
	.thumb_func
getutent:
	movw r12, #1061
	b ws1_resolver
	.align 2

	.global getxattr
	.type getxattr, %function
	.thumb_func
getxattr:
	movw r12, #1062
	b ws1_resolver
	.align 2

	.global glob
	.type glob, %function
	.thumb_func
glob:
	movw r12, #1063
	b ws1_resolver
	.align 2

	.global globfree
	.type globfree, %function
	.thumb_func
globfree:
	movw r12, #1064
	b ws1_resolver
	.align 2

	.global gmtime64
	.type gmtime64, %function
	.thumb_func
gmtime64:
	movw r12, #1065
	b ws1_resolver
	.align 2

	.global gmtime64_r
	.type gmtime64_r, %function
	.thumb_func
gmtime64_r:
	movw r12, #1066
	b ws1_resolver
	.align 2

	.global grantpt
	.type grantpt, %function
	.thumb_func
grantpt:
	movw r12, #1067
	b ws1_resolver
	.align 2

	.global hasmntopt
	.type hasmntopt, %function
	.thumb_func
hasmntopt:
	movw r12, #1068
	b ws1_resolver
	.align 2

	.global hcreate_r
	.type hcreate_r, %function
	.thumb_func
hcreate_r:
	movw r12, #1069
	b ws1_resolver
	.align 2

	.global hdestroy_r
	.type hdestroy_r, %function
	.thumb_func
hdestroy_r:
	movw r12, #1070
	b ws1_resolver
	.align 2

	.global herror
	.type herror, %function
	.thumb_func
herror:
	movw r12, #1071
	b ws1_resolver
	.align 2

	.global hsearch_r
	.type hsearch_r, %function
	.thumb_func
hsearch_r:
	movw r12, #1072
	b ws1_resolver
	.align 2

	.global hstrerror
	.type hstrerror, %function
	.thumb_func
hstrerror:
	movw r12, #1073
	b ws1_resolver
	.align 2

	.global iconv
	.type iconv, %function
	.thumb_func
iconv:
	movw r12, #1074
	b ws1_resolver
	.align 2

	.global iconv_close
	.type iconv_close, %function
	.thumb_func
iconv_close:
	movw r12, #1075
	b ws1_resolver
	.align 2

	.global iconv_open
	.type iconv_open, %function
	.thumb_func
iconv_open:
	movw r12, #1076
	b ws1_resolver
	.align 2

	.global if_freenameindex
	.type if_freenameindex, %function
	.thumb_func
if_freenameindex:
	movw r12, #1077
	b ws1_resolver
	.align 2

	.global if_indextoname
	.type if_indextoname, %function
	.thumb_func
if_indextoname:
	movw r12, #1078
	b ws1_resolver
	.align 2

	.global if_nameindex
	.type if_nameindex, %function
	.thumb_func
if_nameindex:
	movw r12, #1079
	b ws1_resolver
	.align 2

	.global if_nametoindex
	.type if_nametoindex, %function
	.thumb_func
if_nametoindex:
	movw r12, #1080
	b ws1_resolver
	.align 2

	.global imaxabs
	.type imaxabs, %function
	.thumb_func
imaxabs:
	movw r12, #1081
	b ws1_resolver
	.align 2

	.global imaxdiv
	.type imaxdiv, %function
	.thumb_func
imaxdiv:
	movw r12, #1082
	b ws1_resolver
	.align 2

	.global in6addr_any
	.type in6addr_any, %function
	.thumb_func
in6addr_any:
	movw r12, #1083
	b ws1_resolver
	.align 2

	.global in6addr_loopback
	.type in6addr_loopback, %function
	.thumb_func
in6addr_loopback:
	movw r12, #1084
	b ws1_resolver
	.align 2

	.global inet_lnaof
	.type inet_lnaof, %function
	.thumb_func
inet_lnaof:
	movw r12, #1085
	b ws1_resolver
	.align 2

	.global inet_makeaddr
	.type inet_makeaddr, %function
	.thumb_func
inet_makeaddr:
	movw r12, #1086
	b ws1_resolver
	.align 2

	.global inet_netof
	.type inet_netof, %function
	.thumb_func
inet_netof:
	movw r12, #1087
	b ws1_resolver
	.align 2

	.global inet_network
	.type inet_network, %function
	.thumb_func
inet_network:
	movw r12, #1088
	b ws1_resolver
	.align 2

	.global inet_nsap_addr
	.type inet_nsap_addr, %function
	.thumb_func
inet_nsap_addr:
	movw r12, #1089
	b ws1_resolver
	.align 2

	.global inet_nsap_ntoa
	.type inet_nsap_ntoa, %function
	.thumb_func
inet_nsap_ntoa:
	movw r12, #1090
	b ws1_resolver
	.align 2

	.global inet_ntoa
	.type inet_ntoa, %function
	.thumb_func
inet_ntoa:
	movw r12, #1091
	b ws1_resolver
	.align 2

	.global init_module
	.type init_module, %function
	.thumb_func
init_module:
	movw r12, #1092
	b ws1_resolver
	.align 2

	.global initstate
	.type initstate, %function
	.thumb_func
initstate:
	movw r12, #1093
	b ws1_resolver
	.align 2

	.global inotify_init1
	.type inotify_init1, %function
	.thumb_func
inotify_init1:
	movw r12, #1094
	b ws1_resolver
	.align 2

	.global insque
	.type insque, %function
	.thumb_func
insque:
	movw r12, #1095
	b ws1_resolver
	.align 2

	.global isalnum_l
	.type isalnum_l, %function
	.thumb_func
isalnum_l:
	movw r12, #1096
	b ws1_resolver
	.align 2

	.global isalpha_l
	.type isalpha_l, %function
	.thumb_func
isalpha_l:
	movw r12, #1097
	b ws1_resolver
	.align 2

	.global isblank_l
	.type isblank_l, %function
	.thumb_func
isblank_l:
	movw r12, #1098
	b ws1_resolver
	.align 2

	.global iscntrl_l
	.type iscntrl_l, %function
	.thumb_func
iscntrl_l:
	movw r12, #1099
	b ws1_resolver
	.align 2

	.global isdigit_l
	.type isdigit_l, %function
	.thumb_func
isdigit_l:
	movw r12, #1100
	b ws1_resolver
	.align 2

	.global isfinite
	.type isfinite, %function
	.thumb_func
isfinite:
	movw r12, #1101
	b ws1_resolver
	.align 2

	.global isfinitef
	.type isfinitef, %function
	.thumb_func
isfinitef:
	movw r12, #1102
	b ws1_resolver
	.align 2

	.global isfinitel
	.type isfinitel, %function
	.thumb_func
isfinitel:
	movw r12, #1103
	b ws1_resolver
	.align 2

	.global isgraph_l
	.type isgraph_l, %function
	.thumb_func
isgraph_l:
	movw r12, #1104
	b ws1_resolver
	.align 2

	.global isinf
	.type isinf, %function
	.thumb_func
isinf:
	movw r12, #1105
	b ws1_resolver
	.align 2

	.global isinff
	.type isinff, %function
	.thumb_func
isinff:
	movw r12, #1106
	b ws1_resolver
	.align 2

	.global isinfl
	.type isinfl, %function
	.thumb_func
isinfl:
	movw r12, #1107
	b ws1_resolver
	.align 2

	.global islower_l
	.type islower_l, %function
	.thumb_func
islower_l:
	movw r12, #1108
	b ws1_resolver
	.align 2

	.global isnan
	.type isnan, %function
	.thumb_func
isnan:
	movw r12, #1109
	b ws1_resolver
	.align 2

	.global isnanf
	.type isnanf, %function
	.thumb_func
isnanf:
	movw r12, #1110
	b ws1_resolver
	.align 2

	.global isnanl
	.type isnanl, %function
	.thumb_func
isnanl:
	movw r12, #1111
	b ws1_resolver
	.align 2

	.global isnormal
	.type isnormal, %function
	.thumb_func
isnormal:
	movw r12, #1112
	b ws1_resolver
	.align 2

	.global isnormalf
	.type isnormalf, %function
	.thumb_func
isnormalf:
	movw r12, #1113
	b ws1_resolver
	.align 2

	.global isnormall
	.type isnormall, %function
	.thumb_func
isnormall:
	movw r12, #1114
	b ws1_resolver
	.align 2

	.global isprint_l
	.type isprint_l, %function
	.thumb_func
isprint_l:
	movw r12, #1115
	b ws1_resolver
	.align 2

	.global ispunct_l
	.type ispunct_l, %function
	.thumb_func
ispunct_l:
	movw r12, #1116
	b ws1_resolver
	.align 2

	.global issetugid
	.type issetugid, %function
	.thumb_func
issetugid:
	movw r12, #1117
	b ws1_resolver
	.align 2

	.global isspace_l
	.type isspace_l, %function
	.thumb_func
isspace_l:
	movw r12, #1118
	b ws1_resolver
	.align 2

	.global isupper_l
	.type isupper_l, %function
	.thumb_func
isupper_l:
	movw r12, #1119
	b ws1_resolver
	.align 2

	.global iswalnum_l
	.type iswalnum_l, %function
	.thumb_func
iswalnum_l:
	movw r12, #1120
	b ws1_resolver
	.align 2

	.global iswalpha_l
	.type iswalpha_l, %function
	.thumb_func
iswalpha_l:
	movw r12, #1121
	b ws1_resolver
	.align 2

	.global iswblank_l
	.type iswblank_l, %function
	.thumb_func
iswblank_l:
	movw r12, #1122
	b ws1_resolver
	.align 2

	.global iswcntrl_l
	.type iswcntrl_l, %function
	.thumb_func
iswcntrl_l:
	movw r12, #1123
	b ws1_resolver
	.align 2

	.global iswctype_l
	.type iswctype_l, %function
	.thumb_func
iswctype_l:
	movw r12, #1124
	b ws1_resolver
	.align 2

	.global iswdigit_l
	.type iswdigit_l, %function
	.thumb_func
iswdigit_l:
	movw r12, #1125
	b ws1_resolver
	.align 2

	.global iswgraph_l
	.type iswgraph_l, %function
	.thumb_func
iswgraph_l:
	movw r12, #1126
	b ws1_resolver
	.align 2

	.global iswlower_l
	.type iswlower_l, %function
	.thumb_func
iswlower_l:
	movw r12, #1127
	b ws1_resolver
	.align 2

	.global iswprint_l
	.type iswprint_l, %function
	.thumb_func
iswprint_l:
	movw r12, #1128
	b ws1_resolver
	.align 2

	.global iswpunct_l
	.type iswpunct_l, %function
	.thumb_func
iswpunct_l:
	movw r12, #1129
	b ws1_resolver
	.align 2

	.global iswspace_l
	.type iswspace_l, %function
	.thumb_func
iswspace_l:
	movw r12, #1130
	b ws1_resolver
	.align 2

	.global iswupper_l
	.type iswupper_l, %function
	.thumb_func
iswupper_l:
	movw r12, #1131
	b ws1_resolver
	.align 2

	.global iswxdigit_l
	.type iswxdigit_l, %function
	.thumb_func
iswxdigit_l:
	movw r12, #1132
	b ws1_resolver
	.align 2

	.global isxdigit_l
	.type isxdigit_l, %function
	.thumb_func
isxdigit_l:
	movw r12, #1133
	b ws1_resolver
	.align 2

	.global ldexp
	.type ldexp, %function
	.thumb_func
ldexp:
	movw r12, #1134
	b ws1_resolver
	.align 2

	.global lgetxattr
	.type lgetxattr, %function
	.thumb_func
lgetxattr:
	movw r12, #1135
	b ws1_resolver
	.align 2

	.global linkat
	.type linkat, %function
	.thumb_func
linkat:
	movw r12, #1136
	b ws1_resolver
	.align 2

	.global listen
	.type listen, %function
	.thumb_func
listen:
	movw r12, #1137
	b ws1_resolver
	.align 2

	.global listxattr
	.type listxattr, %function
	.thumb_func
listxattr:
	movw r12, #1138
	b ws1_resolver
	.align 2

	.global llistxattr
	.type llistxattr, %function
	.thumb_func
llistxattr:
	movw r12, #1139
	b ws1_resolver
	.align 2

	.global localtime64
	.type localtime64, %function
	.thumb_func
localtime64:
	movw r12, #1140
	b ws1_resolver
	.align 2

	.global localtime64_r
	.type localtime64_r, %function
	.thumb_func
localtime64_r:
	movw r12, #1141
	b ws1_resolver
	.align 2

	.global login_tty
	.type login_tty, %function
	.thumb_func
login_tty:
	movw r12, #1142
	b ws1_resolver
	.align 2

	.global lremovexattr
	.type lremovexattr, %function
	.thumb_func
lremovexattr:
	movw r12, #1143
	b ws1_resolver
	.align 2

	.global lsetxattr
	.type lsetxattr, %function
	.thumb_func
lsetxattr:
	movw r12, #1144
	b ws1_resolver
	.align 2

	.global lutimes
	.type lutimes, %function
	.thumb_func
lutimes:
	movw r12, #1145
	b ws1_resolver
	.align 2

	.global madvise
	.type madvise, %function
	.thumb_func
madvise:
	movw r12, #1146
	b ws1_resolver
	.align 2

	.global malloc_backtrace
	.type malloc_backtrace, %function
	.thumb_func
malloc_backtrace:
	movw r12, #1147
	b ws1_resolver
	.align 2

	.global malloc_disable
	.type malloc_disable, %function
	.thumb_func
malloc_disable:
	movw r12, #1148
	b ws1_resolver
	.align 2

	.global malloc_enable
	.type malloc_enable, %function
	.thumb_func
malloc_enable:
	movw r12, #1149
	b ws1_resolver
	.align 2

	.global malloc_info
	.type malloc_info, %function
	.thumb_func
malloc_info:
	movw r12, #1150
	b ws1_resolver
	.align 2

	.global malloc_iterate
	.type malloc_iterate, %function
	.thumb_func
malloc_iterate:
	movw r12, #1151
	b ws1_resolver
	.align 2

	.global malloc_usable_size
	.type malloc_usable_size, %function
	.thumb_func
malloc_usable_size:
	movw r12, #1152
	b ws1_resolver
	.align 2

	.global mbsnrtowcs
	.type mbsnrtowcs, %function
	.thumb_func
mbsnrtowcs:
	movw r12, #1153
	b ws1_resolver
	.align 2

	.global memfd_create
	.type memfd_create, %function
	.thumb_func
memfd_create:
	movw r12, #1154
	b ws1_resolver
	.align 2

	.global memswap
	.type memswap, %function
	.thumb_func
memswap:
	movw r12, #1155
	b ws1_resolver
	.align 2

	.global mincore
	.type mincore, %function
	.thumb_func
mincore:
	movw r12, #1156
	b ws1_resolver
	.align 2

	.global mkfifoat
	.type mkfifoat, %function
	.thumb_func
mkfifoat:
	movw r12, #1157
	b ws1_resolver
	.align 2

	.global mknodat
	.type mknodat, %function
	.thumb_func
mknodat:
	movw r12, #1158
	b ws1_resolver
	.align 2

	.global mkostemp
	.type mkostemp, %function
	.thumb_func
mkostemp:
	movw r12, #1159
	b ws1_resolver
	.align 2

	.global mkostemp64
	.type mkostemp64, %function
	.thumb_func
mkostemp64:
	movw r12, #1160
	b ws1_resolver
	.align 2

	.global mkostemps
	.type mkostemps, %function
	.thumb_func
mkostemps:
	movw r12, #1161
	b ws1_resolver
	.align 2

	.global mkostemps64
	.type mkostemps64, %function
	.thumb_func
mkostemps64:
	movw r12, #1162
	b ws1_resolver
	.align 2

	.global mkstemp64
	.type mkstemp64, %function
	.thumb_func
mkstemp64:
	movw r12, #1163
	b ws1_resolver
	.align 2

	.global mkstemps
	.type mkstemps, %function
	.thumb_func
mkstemps:
	movw r12, #1164
	b ws1_resolver
	.align 2

	.global mkstemps64
	.type mkstemps64, %function
	.thumb_func
mkstemps64:
	movw r12, #1165
	b ws1_resolver
	.align 2

	.global mktime64
	.type mktime64, %function
	.thumb_func
mktime64:
	movw r12, #1166
	b ws1_resolver
	.align 2

	.global mlock2
	.type mlock2, %function
	.thumb_func
mlock2:
	movw r12, #1167
	b ws1_resolver
	.align 2

	.global mremap
	.type mremap, %function
	.thumb_func
mremap:
	movw r12, #1168
	b ws1_resolver
	.align 2

	.global msgctl
	.type msgctl, %function
	.thumb_func
msgctl:
	movw r12, #1169
	b ws1_resolver
	.align 2

	.global msgget
	.type msgget, %function
	.thumb_func
msgget:
	movw r12, #1170
	b ws1_resolver
	.align 2

	.global msgrcv
	.type msgrcv, %function
	.thumb_func
msgrcv:
	movw r12, #1171
	b ws1_resolver
	.align 2

	.global msgsnd
	.type msgsnd, %function
	.thumb_func
msgsnd:
	movw r12, #1172
	b ws1_resolver
	.align 2

	.global mtx_destroy
	.type mtx_destroy, %function
	.thumb_func
mtx_destroy:
	movw r12, #1173
	b ws1_resolver
	.align 2

	.global mtx_init
	.type mtx_init, %function
	.thumb_func
mtx_init:
	movw r12, #1174
	b ws1_resolver
	.align 2

	.global mtx_lock
	.type mtx_lock, %function
	.thumb_func
mtx_lock:
	movw r12, #1175
	b ws1_resolver
	.align 2

	.global mtx_timedlock
	.type mtx_timedlock, %function
	.thumb_func
mtx_timedlock:
	movw r12, #1176
	b ws1_resolver
	.align 2

	.global mtx_trylock
	.type mtx_trylock, %function
	.thumb_func
mtx_trylock:
	movw r12, #1177
	b ws1_resolver
	.align 2

	.global mtx_unlock
	.type mtx_unlock, %function
	.thumb_func
mtx_unlock:
	movw r12, #1178
	b ws1_resolver
	.align 2

	.global newlocale
	.type newlocale, %function
	.thumb_func
newlocale:
	movw r12, #1179
	b ws1_resolver
	.align 2

	.global nl_langinfo
	.type nl_langinfo, %function
	.thumb_func
nl_langinfo:
	movw r12, #1180
	b ws1_resolver
	.align 2

	.global nl_langinfo_l
	.type nl_langinfo_l, %function
	.thumb_func
nl_langinfo_l:
	movw r12, #1181
	b ws1_resolver
	.align 2

	.global nsdispatch
	.type nsdispatch, %function
	.thumb_func
nsdispatch:
	movw r12, #1182
	b ws1_resolver
	.align 2

	.global open_memstream
	.type open_memstream, %function
	.thumb_func
open_memstream:
	movw r12, #1183
	b ws1_resolver
	.align 2

	.global open_wmemstream
	.type open_wmemstream, %function
	.thumb_func
open_wmemstream:
	movw r12, #1184
	b ws1_resolver
	.align 2

	.global openat64
	.type openat64, %function
	.thumb_func
openat64:
	movw r12, #1185
	b ws1_resolver
	.align 2

	.global openpty
	.type openpty, %function
	.thumb_func
openpty:
	movw r12, #1186
	b ws1_resolver
	.align 2

	.global pclose
	.type pclose, %function
	.thumb_func
pclose:
	movw r12, #1187
	b ws1_resolver
	.align 2

	.global personality
	.type personality, %function
	.thumb_func
personality:
	movw r12, #1188
	b ws1_resolver
	.align 2

	.global pipe2
	.type pipe2, %function
	.thumb_func
pipe2:
	movw r12, #1189
	b ws1_resolver
	.align 2

	.global popen
	.type popen, %function
	.thumb_func
popen:
	movw r12, #1190
	b ws1_resolver
	.align 2

	.global posix_openpt
	.type posix_openpt, %function
	.thumb_func
posix_openpt:
	movw r12, #1191
	b ws1_resolver
	.align 2

	.global posix_spawnattr_getsigdefault64
	.type posix_spawnattr_getsigdefault64, %function
	.thumb_func
posix_spawnattr_getsigdefault64:
	movw r12, #1192
	b ws1_resolver
	.align 2

	.global posix_spawnattr_getsigmask64
	.type posix_spawnattr_getsigmask64, %function
	.thumb_func
posix_spawnattr_getsigmask64:
	movw r12, #1193
	b ws1_resolver
	.align 2

	.global posix_spawnattr_setsigdefault64
	.type posix_spawnattr_setsigdefault64, %function
	.thumb_func
posix_spawnattr_setsigdefault64:
	movw r12, #1194
	b ws1_resolver
	.align 2

	.global posix_spawnattr_setsigmask64
	.type posix_spawnattr_setsigmask64, %function
	.thumb_func
posix_spawnattr_setsigmask64:
	movw r12, #1195
	b ws1_resolver
	.align 2

	.global ppoll
	.type ppoll, %function
	.thumb_func
ppoll:
	movw r12, #1196
	b ws1_resolver
	.align 2

	.global ppoll64
	.type ppoll64, %function
	.thumb_func
ppoll64:
	movw r12, #1197
	b ws1_resolver
	.align 2

	.global preadv
	.type preadv, %function
	.thumb_func
preadv:
	movw r12, #1198
	b ws1_resolver
	.align 2

	.global preadv64
	.type preadv64, %function
	.thumb_func
preadv64:
	movw r12, #1199
	b ws1_resolver
	.align 2

	.global prlimit
	.type prlimit, %function
	.thumb_func
prlimit:
	movw r12, #1200
	b ws1_resolver
	.align 2

	.global prlimit64
	.type prlimit64, %function
	.thumb_func
prlimit64:
	movw r12, #1201
	b ws1_resolver
	.align 2

	.global process_vm_readv
	.type process_vm_readv, %function
	.thumb_func
process_vm_readv:
	movw r12, #1202
	b ws1_resolver
	.align 2

	.global process_vm_writev
	.type process_vm_writev, %function
	.thumb_func
process_vm_writev:
	movw r12, #1203
	b ws1_resolver
	.align 2

	.global pselect
	.type pselect, %function
	.thumb_func
pselect:
	movw r12, #1204
	b ws1_resolver
	.align 2

	.global pselect64
	.type pselect64, %function
	.thumb_func
pselect64:
	movw r12, #1205
	b ws1_resolver
	.align 2

	.global psiginfo
	.type psiginfo, %function
	.thumb_func
psiginfo:
	movw r12, #1206
	b ws1_resolver
	.align 2

	.global psignal
	.type psignal, %function
	.thumb_func
psignal:
	movw r12, #1207
	b ws1_resolver
	.align 2

	.global pthread_cond_clockwait
	.type pthread_cond_clockwait, %function
	.thumb_func
pthread_cond_clockwait:
	movw r12, #1208
	b ws1_resolver
	.align 2

	.global pthread_cond_timedwait_monotonic
	.type pthread_cond_timedwait_monotonic, %function
	.thumb_func
pthread_cond_timedwait_monotonic:
	movw r12, #1209
	b ws1_resolver
	.align 2

	.global pthread_cond_timedwait_monotonic_np
	.type pthread_cond_timedwait_monotonic_np, %function
	.thumb_func
pthread_cond_timedwait_monotonic_np:
	movw r12, #1210
	b ws1_resolver
	.align 2

	.global pthread_cond_timedwait_relative_np
	.type pthread_cond_timedwait_relative_np, %function
	.thumb_func
pthread_cond_timedwait_relative_np:
	movw r12, #1211
	b ws1_resolver
	.align 2

	.global pthread_cond_timeout_np
	.type pthread_cond_timeout_np, %function
	.thumb_func
pthread_cond_timeout_np:
	movw r12, #1212
	b ws1_resolver
	.align 2

	.global pthread_getattr_np
	.type pthread_getattr_np, %function
	.thumb_func
pthread_getattr_np:
	movw r12, #1213
	b ws1_resolver
	.align 2

	.global pthread_gettid_np
	.type pthread_gettid_np, %function
	.thumb_func
pthread_gettid_np:
	movw r12, #1214
	b ws1_resolver
	.align 2

	.global pthread_mutex_clocklock
	.type pthread_mutex_clocklock, %function
	.thumb_func
pthread_mutex_clocklock:
	movw r12, #1215
	b ws1_resolver
	.align 2

	.global pthread_mutex_lock_timeout_np
	.type pthread_mutex_lock_timeout_np, %function
	.thumb_func
pthread_mutex_lock_timeout_np:
	movw r12, #1216
	b ws1_resolver
	.align 2

	.global pthread_mutex_timedlock_monotonic_np
	.type pthread_mutex_timedlock_monotonic_np, %function
	.thumb_func
pthread_mutex_timedlock_monotonic_np:
	movw r12, #1217
	b ws1_resolver
	.align 2

	.global pthread_rwlock_clockrdlock
	.type pthread_rwlock_clockrdlock, %function
	.thumb_func
pthread_rwlock_clockrdlock:
	movw r12, #1218
	b ws1_resolver
	.align 2

	.global pthread_rwlock_clockwrlock
	.type pthread_rwlock_clockwrlock, %function
	.thumb_func
pthread_rwlock_clockwrlock:
	movw r12, #1219
	b ws1_resolver
	.align 2

	.global pthread_rwlock_timedrdlock_monotonic_np
	.type pthread_rwlock_timedrdlock_monotonic_np, %function
	.thumb_func
pthread_rwlock_timedrdlock_monotonic_np:
	movw r12, #1220
	b ws1_resolver
	.align 2

	.global pthread_rwlock_timedwrlock_monotonic_np
	.type pthread_rwlock_timedwrlock_monotonic_np, %function
	.thumb_func
pthread_rwlock_timedwrlock_monotonic_np:
	movw r12, #1221
	b ws1_resolver
	.align 2

	.global pthread_rwlockattr_getkind_np
	.type pthread_rwlockattr_getkind_np, %function
	.thumb_func
pthread_rwlockattr_getkind_np:
	movw r12, #1222
	b ws1_resolver
	.align 2

	.global pthread_rwlockattr_setkind_np
	.type pthread_rwlockattr_setkind_np, %function
	.thumb_func
pthread_rwlockattr_setkind_np:
	movw r12, #1223
	b ws1_resolver
	.align 2

	.global pthread_sigmask64
	.type pthread_sigmask64, %function
	.thumb_func
pthread_sigmask64:
	movw r12, #1224
	b ws1_resolver
	.align 2

	.global pthread_sigqueue
	.type pthread_sigqueue, %function
	.thumb_func
pthread_sigqueue:
	movw r12, #1225
	b ws1_resolver
	.align 2

	.global ptrace
	.type ptrace, %function
	.thumb_func
ptrace:
	movw r12, #1226
	b ws1_resolver
	.align 2

	.global ptsname
	.type ptsname, %function
	.thumb_func
ptsname:
	movw r12, #1227
	b ws1_resolver
	.align 2

	.global ptsname_r
	.type ptsname_r, %function
	.thumb_func
ptsname_r:
	movw r12, #1228
	b ws1_resolver
	.align 2

	.global pututline
	.type pututline, %function
	.thumb_func
pututline:
	movw r12, #1229
	b ws1_resolver
	.align 2

	.global putw
	.type putw, %function
	.thumb_func
putw:
	movw r12, #1230
	b ws1_resolver
	.align 2

	.global pvalloc
	.type pvalloc, %function
	.thumb_func
pvalloc:
	movw r12, #1231
	b ws1_resolver
	.align 2

	.global pwritev
	.type pwritev, %function
	.thumb_func
pwritev:
	movw r12, #1232
	b ws1_resolver
	.align 2

	.global pwritev64
	.type pwritev64, %function
	.thumb_func
pwritev64:
	movw r12, #1233
	b ws1_resolver
	.align 2

	.global quotactl
	.type quotactl, %function
	.thumb_func
quotactl:
	movw r12, #1234
	b ws1_resolver
	.align 2

	.global random
	.type random, %function
	.thumb_func
random:
	movw r12, #1235
	b ws1_resolver
	.align 2

	.global readahead
	.type readahead, %function
	.thumb_func
readahead:
	movw r12, #1236
	b ws1_resolver
	.align 2

	.global reallocarray
	.type reallocarray, %function
	.thumb_func
reallocarray:
	movw r12, #1237
	b ws1_resolver
	.align 2

	.global reboot
	.type reboot, %function
	.thumb_func
reboot:
	movw r12, #1238
	b ws1_resolver
	.align 2

	.global recv
	.type recv, %function
	.thumb_func
recv:
	movw r12, #1239
	b ws1_resolver
	.align 2

	.global recvfrom
	.type recvfrom, %function
	.thumb_func
recvfrom:
	movw r12, #1240
	b ws1_resolver
	.align 2

	.global recvmmsg
	.type recvmmsg, %function
	.thumb_func
recvmmsg:
	movw r12, #1241
	b ws1_resolver
	.align 2

	.global recvmsg
	.type recvmsg, %function
	.thumb_func
recvmsg:
	movw r12, #1242
	b ws1_resolver
	.align 2

	.global regcomp
	.type regcomp, %function
	.thumb_func
regcomp:
	movw r12, #1243
	b ws1_resolver
	.align 2

	.global regerror
	.type regerror, %function
	.thumb_func
regerror:
	movw r12, #1244
	b ws1_resolver
	.align 2

	.global regexec
	.type regexec, %function
	.thumb_func
regexec:
	movw r12, #1245
	b ws1_resolver
	.align 2

	.global regfree
	.type regfree, %function
	.thumb_func
regfree:
	movw r12, #1246
	b ws1_resolver
	.align 2

	.global removexattr
	.type removexattr, %function
	.thumb_func
removexattr:
	movw r12, #1247
	b ws1_resolver
	.align 2

	.global remque
	.type remque, %function
	.thumb_func
remque:
	movw r12, #1248
	b ws1_resolver
	.align 2

	.global renameat2
	.type renameat2, %function
	.thumb_func
renameat2:
	movw r12, #1249
	b ws1_resolver
	.align 2

	.global res_init
	.type res_init, %function
	.thumb_func
res_init:
	movw r12, #1250
	b ws1_resolver
	.align 2

	.global res_mkquery
	.type res_mkquery, %function
	.thumb_func
res_mkquery:
	movw r12, #1251
	b ws1_resolver
	.align 2

	.global res_query
	.type res_query, %function
	.thumb_func
res_query:
	movw r12, #1252
	b ws1_resolver
	.align 2

	.global res_search
	.type res_search, %function
	.thumb_func
res_search:
	movw r12, #1253
	b ws1_resolver
	.align 2

	.global sbrk
	.type sbrk, %function
	.thumb_func
sbrk:
	movw r12, #1254
	b ws1_resolver
	.align 2

	.global scandir
	.type scandir, %function
	.thumb_func
scandir:
	movw r12, #1255
	b ws1_resolver
	.align 2

	.global scandir64
	.type scandir64, %function
	.thumb_func
scandir64:
	movw r12, #1256
	b ws1_resolver
	.align 2

	.global scandirat
	.type scandirat, %function
	.thumb_func
scandirat:
	movw r12, #1257
	b ws1_resolver
	.align 2

	.global scandirat64
	.type scandirat64, %function
	.thumb_func
scandirat64:
	movw r12, #1258
	b ws1_resolver
	.align 2

	.global sched_getaffinity
	.type sched_getaffinity, %function
	.thumb_func
sched_getaffinity:
	movw r12, #1259
	b ws1_resolver
	.align 2

	.global sched_getcpu
	.type sched_getcpu, %function
	.thumb_func
sched_getcpu:
	movw r12, #1260
	b ws1_resolver
	.align 2

	.global sched_setaffinity
	.type sched_setaffinity, %function
	.thumb_func
sched_setaffinity:
	movw r12, #1261
	b ws1_resolver
	.align 2

	.global sem_clockwait
	.type sem_clockwait, %function
	.thumb_func
sem_clockwait:
	movw r12, #1262
	b ws1_resolver
	.align 2

	.global sem_timedwait_monotonic_np
	.type sem_timedwait_monotonic_np, %function
	.thumb_func
sem_timedwait_monotonic_np:
	movw r12, #1263
	b ws1_resolver
	.align 2

	.global semctl
	.type semctl, %function
	.thumb_func
semctl:
	movw r12, #1264
	b ws1_resolver
	.align 2

	.global semget
	.type semget, %function
	.thumb_func
semget:
	movw r12, #1265
	b ws1_resolver
	.align 2

	.global semop
	.type semop, %function
	.thumb_func
semop:
	movw r12, #1266
	b ws1_resolver
	.align 2

	.global semtimedop
	.type semtimedop, %function
	.thumb_func
semtimedop:
	movw r12, #1267
	b ws1_resolver
	.align 2

	.global send
	.type send, %function
	.thumb_func
send:
	movw r12, #1268
	b ws1_resolver
	.align 2

	.global sendfile64
	.type sendfile64, %function
	.thumb_func
sendfile64:
	movw r12, #1269
	b ws1_resolver
	.align 2

	.global sendmmsg
	.type sendmmsg, %function
	.thumb_func
sendmmsg:
	movw r12, #1270
	b ws1_resolver
	.align 2

	.global sendmsg
	.type sendmsg, %function
	.thumb_func
sendmsg:
	movw r12, #1271
	b ws1_resolver
	.align 2

	.global sendto
	.type sendto, %function
	.thumb_func
sendto:
	movw r12, #1272
	b ws1_resolver
	.align 2

	.global setdomainname
	.type setdomainname, %function
	.thumb_func
setdomainname:
	movw r12, #1273
	b ws1_resolver
	.align 2

	.global setfsgid
	.type setfsgid, %function
	.thumb_func
setfsgid:
	movw r12, #1274
	b ws1_resolver
	.align 2

	.global setfsuid
	.type setfsuid, %function
	.thumb_func
setfsuid:
	movw r12, #1275
	b ws1_resolver
	.align 2

	.global sethostent
	.type sethostent, %function
	.thumb_func
sethostent:
	movw r12, #1276
	b ws1_resolver
	.align 2

	.global setjmp
	.type setjmp, %function
	.thumb_func
setjmp:
	movw r12, #1277
	b ws1_resolver
	.align 2

	.global setmntent
	.type setmntent, %function
	.thumb_func
setmntent:
	movw r12, #1278
	b ws1_resolver
	.align 2

	.global setnetent
	.type setnetent, %function
	.thumb_func
setnetent:
	movw r12, #1279
	b ws1_resolver
	.align 2

	.global setns
	.type setns, %function
	.thumb_func
setns:
	movw r12, #1280
	b ws1_resolver
	.align 2

	.global setprogname
	.type setprogname, %function
	.thumb_func
setprogname:
	movw r12, #1281
	b ws1_resolver
	.align 2

	.global setprotoent
	.type setprotoent, %function
	.thumb_func
setprotoent:
	movw r12, #1282
	b ws1_resolver
	.align 2

	.global setservent
	.type setservent, %function
	.thumb_func
setservent:
	movw r12, #1283
	b ws1_resolver
	.align 2

	.global setsockopt
	.type setsockopt, %function
	.thumb_func
setsockopt:
	movw r12, #1284
	b ws1_resolver
	.align 2

	.global setstate
	.type setstate, %function
	.thumb_func
setstate:
	movw r12, #1285
	b ws1_resolver
	.align 2

	.global setutent
	.type setutent, %function
	.thumb_func
setutent:
	movw r12, #1286
	b ws1_resolver
	.align 2

	.global setxattr
	.type setxattr, %function
	.thumb_func
setxattr:
	movw r12, #1287
	b ws1_resolver
	.align 2

	.global shmat
	.type shmat, %function
	.thumb_func
shmat:
	movw r12, #1288
	b ws1_resolver
	.align 2

	.global shmctl
	.type shmctl, %function
	.thumb_func
shmctl:
	movw r12, #1289
	b ws1_resolver
	.align 2

	.global shmdt
	.type shmdt, %function
	.thumb_func
shmdt:
	movw r12, #1290
	b ws1_resolver
	.align 2

	.global shmget
	.type shmget, %function
	.thumb_func
shmget:
	movw r12, #1291
	b ws1_resolver
	.align 2

	.global shutdown
	.type shutdown, %function
	.thumb_func
shutdown:
	movw r12, #1292
	b ws1_resolver
	.align 2

	.global sigaction64
	.type sigaction64, %function
	.thumb_func
sigaction64:
	movw r12, #1293
	b ws1_resolver
	.align 2

	.global sigaddset64
	.type sigaddset64, %function
	.thumb_func
sigaddset64:
	movw r12, #1294
	b ws1_resolver
	.align 2

	.global sigaltstack
	.type sigaltstack, %function
	.thumb_func
sigaltstack:
	movw r12, #1295
	b ws1_resolver
	.align 2

	.global sigdelset64
	.type sigdelset64, %function
	.thumb_func
sigdelset64:
	movw r12, #1296
	b ws1_resolver
	.align 2

	.global sigemptyset64
	.type sigemptyset64, %function
	.thumb_func
sigemptyset64:
	movw r12, #1297
	b ws1_resolver
	.align 2

	.global sigfillset64
	.type sigfillset64, %function
	.thumb_func
sigfillset64:
	movw r12, #1298
	b ws1_resolver
	.align 2

	.global sighold
	.type sighold, %function
	.thumb_func
sighold:
	movw r12, #1299
	b ws1_resolver
	.align 2

	.global sigignore
	.type sigignore, %function
	.thumb_func
sigignore:
	movw r12, #1300
	b ws1_resolver
	.align 2

	.global siginterrupt
	.type siginterrupt, %function
	.thumb_func
siginterrupt:
	movw r12, #1301
	b ws1_resolver
	.align 2

	.global sigismember64
	.type sigismember64, %function
	.thumb_func
sigismember64:
	movw r12, #1302
	b ws1_resolver
	.align 2

	.global signalfd
	.type signalfd, %function
	.thumb_func
signalfd:
	movw r12, #1303
	b ws1_resolver
	.align 2

	.global signalfd64
	.type signalfd64, %function
	.thumb_func
signalfd64:
	movw r12, #1304
	b ws1_resolver
	.align 2

	.global sigpending64
	.type sigpending64, %function
	.thumb_func
sigpending64:
	movw r12, #1305
	b ws1_resolver
	.align 2

	.global sigprocmask64
	.type sigprocmask64, %function
	.thumb_func
sigprocmask64:
	movw r12, #1306
	b ws1_resolver
	.align 2

	.global sigrelse
	.type sigrelse, %function
	.thumb_func
sigrelse:
	movw r12, #1307
	b ws1_resolver
	.align 2

	.global sigset
	.type sigset, %function
	.thumb_func
sigset:
	movw r12, #1308
	b ws1_resolver
	.align 2

	.global sigsuspend64
	.type sigsuspend64, %function
	.thumb_func
sigsuspend64:
	movw r12, #1309
	b ws1_resolver
	.align 2

	.global sigtimedwait64
	.type sigtimedwait64, %function
	.thumb_func
sigtimedwait64:
	movw r12, #1310
	b ws1_resolver
	.align 2

	.global sigwait64
	.type sigwait64, %function
	.thumb_func
sigwait64:
	movw r12, #1311
	b ws1_resolver
	.align 2

	.global sigwaitinfo64
	.type sigwaitinfo64, %function
	.thumb_func
sigwaitinfo64:
	movw r12, #1312
	b ws1_resolver
	.align 2

	.global socket
	.type socket, %function
	.thumb_func
socket:
	movw r12, #1313
	b ws1_resolver
	.align 2

	.global socketpair
	.type socketpair, %function
	.thumb_func
socketpair:
	movw r12, #1314
	b ws1_resolver
	.align 2

	.global splice
	.type splice, %function
	.thumb_func
splice:
	movw r12, #1315
	b ws1_resolver
	.align 2

	.global srandom
	.type srandom, %function
	.thumb_func
srandom:
	movw r12, #1316
	b ws1_resolver
	.align 2

	.global statfs
	.type statfs, %function
	.thumb_func
statfs:
	movw r12, #1317
	b ws1_resolver
	.align 2

	.global statfs64
	.type statfs64, %function
	.thumb_func
statfs64:
	movw r12, #1318
	b ws1_resolver
	.align 2

	.global statx
	.type statx, %function
	.thumb_func
statx:
	movw r12, #1319
	b ws1_resolver
	.align 2

	.global strcasecmp_l
	.type strcasecmp_l, %function
	.thumb_func
strcasecmp_l:
	movw r12, #1320
	b ws1_resolver
	.align 2

	.global strchrnul
	.type strchrnul, %function
	.thumb_func
strchrnul:
	movw r12, #1321
	b ws1_resolver
	.align 2

	.global strcoll_l
	.type strcoll_l, %function
	.thumb_func
strcoll_l:
	movw r12, #1322
	b ws1_resolver
	.align 2

	.global strerror_l
	.type strerror_l, %function
	.thumb_func
strerror_l:
	movw r12, #1323
	b ws1_resolver
	.align 2

	.global strftime_l
	.type strftime_l, %function
	.thumb_func
strftime_l:
	movw r12, #1324
	b ws1_resolver
	.align 2

	.global strncasecmp_l
	.type strncasecmp_l, %function
	.thumb_func
strncasecmp_l:
	movw r12, #1325
	b ws1_resolver
	.align 2

	.global strntoimax
	.type strntoimax, %function
	.thumb_func
strntoimax:
	movw r12, #1326
	b ws1_resolver
	.align 2

	.global strntoumax
	.type strntoumax, %function
	.thumb_func
strntoumax:
	movw r12, #1327
	b ws1_resolver
	.align 2

	.global strptime_l
	.type strptime_l, %function
	.thumb_func
strptime_l:
	movw r12, #1328
	b ws1_resolver
	.align 2

	.global strtod_l
	.type strtod_l, %function
	.thumb_func
strtod_l:
	movw r12, #1329
	b ws1_resolver
	.align 2

	.global strtof_l
	.type strtof_l, %function
	.thumb_func
strtof_l:
	movw r12, #1330
	b ws1_resolver
	.align 2

	.global strtol_l
	.type strtol_l, %function
	.thumb_func
strtol_l:
	movw r12, #1331
	b ws1_resolver
	.align 2

	.global strtold_l
	.type strtold_l, %function
	.thumb_func
strtold_l:
	movw r12, #1332
	b ws1_resolver
	.align 2

	.global strtoll_l
	.type strtoll_l, %function
	.thumb_func
strtoll_l:
	movw r12, #1333
	b ws1_resolver
	.align 2

	.global strtoq
	.type strtoq, %function
	.thumb_func
strtoq:
	movw r12, #1334
	b ws1_resolver
	.align 2

	.global strtotimeval
	.type strtotimeval, %function
	.thumb_func
strtotimeval:
	movw r12, #1335
	b ws1_resolver
	.align 2

	.global strtoul_l
	.type strtoul_l, %function
	.thumb_func
strtoul_l:
	movw r12, #1336
	b ws1_resolver
	.align 2

	.global strtoull_l
	.type strtoull_l, %function
	.thumb_func
strtoull_l:
	movw r12, #1337
	b ws1_resolver
	.align 2

	.global strtouq
	.type strtouq, %function
	.thumb_func
strtouq:
	movw r12, #1338
	b ws1_resolver
	.align 2

	.global strxfrm_l
	.type strxfrm_l, %function
	.thumb_func
strxfrm_l:
	movw r12, #1339
	b ws1_resolver
	.align 2

	.global swapoff
	.type swapoff, %function
	.thumb_func
swapoff:
	movw r12, #1340
	b ws1_resolver
	.align 2

	.global swapon
	.type swapon, %function
	.thumb_func
swapon:
	movw r12, #1341
	b ws1_resolver
	.align 2

	.global symlinkat
	.type symlinkat, %function
	.thumb_func
symlinkat:
	movw r12, #1342
	b ws1_resolver
	.align 2

	.global sync_file_range
	.type sync_file_range, %function
	.thumb_func
sync_file_range:
	movw r12, #1343
	b ws1_resolver
	.align 2

	.global syncfs
	.type syncfs, %function
	.thumb_func
syncfs:
	movw r12, #1344
	b ws1_resolver
	.align 2

	.global sys_signame
	.type sys_signame, %function
	.thumb_func
sys_signame:
	movw r12, #1345
	b ws1_resolver
	.align 2

	.global syscall
	.type syscall, %function
	.thumb_func
syscall:
	movw r12, #1346
	b ws1_resolver
	.align 2

	.global sysinfo
	.type sysinfo, %function
	.thumb_func
sysinfo:
	movw r12, #1347
	b ws1_resolver
	.align 2

	.global sysv_signal
	.type sysv_signal, %function
	.thumb_func
sysv_signal:
	movw r12, #1348
	b ws1_resolver
	.align 2

	.global tdelete
	.type tdelete, %function
	.thumb_func
tdelete:
	movw r12, #1349
	b ws1_resolver
	.align 2

	.global tdestroy
	.type tdestroy, %function
	.thumb_func
tdestroy:
	movw r12, #1350
	b ws1_resolver
	.align 2

	.global tee
	.type tee, %function
	.thumb_func
tee:
	movw r12, #1351
	b ws1_resolver
	.align 2

	.global tfind
	.type tfind, %function
	.thumb_func
tfind:
	movw r12, #1352
	b ws1_resolver
	.align 2

	.global tgkill
	.type tgkill, %function
	.thumb_func
tgkill:
	movw r12, #1353
	b ws1_resolver
	.align 2

	.global thrd_create
	.type thrd_create, %function
	.thumb_func
thrd_create:
	movw r12, #1354
	b ws1_resolver
	.align 2

	.global thrd_current
	.type thrd_current, %function
	.thumb_func
thrd_current:
	movw r12, #1355
	b ws1_resolver
	.align 2

	.global thrd_detach
	.type thrd_detach, %function
	.thumb_func
thrd_detach:
	movw r12, #1356
	b ws1_resolver
	.align 2

	.global thrd_equal
	.type thrd_equal, %function
	.thumb_func
thrd_equal:
	movw r12, #1357
	b ws1_resolver
	.align 2

	.global thrd_exit
	.type thrd_exit, %function
	.thumb_func
thrd_exit:
	movw r12, #1358
	b ws1_resolver
	.align 2

	.global thrd_join
	.type thrd_join, %function
	.thumb_func
thrd_join:
	movw r12, #1359
	b ws1_resolver
	.align 2

	.global thrd_sleep
	.type thrd_sleep, %function
	.thumb_func
thrd_sleep:
	movw r12, #1360
	b ws1_resolver
	.align 2

	.global thrd_yield
	.type thrd_yield, %function
	.thumb_func
thrd_yield:
	movw r12, #1361
	b ws1_resolver
	.align 2

	.global timegm64
	.type timegm64, %function
	.thumb_func
timegm64:
	movw r12, #1362
	b ws1_resolver
	.align 2

	.global timelocal64
	.type timelocal64, %function
	.thumb_func
timelocal64:
	movw r12, #1363
	b ws1_resolver
	.align 2

	.global timerfd_create
	.type timerfd_create, %function
	.thumb_func
timerfd_create:
	movw r12, #1364
	b ws1_resolver
	.align 2

	.global timerfd_gettime
	.type timerfd_gettime, %function
	.thumb_func
timerfd_gettime:
	movw r12, #1365
	b ws1_resolver
	.align 2

	.global timerfd_settime
	.type timerfd_settime, %function
	.thumb_func
timerfd_settime:
	movw r12, #1366
	b ws1_resolver
	.align 2

	.global timespec_get
	.type timespec_get, %function
	.thumb_func
timespec_get:
	movw r12, #1367
	b ws1_resolver
	.align 2

	.global tkill
	.type tkill, %function
	.thumb_func
tkill:
	movw r12, #1368
	b ws1_resolver
	.align 2

	.global toascii
	.type toascii, %function
	.thumb_func
toascii:
	movw r12, #1369
	b ws1_resolver
	.align 2

	.global tolower_l
	.type tolower_l, %function
	.thumb_func
tolower_l:
	movw r12, #1370
	b ws1_resolver
	.align 2

	.global toupper_l
	.type toupper_l, %function
	.thumb_func
toupper_l:
	movw r12, #1371
	b ws1_resolver
	.align 2

	.global towctrans_l
	.type towctrans_l, %function
	.thumb_func
towctrans_l:
	movw r12, #1372
	b ws1_resolver
	.align 2

	.global towlower_l
	.type towlower_l, %function
	.thumb_func
towlower_l:
	movw r12, #1373
	b ws1_resolver
	.align 2

	.global towupper_l
	.type towupper_l, %function
	.thumb_func
towupper_l:
	movw r12, #1374
	b ws1_resolver
	.align 2

	.global tsearch
	.type tsearch, %function
	.thumb_func
tsearch:
	movw r12, #1375
	b ws1_resolver
	.align 2

	.global tss_create
	.type tss_create, %function
	.thumb_func
tss_create:
	movw r12, #1376
	b ws1_resolver
	.align 2

	.global tss_delete
	.type tss_delete, %function
	.thumb_func
tss_delete:
	movw r12, #1377
	b ws1_resolver
	.align 2

	.global tss_get
	.type tss_get, %function
	.thumb_func
tss_get:
	movw r12, #1378
	b ws1_resolver
	.align 2

	.global tss_set
	.type tss_set, %function
	.thumb_func
tss_set:
	movw r12, #1379
	b ws1_resolver
	.align 2

	.global twalk
	.type twalk, %function
	.thumb_func
twalk:
	movw r12, #1380
	b ws1_resolver
	.align 2

	.global umount2
	.type umount2, %function
	.thumb_func
umount2:
	movw r12, #1381
	b ws1_resolver
	.align 2

	.global unlockpt
	.type unlockpt, %function
	.thumb_func
unlockpt:
	movw r12, #1382
	b ws1_resolver
	.align 2

	.global unshare
	.type unshare, %function
	.thumb_func
unshare:
	movw r12, #1383
	b ws1_resolver
	.align 2

	.global uselocale
	.type uselocale, %function
	.thumb_func
uselocale:
	movw r12, #1384
	b ws1_resolver
	.align 2

	.global utmpname
	.type utmpname, %function
	.thumb_func
utmpname:
	movw r12, #1385
	b ws1_resolver
	.align 2

	.global vasprintf
	.type vasprintf, %function
	.thumb_func
vasprintf:
	movw r12, #1386
	b ws1_resolver
	.align 2

	.global vdprintf
	.type vdprintf, %function
	.thumb_func
vdprintf:
	movw r12, #1387
	b ws1_resolver
	.align 2

	.global vmsplice
	.type vmsplice, %function
	.thumb_func
vmsplice:
	movw r12, #1388
	b ws1_resolver
	.align 2

	.global wcpcpy
	.type wcpcpy, %function
	.thumb_func
wcpcpy:
	movw r12, #1389
	b ws1_resolver
	.align 2

	.global wcpncpy
	.type wcpncpy, %function
	.thumb_func
wcpncpy:
	movw r12, #1390
	b ws1_resolver
	.align 2

	.global wcscasecmp
	.type wcscasecmp, %function
	.thumb_func
wcscasecmp:
	movw r12, #1391
	b ws1_resolver
	.align 2

	.global wcscasecmp_l
	.type wcscasecmp_l, %function
	.thumb_func
wcscasecmp_l:
	movw r12, #1392
	b ws1_resolver
	.align 2

	.global wcscoll_l
	.type wcscoll_l, %function
	.thumb_func
wcscoll_l:
	movw r12, #1393
	b ws1_resolver
	.align 2

	.global wcsdup
	.type wcsdup, %function
	.thumb_func
wcsdup:
	movw r12, #1394
	b ws1_resolver
	.align 2

	.global wcsftime_l
	.type wcsftime_l, %function
	.thumb_func
wcsftime_l:
	movw r12, #1395
	b ws1_resolver
	.align 2

	.global wcslcat
	.type wcslcat, %function
	.thumb_func
wcslcat:
	movw r12, #1396
	b ws1_resolver
	.align 2

	.global wcslcpy
	.type wcslcpy, %function
	.thumb_func
wcslcpy:
	movw r12, #1397
	b ws1_resolver
	.align 2

	.global wcsncasecmp
	.type wcsncasecmp, %function
	.thumb_func
wcsncasecmp:
	movw r12, #1398
	b ws1_resolver
	.align 2

	.global wcsncasecmp_l
	.type wcsncasecmp_l, %function
	.thumb_func
wcsncasecmp_l:
	movw r12, #1399
	b ws1_resolver
	.align 2

	.global wcsnlen
	.type wcsnlen, %function
	.thumb_func
wcsnlen:
	movw r12, #1400
	b ws1_resolver
	.align 2

	.global wcsnrtombs
	.type wcsnrtombs, %function
	.thumb_func
wcsnrtombs:
	movw r12, #1401
	b ws1_resolver
	.align 2

	.global wcstod_l
	.type wcstod_l, %function
	.thumb_func
wcstod_l:
	movw r12, #1402
	b ws1_resolver
	.align 2

	.global wcstof_l
	.type wcstof_l, %function
	.thumb_func
wcstof_l:
	movw r12, #1403
	b ws1_resolver
	.align 2

	.global wcstol_l
	.type wcstol_l, %function
	.thumb_func
wcstol_l:
	movw r12, #1404
	b ws1_resolver
	.align 2

	.global wcstold_l
	.type wcstold_l, %function
	.thumb_func
wcstold_l:
	movw r12, #1405
	b ws1_resolver
	.align 2

	.global wcstoll_l
	.type wcstoll_l, %function
	.thumb_func
wcstoll_l:
	movw r12, #1406
	b ws1_resolver
	.align 2

	.global wcstoul_l
	.type wcstoul_l, %function
	.thumb_func
wcstoul_l:
	movw r12, #1407
	b ws1_resolver
	.align 2

	.global wcstoull_l
	.type wcstoull_l, %function
	.thumb_func
wcstoull_l:
	movw r12, #1408
	b ws1_resolver
	.align 2

	.global wcswcs
	.type wcswcs, %function
	.thumb_func
wcswcs:
	movw r12, #1409
	b ws1_resolver
	.align 2

	.global wcswidth
	.type wcswidth, %function
	.thumb_func
wcswidth:
	movw r12, #1410
	b ws1_resolver
	.align 2

	.global wcsxfrm_l
	.type wcsxfrm_l, %function
	.thumb_func
wcsxfrm_l:
	movw r12, #1411
	b ws1_resolver
	.align 2

	.global wctrans_l
	.type wctrans_l, %function
	.thumb_func
wctrans_l:
	movw r12, #1412
	b ws1_resolver
	.align 2

	.global wctype_l
	.type wctype_l, %function
	.thumb_func
wctype_l:
	movw r12, #1413
	b ws1_resolver
	.align 2

	.global wcwidth
	.type wcwidth, %function
	.thumb_func
wcwidth:
	movw r12, #1414
	b ws1_resolver
	.align 2

	.global wmempcpy
	.type wmempcpy, %function
	.thumb_func
wmempcpy:
	movw r12, #1415
	b ws1_resolver
	.align 2

	.global SHA1Final
	.type SHA1Final, %function
	.thumb_func
SHA1Final:
	movw r12, #1416
	b ws1_resolver
	.align 2

	.global SHA1Init
	.type SHA1Init, %function
	.thumb_func
SHA1Init:
	movw r12, #1417
	b ws1_resolver
	.align 2

	.global SHA1Transform
	.type SHA1Transform, %function
	.thumb_func
SHA1Transform:
	movw r12, #1418
	b ws1_resolver
	.align 2

	.global SHA1Update
	.type SHA1Update, %function
	.thumb_func
SHA1Update:
	movw r12, #1419
	b ws1_resolver
	.align 2

	.global __assert2
	.type __assert2, %function
	.thumb_func
__assert2:
	movw r12, #1420
	b ws1_resolver
	.align 2

	.global __atomic_cmpxchg
	.type __atomic_cmpxchg, %function
	.thumb_func
__atomic_cmpxchg:
	movw r12, #1421
	b ws1_resolver
	.align 2

	.global __atomic_dec
	.type __atomic_dec, %function
	.thumb_func
__atomic_dec:
	movw r12, #1422
	b ws1_resolver
	.align 2

	.global __atomic_inc
	.type __atomic_inc, %function
	.thumb_func
__atomic_inc:
	movw r12, #1423
	b ws1_resolver
	.align 2

	.global __atomic_swap
	.type __atomic_swap, %function
	.thumb_func
__atomic_swap:
	movw r12, #1424
	b ws1_resolver
	.align 2

	.global __isthreaded
	.type __isthreaded, %function
	.thumb_func
__isthreaded:
	movw r12, #1425
	b ws1_resolver
	.align 2

	.global __system_properties_init
	.type __system_properties_init, %function
	.thumb_func
__system_properties_init:
	movw r12, #1426
	b ws1_resolver
	.align 2

	.global __system_property_area__
	.type __system_property_area__, %function
	.thumb_func
__system_property_area__:
	movw r12, #1427
	b ws1_resolver
	.align 2

	.global __system_property_find
	.type __system_property_find, %function
	.thumb_func
__system_property_find:
	movw r12, #1428
	b ws1_resolver
	.align 2

	.global __system_property_find_nth
	.type __system_property_find_nth, %function
	.thumb_func
__system_property_find_nth:
	movw r12, #1429
	b ws1_resolver
	.align 2

	.global __system_property_get
	.type __system_property_get, %function
	.thumb_func
__system_property_get:
	movw r12, #1430
	b ws1_resolver
	.align 2

	.global __system_property_read
	.type __system_property_read, %function
	.thumb_func
__system_property_read:
	movw r12, #1431
	b ws1_resolver
	.align 2

	.global __system_property_set
	.type __system_property_set, %function
	.thumb_func
__system_property_set:
	movw r12, #1432
	b ws1_resolver
	.align 2

	.global __system_property_wait
	.type __system_property_wait, %function
	.thumb_func
__system_property_wait:
	movw r12, #1433
	b ws1_resolver
	.align 2

	.global asctime
	.type asctime, %function
	.thumb_func
asctime:
	movw r12, #1434
	b ws1_resolver
	.align 2

	.global asctime_r
	.type asctime_r, %function
	.thumb_func
asctime_r:
	movw r12, #1435
	b ws1_resolver
	.align 2

	.global cacheflush
	.type cacheflush, %function
	.thumb_func
cacheflush:
	movw r12, #1436
	b ws1_resolver
	.align 2

	.global chdir
	.type chdir, %function
	.thumb_func
chdir:
	movw r12, #1437
	b ws1_resolver
	.align 2

	.global chown
	.type chown, %function
	.thumb_func
chown:
	movw r12, #1438
	b ws1_resolver
	.align 2

	.global close
	.type close, %function
	.thumb_func
close:
	movw r12, #1439
	b ws1_resolver
	.align 2

	.global creat
	.type creat, %function
	.thumb_func
creat:
	movw r12, #1440
	b ws1_resolver
	.align 2

	.global creat64
	.type creat64, %function
	.thumb_func
creat64:
	movw r12, #1441
	b ws1_resolver
	.align 2

	.global ctime
	.type ctime, %function
	.thumb_func
ctime:
	movw r12, #1442
	b ws1_resolver
	.align 2

	.global ctime_r
	.type ctime_r, %function
	.thumb_func
ctime_r:
	movw r12, #1443
	b ws1_resolver
	.align 2

	.global daylight
	.type daylight, %function
	.thumb_func
daylight:
	movw r12, #1444
	b ws1_resolver
	.align 2

	.global difftime
	.type difftime, %function
	.thumb_func
difftime:
	movw r12, #1445
	b ws1_resolver
	.align 2

	.global endpwent
	.type endpwent, %function
	.thumb_func
endpwent:
	movw r12, #1446
	b ws1_resolver
	.align 2

	.global epoll_create
	.type epoll_create, %function
	.thumb_func
epoll_create:
	movw r12, #1447
	b ws1_resolver
	.align 2

	.global epoll_ctl
	.type epoll_ctl, %function
	.thumb_func
epoll_ctl:
	movw r12, #1448
	b ws1_resolver
	.align 2

	.global epoll_wait
	.type epoll_wait, %function
	.thumb_func
epoll_wait:
	movw r12, #1449
	b ws1_resolver
	.align 2

	.global eventfd
	.type eventfd, %function
	.thumb_func
eventfd:
	movw r12, #1450
	b ws1_resolver
	.align 2

	.global eventfd_read
	.type eventfd_read, %function
	.thumb_func
eventfd_read:
	movw r12, #1451
	b ws1_resolver
	.align 2

	.global eventfd_write
	.type eventfd_write, %function
	.thumb_func
eventfd_write:
	movw r12, #1452
	b ws1_resolver
	.align 2

	.global execl
	.type execl, %function
	.thumb_func
execl:
	movw r12, #1453
	b ws1_resolver
	.align 2

	.global execle
	.type execle, %function
	.thumb_func
execle:
	movw r12, #1454
	b ws1_resolver
	.align 2

	.global execlp
	.type execlp, %function
	.thumb_func
execlp:
	movw r12, #1455
	b ws1_resolver
	.align 2

	.global execv
	.type execv, %function
	.thumb_func
execv:
	movw r12, #1456
	b ws1_resolver
	.align 2

	.global execve
	.type execve, %function
	.thumb_func
execve:
	movw r12, #1457
	b ws1_resolver
	.align 2

	.global execvp
	.type execvp, %function
	.thumb_func
execvp:
	movw r12, #1458
	b ws1_resolver
	.align 2

	.global execvpe
	.type execvpe, %function
	.thumb_func
execvpe:
	movw r12, #1459
	b ws1_resolver
	.align 2

	.global faccessat
	.type faccessat, %function
	.thumb_func
faccessat:
	movw r12, #1460
	b ws1_resolver
	.align 2

	.global fchmodat
	.type fchmodat, %function
	.thumb_func
fchmodat:
	movw r12, #1461
	b ws1_resolver
	.align 2

	.global fchown
	.type fchown, %function
	.thumb_func
fchown:
	movw r12, #1462
	b ws1_resolver
	.align 2

	.global fchownat
	.type fchownat, %function
	.thumb_func
fchownat:
	movw r12, #1463
	b ws1_resolver
	.align 2

	.global fdopendir
	.type fdopendir, %function
	.thumb_func
fdopendir:
	movw r12, #1464
	b ws1_resolver
	.align 2

	.global fdprintf
	.type fdprintf, %function
	.thumb_func
fdprintf:
	movw r12, #1465
	b ws1_resolver
	.align 2

	.global fork
	.type fork, %function
	.thumb_func
fork:
	movw r12, #1466
	b ws1_resolver
	.align 2

	.global fstat
	.type fstat, %function
	.thumb_func
fstat:
	movw r12, #1467
	b ws1_resolver
	.align 2

	.global fstat64
	.type fstat64, %function
	.thumb_func
fstat64:
	movw r12, #1468
	b ws1_resolver
	.align 2

	.global fstatat
	.type fstatat, %function
	.thumb_func
fstatat:
	movw r12, #1469
	b ws1_resolver
	.align 2

	.global fstatat64
	.type fstatat64, %function
	.thumb_func
fstatat64:
	movw r12, #1470
	b ws1_resolver
	.align 2

	.global getegid
	.type getegid, %function
	.thumb_func
getegid:
	movw r12, #1471
	b ws1_resolver
	.align 2

	.global geteuid
	.type geteuid, %function
	.thumb_func
geteuid:
	movw r12, #1472
	b ws1_resolver
	.align 2

	.global getgid
	.type getgid, %function
	.thumb_func
getgid:
	movw r12, #1473
	b ws1_resolver
	.align 2

	.global getgrgid
	.type getgrgid, %function
	.thumb_func
getgrgid:
	movw r12, #1474
	b ws1_resolver
	.align 2

	.global getgrnam
	.type getgrnam, %function
	.thumb_func
getgrnam:
	movw r12, #1475
	b ws1_resolver
	.align 2

	.global getgrouplist
	.type getgrouplist, %function
	.thumb_func
getgrouplist:
	movw r12, #1476
	b ws1_resolver
	.align 2

	.global getgroups
	.type getgroups, %function
	.thumb_func
getgroups:
	movw r12, #1477
	b ws1_resolver
	.align 2

	.global getlogin
	.type getlogin, %function
	.thumb_func
getlogin:
	movw r12, #1478
	b ws1_resolver
	.align 2

	.global getmntent
	.type getmntent, %function
	.thumb_func
getmntent:
	movw r12, #1479
	b ws1_resolver
	.align 2

	.global getnetbyaddr
	.type getnetbyaddr, %function
	.thumb_func
getnetbyaddr:
	movw r12, #1480
	b ws1_resolver
	.align 2

	.global getnetbyname
	.type getnetbyname, %function
	.thumb_func
getnetbyname:
	movw r12, #1481
	b ws1_resolver
	.align 2

	.global getpriority
	.type getpriority, %function
	.thumb_func
getpriority:
	movw r12, #1482
	b ws1_resolver
	.align 2

	.global getprotobyname
	.type getprotobyname, %function
	.thumb_func
getprotobyname:
	movw r12, #1483
	b ws1_resolver
	.align 2

	.global getprotobynumber
	.type getprotobynumber, %function
	.thumb_func
getprotobynumber:
	movw r12, #1484
	b ws1_resolver
	.align 2

	.global getpwnam
	.type getpwnam, %function
	.thumb_func
getpwnam:
	movw r12, #1485
	b ws1_resolver
	.align 2

	.global getpwnam_r
	.type getpwnam_r, %function
	.thumb_func
getpwnam_r:
	movw r12, #1486
	b ws1_resolver
	.align 2

	.global getpwuid
	.type getpwuid, %function
	.thumb_func
getpwuid:
	movw r12, #1487
	b ws1_resolver
	.align 2

	.global getpwuid_r
	.type getpwuid_r, %function
	.thumb_func
getpwuid_r:
	movw r12, #1488
	b ws1_resolver
	.align 2

	.global getresgid
	.type getresgid, %function
	.thumb_func
getresgid:
	movw r12, #1489
	b ws1_resolver
	.align 2

	.global getresuid
	.type getresuid, %function
	.thumb_func
getresuid:
	movw r12, #1490
	b ws1_resolver
	.align 2

	.global getuid
	.type getuid, %function
	.thumb_func
getuid:
	movw r12, #1491
	b ws1_resolver
	.align 2

	.global gmtime
	.type gmtime, %function
	.thumb_func
gmtime:
	movw r12, #1492
	b ws1_resolver
	.align 2

	.global gmtime_r
	.type gmtime_r, %function
	.thumb_func
gmtime_r:
	movw r12, #1493
	b ws1_resolver
	.align 2

	.global klogctl
	.type klogctl, %function
	.thumb_func
klogctl:
	movw r12, #1494
	b ws1_resolver
	.align 2

	.global lchown
	.type lchown, %function
	.thumb_func
lchown:
	movw r12, #1495
	b ws1_resolver
	.align 2

	.global localtime
	.type localtime, %function
	.thumb_func
localtime:
	movw r12, #1496
	b ws1_resolver
	.align 2

	.global localtime_r
	.type localtime_r, %function
	.thumb_func
localtime_r:
	movw r12, #1497
	b ws1_resolver
	.align 2

	.global lstat
	.type lstat, %function
	.thumb_func
lstat:
	movw r12, #1498
	b ws1_resolver
	.align 2

	.global lstat64
	.type lstat64, %function
	.thumb_func
lstat64:
	movw r12, #1499
	b ws1_resolver
	.align 2

	.global memcmp
	.type memcmp, %function
	.thumb_func
memcmp:
	movw r12, #1500
	b ws1_resolver
	.align 2

	.global memmem
	.type memmem, %function
	.thumb_func
memmem:
	movw r12, #1501
	b ws1_resolver
	.align 2

	.global mkdir
	.type mkdir, %function
	.thumb_func
mkdir:
	movw r12, #1502
	b ws1_resolver
	.align 2

	.global mkdirat
	.type mkdirat, %function
	.thumb_func
mkdirat:
	movw r12, #1503
	b ws1_resolver
	.align 2

	.global mkdtemp
	.type mkdtemp, %function
	.thumb_func
mkdtemp:
	movw r12, #1504
	b ws1_resolver
	.align 2

	.global mknod
	.type mknod, %function
	.thumb_func
mknod:
	movw r12, #1505
	b ws1_resolver
	.align 2

	.global mktime
	.type mktime, %function
	.thumb_func
mktime:
	movw r12, #1506
	b ws1_resolver
	.align 2

	.global open
	.type open, %function
	.thumb_func
open:
	movw r12, #1507
	b ws1_resolver
	.align 2

	.global open64
	.type open64, %function
	.thumb_func
open64:
	movw r12, #1508
	b ws1_resolver
	.align 2

	.global openat
	.type openat, %function
	.thumb_func
openat:
	movw r12, #1509
	b ws1_resolver
	.align 2

	.global opendir
	.type opendir, %function
	.thumb_func
opendir:
	movw r12, #1510
	b ws1_resolver
	.align 2

	.global poll
	.type poll, %function
	.thumb_func
poll:
	movw r12, #1511
	b ws1_resolver
	.align 2

	.global prctl
	.type prctl, %function
	.thumb_func
prctl:
	movw r12, #1512
	b ws1_resolver
	.align 2

	.global pthread_attr_init
	.type pthread_attr_init, %function
	.thumb_func
pthread_attr_init:
	movw r12, #1513
	b ws1_resolver
	.align 2

	.global pthread_create
	.type pthread_create, %function
	.thumb_func
pthread_create:
	movw r12, #1514
	b ws1_resolver
	.align 2

	.global renameat
	.type renameat, %function
	.thumb_func
renameat:
	movw r12, #1515
	b ws1_resolver
	.align 2

	.global rmdir
	.type rmdir, %function
	.thumb_func
rmdir:
	movw r12, #1516
	b ws1_resolver
	.align 2

	.global sendfile
	.type sendfile, %function
	.thumb_func
sendfile:
	movw r12, #1517
	b ws1_resolver
	.align 2

	.global setegid
	.type setegid, %function
	.thumb_func
setegid:
	movw r12, #1518
	b ws1_resolver
	.align 2

	.global seteuid
	.type seteuid, %function
	.thumb_func
seteuid:
	movw r12, #1519
	b ws1_resolver
	.align 2

	.global setgid
	.type setgid, %function
	.thumb_func
setgid:
	movw r12, #1520
	b ws1_resolver
	.align 2

	.global setgroups
	.type setgroups, %function
	.thumb_func
setgroups:
	movw r12, #1521
	b ws1_resolver
	.align 2

	.global setpriority
	.type setpriority, %function
	.thumb_func
setpriority:
	movw r12, #1522
	b ws1_resolver
	.align 2

	.global setregid
	.type setregid, %function
	.thumb_func
setregid:
	movw r12, #1523
	b ws1_resolver
	.align 2

	.global setresgid
	.type setresgid, %function
	.thumb_func
setresgid:
	movw r12, #1524
	b ws1_resolver
	.align 2

	.global setresuid
	.type setresuid, %function
	.thumb_func
setresuid:
	movw r12, #1525
	b ws1_resolver
	.align 2

	.global setreuid
	.type setreuid, %function
	.thumb_func
setreuid:
	movw r12, #1526
	b ws1_resolver
	.align 2

	.global setuid
	.type setuid, %function
	.thumb_func
setuid:
	movw r12, #1527
	b ws1_resolver
	.align 2

	.global stat
	.type stat, %function
	.thumb_func
stat:
	movw r12, #1528
	b ws1_resolver
	.align 2

	.global stat64
	.type stat64, %function
	.thumb_func
stat64:
	movw r12, #1529
	b ws1_resolver
	.align 2

	.global statvfs
	.type statvfs, %function
	.thumb_func
statvfs:
	movw r12, #1530
	b ws1_resolver
	.align 2

	.global strcasestr
	.type strcasestr, %function
	.thumb_func
strcasestr:
	movw r12, #1531
	b ws1_resolver
	.align 2

	.global strftime
	.type strftime, %function
	.thumb_func
strftime:
	movw r12, #1532
	b ws1_resolver
	.align 2

	.global strndup
	.type strndup, %function
	.thumb_func
strndup:
	movw r12, #1533
	b ws1_resolver
	.align 2

	.global strptime
	.type strptime, %function
	.thumb_func
strptime:
	movw r12, #1534
	b ws1_resolver
	.align 2

	.global timegm
	.type timegm, %function
	.thumb_func
timegm:
	movw r12, #1535
	b ws1_resolver
	.align 2

	.global timelocal
	.type timelocal, %function
	.thumb_func
timelocal:
	movw r12, #1536
	b ws1_resolver
	.align 2

	.global timezone
	.type timezone, %function
	.thumb_func
timezone:
	movw r12, #1537
	b ws1_resolver
	.align 2

	.global ttyname
	.type ttyname, %function
	.thumb_func
ttyname:
	movw r12, #1538
	b ws1_resolver
	.align 2

	.global ttyname_r
	.type ttyname_r, %function
	.thumb_func
ttyname_r:
	movw r12, #1539
	b ws1_resolver
	.align 2

	.global tzname
	.type tzname, %function
	.thumb_func
tzname:
	movw r12, #1540
	b ws1_resolver
	.align 2

	.global tzset
	.type tzset, %function
	.thumb_func
tzset:
	movw r12, #1541
	b ws1_resolver
	.align 2

	.global unlinkat
	.type unlinkat, %function
	.thumb_func
unlinkat:
	movw r12, #1542
	b ws1_resolver
	.align 2

	.global utimensat
	.type utimensat, %function
	.thumb_func
utimensat:
	movw r12, #1543
	b ws1_resolver
	.align 2

	.global vfdprintf
	.type vfdprintf, %function
	.thumb_func
vfdprintf:
	movw r12, #1544
	b ws1_resolver
	.align 2

	.section .data.ws1slots,"aw"
	.global ws1_slot_0000
ws1_slot_0000:
	.word 0
	.global ws1_slot_0001
ws1_slot_0001:
	.word 0
	.global ws1_slot_0002
ws1_slot_0002:
	.word 0
	.global ws1_slot_0003
ws1_slot_0003:
	.word 0
	.global ws1_slot_0004
ws1_slot_0004:
	.word 0
	.global ws1_slot_0005
ws1_slot_0005:
	.word 0
	.global ws1_slot_0006
ws1_slot_0006:
	.word 0
	.global ws1_slot_0007
ws1_slot_0007:
	.word 0
	.global ws1_slot_0008
ws1_slot_0008:
	.word 0
	.global ws1_slot_0009
ws1_slot_0009:
	.word 0
	.global ws1_slot_0010
ws1_slot_0010:
	.word 0
	.global ws1_slot_0011
ws1_slot_0011:
	.word 0
	.global ws1_slot_0012
ws1_slot_0012:
	.word 0
	.global ws1_slot_0013
ws1_slot_0013:
	.word 0
	.global ws1_slot_0014
ws1_slot_0014:
	.word 0
	.global ws1_slot_0015
ws1_slot_0015:
	.word 0
	.global ws1_slot_0016
ws1_slot_0016:
	.word 0
	.global ws1_slot_0017
ws1_slot_0017:
	.word 0
	.global ws1_slot_0018
ws1_slot_0018:
	.word 0
	.global ws1_slot_0019
ws1_slot_0019:
	.word 0
	.global ws1_slot_0020
ws1_slot_0020:
	.word 0
	.global ws1_slot_0021
ws1_slot_0021:
	.word 0
	.global ws1_slot_0022
ws1_slot_0022:
	.word 0
	.global ws1_slot_0023
ws1_slot_0023:
	.word 0
	.global ws1_slot_0024
ws1_slot_0024:
	.word 0
	.global ws1_slot_0025
ws1_slot_0025:
	.word 0
	.global ws1_slot_0026
ws1_slot_0026:
	.word 0
	.global ws1_slot_0027
ws1_slot_0027:
	.word 0
	.global ws1_slot_0028
ws1_slot_0028:
	.word 0
	.global ws1_slot_0029
ws1_slot_0029:
	.word 0
	.global ws1_slot_0030
ws1_slot_0030:
	.word 0
	.global ws1_slot_0031
ws1_slot_0031:
	.word 0
	.global ws1_slot_0032
ws1_slot_0032:
	.word 0
	.global ws1_slot_0033
ws1_slot_0033:
	.word 0
	.global ws1_slot_0034
ws1_slot_0034:
	.word 0
	.global ws1_slot_0035
ws1_slot_0035:
	.word 0
	.global ws1_slot_0036
ws1_slot_0036:
	.word 0
	.global ws1_slot_0037
ws1_slot_0037:
	.word 0
	.global ws1_slot_0038
ws1_slot_0038:
	.word 0
	.global ws1_slot_0039
ws1_slot_0039:
	.word 0
	.global ws1_slot_0040
ws1_slot_0040:
	.word 0
	.global ws1_slot_0041
ws1_slot_0041:
	.word 0
	.global ws1_slot_0042
ws1_slot_0042:
	.word 0
	.global ws1_slot_0043
ws1_slot_0043:
	.word 0
	.global ws1_slot_0044
ws1_slot_0044:
	.word 0
	.global ws1_slot_0045
ws1_slot_0045:
	.word 0
	.global ws1_slot_0046
ws1_slot_0046:
	.word 0
	.global ws1_slot_0047
ws1_slot_0047:
	.word 0
	.global ws1_slot_0048
ws1_slot_0048:
	.word 0
	.global ws1_slot_0049
ws1_slot_0049:
	.word 0
	.global ws1_slot_0050
ws1_slot_0050:
	.word 0
	.global ws1_slot_0051
ws1_slot_0051:
	.word 0
	.global ws1_slot_0052
ws1_slot_0052:
	.word 0
	.global ws1_slot_0053
ws1_slot_0053:
	.word 0
	.global ws1_slot_0054
ws1_slot_0054:
	.word 0
	.global ws1_slot_0055
ws1_slot_0055:
	.word 0
	.global ws1_slot_0056
ws1_slot_0056:
	.word 0
	.global ws1_slot_0057
ws1_slot_0057:
	.word 0
	.global ws1_slot_0058
ws1_slot_0058:
	.word 0
	.global ws1_slot_0059
ws1_slot_0059:
	.word 0
	.global ws1_slot_0060
ws1_slot_0060:
	.word 0
	.global ws1_slot_0061
ws1_slot_0061:
	.word 0
	.global ws1_slot_0062
ws1_slot_0062:
	.word 0
	.global ws1_slot_0063
ws1_slot_0063:
	.word 0
	.global ws1_slot_0064
ws1_slot_0064:
	.word 0
	.global ws1_slot_0065
ws1_slot_0065:
	.word 0
	.global ws1_slot_0066
ws1_slot_0066:
	.word 0
	.global ws1_slot_0067
ws1_slot_0067:
	.word 0
	.global ws1_slot_0068
ws1_slot_0068:
	.word 0
	.global ws1_slot_0069
ws1_slot_0069:
	.word 0
	.global ws1_slot_0070
ws1_slot_0070:
	.word 0
	.global ws1_slot_0071
ws1_slot_0071:
	.word 0
	.global ws1_slot_0072
ws1_slot_0072:
	.word 0
	.global ws1_slot_0073
ws1_slot_0073:
	.word 0
	.global ws1_slot_0074
ws1_slot_0074:
	.word 0
	.global ws1_slot_0075
ws1_slot_0075:
	.word 0
	.global ws1_slot_0076
ws1_slot_0076:
	.word 0
	.global ws1_slot_0077
ws1_slot_0077:
	.word 0
	.global ws1_slot_0078
ws1_slot_0078:
	.word 0
	.global ws1_slot_0079
ws1_slot_0079:
	.word 0
	.global ws1_slot_0080
ws1_slot_0080:
	.word 0
	.global ws1_slot_0081
ws1_slot_0081:
	.word 0
	.global ws1_slot_0082
ws1_slot_0082:
	.word 0
	.global ws1_slot_0083
ws1_slot_0083:
	.word 0
	.global ws1_slot_0084
ws1_slot_0084:
	.word 0
	.global ws1_slot_0085
ws1_slot_0085:
	.word 0
	.global ws1_slot_0086
ws1_slot_0086:
	.word 0
	.global ws1_slot_0087
ws1_slot_0087:
	.word 0
	.global ws1_slot_0088
ws1_slot_0088:
	.word 0
	.global ws1_slot_0089
ws1_slot_0089:
	.word 0
	.global ws1_slot_0090
ws1_slot_0090:
	.word 0
	.global ws1_slot_0091
ws1_slot_0091:
	.word 0
	.global ws1_slot_0092
ws1_slot_0092:
	.word 0
	.global ws1_slot_0093
ws1_slot_0093:
	.word 0
	.global ws1_slot_0094
ws1_slot_0094:
	.word 0
	.global ws1_slot_0095
ws1_slot_0095:
	.word 0
	.global ws1_slot_0096
ws1_slot_0096:
	.word 0
	.global ws1_slot_0097
ws1_slot_0097:
	.word 0
	.global ws1_slot_0098
ws1_slot_0098:
	.word 0
	.global ws1_slot_0099
ws1_slot_0099:
	.word 0
	.global ws1_slot_0100
ws1_slot_0100:
	.word 0
	.global ws1_slot_0101
ws1_slot_0101:
	.word 0
	.global ws1_slot_0102
ws1_slot_0102:
	.word 0
	.global ws1_slot_0103
ws1_slot_0103:
	.word 0
	.global ws1_slot_0104
ws1_slot_0104:
	.word 0
	.global ws1_slot_0105
ws1_slot_0105:
	.word 0
	.global ws1_slot_0106
ws1_slot_0106:
	.word 0
	.global ws1_slot_0107
ws1_slot_0107:
	.word 0
	.global ws1_slot_0108
ws1_slot_0108:
	.word 0
	.global ws1_slot_0109
ws1_slot_0109:
	.word 0
	.global ws1_slot_0110
ws1_slot_0110:
	.word 0
	.global ws1_slot_0111
ws1_slot_0111:
	.word 0
	.global ws1_slot_0112
ws1_slot_0112:
	.word 0
	.global ws1_slot_0113
ws1_slot_0113:
	.word 0
	.global ws1_slot_0114
ws1_slot_0114:
	.word 0
	.global ws1_slot_0115
ws1_slot_0115:
	.word 0
	.global ws1_slot_0116
ws1_slot_0116:
	.word 0
	.global ws1_slot_0117
ws1_slot_0117:
	.word 0
	.global ws1_slot_0118
ws1_slot_0118:
	.word 0
	.global ws1_slot_0119
ws1_slot_0119:
	.word 0
	.global ws1_slot_0120
ws1_slot_0120:
	.word 0
	.global ws1_slot_0121
ws1_slot_0121:
	.word 0
	.global ws1_slot_0122
ws1_slot_0122:
	.word 0
	.global ws1_slot_0123
ws1_slot_0123:
	.word 0
	.global ws1_slot_0124
ws1_slot_0124:
	.word 0
	.global ws1_slot_0125
ws1_slot_0125:
	.word 0
	.global ws1_slot_0126
ws1_slot_0126:
	.word 0
	.global ws1_slot_0127
ws1_slot_0127:
	.word 0
	.global ws1_slot_0128
ws1_slot_0128:
	.word 0
	.global ws1_slot_0129
ws1_slot_0129:
	.word 0
	.global ws1_slot_0130
ws1_slot_0130:
	.word 0
	.global ws1_slot_0131
ws1_slot_0131:
	.word 0
	.global ws1_slot_0132
ws1_slot_0132:
	.word 0
	.global ws1_slot_0133
ws1_slot_0133:
	.word 0
	.global ws1_slot_0134
ws1_slot_0134:
	.word 0
	.global ws1_slot_0135
ws1_slot_0135:
	.word 0
	.global ws1_slot_0136
ws1_slot_0136:
	.word 0
	.global ws1_slot_0137
ws1_slot_0137:
	.word 0
	.global ws1_slot_0138
ws1_slot_0138:
	.word 0
	.global ws1_slot_0139
ws1_slot_0139:
	.word 0
	.global ws1_slot_0140
ws1_slot_0140:
	.word 0
	.global ws1_slot_0141
ws1_slot_0141:
	.word 0
	.global ws1_slot_0142
ws1_slot_0142:
	.word 0
	.global ws1_slot_0143
ws1_slot_0143:
	.word 0
	.global ws1_slot_0144
ws1_slot_0144:
	.word 0
	.global ws1_slot_0145
ws1_slot_0145:
	.word 0
	.global ws1_slot_0146
ws1_slot_0146:
	.word 0
	.global ws1_slot_0147
ws1_slot_0147:
	.word 0
	.global ws1_slot_0148
ws1_slot_0148:
	.word 0
	.global ws1_slot_0149
ws1_slot_0149:
	.word 0
	.global ws1_slot_0150
ws1_slot_0150:
	.word 0
	.global ws1_slot_0151
ws1_slot_0151:
	.word 0
	.global ws1_slot_0152
ws1_slot_0152:
	.word 0
	.global ws1_slot_0153
ws1_slot_0153:
	.word 0
	.global ws1_slot_0154
ws1_slot_0154:
	.word 0
	.global ws1_slot_0155
ws1_slot_0155:
	.word 0
	.global ws1_slot_0156
ws1_slot_0156:
	.word 0
	.global ws1_slot_0157
ws1_slot_0157:
	.word 0
	.global ws1_slot_0158
ws1_slot_0158:
	.word 0
	.global ws1_slot_0159
ws1_slot_0159:
	.word 0
	.global ws1_slot_0160
ws1_slot_0160:
	.word 0
	.global ws1_slot_0161
ws1_slot_0161:
	.word 0
	.global ws1_slot_0162
ws1_slot_0162:
	.word 0
	.global ws1_slot_0163
ws1_slot_0163:
	.word 0
	.global ws1_slot_0164
ws1_slot_0164:
	.word 0
	.global ws1_slot_0165
ws1_slot_0165:
	.word 0
	.global ws1_slot_0166
ws1_slot_0166:
	.word 0
	.global ws1_slot_0167
ws1_slot_0167:
	.word 0
	.global ws1_slot_0168
ws1_slot_0168:
	.word 0
	.global ws1_slot_0169
ws1_slot_0169:
	.word 0
	.global ws1_slot_0170
ws1_slot_0170:
	.word 0
	.global ws1_slot_0171
ws1_slot_0171:
	.word 0
	.global ws1_slot_0172
ws1_slot_0172:
	.word 0
	.global ws1_slot_0173
ws1_slot_0173:
	.word 0
	.global ws1_slot_0174
ws1_slot_0174:
	.word 0
	.global ws1_slot_0175
ws1_slot_0175:
	.word 0
	.global ws1_slot_0176
ws1_slot_0176:
	.word 0
	.global ws1_slot_0177
ws1_slot_0177:
	.word 0
	.global ws1_slot_0178
ws1_slot_0178:
	.word 0
	.global ws1_slot_0179
ws1_slot_0179:
	.word 0
	.global ws1_slot_0180
ws1_slot_0180:
	.word 0
	.global ws1_slot_0181
ws1_slot_0181:
	.word 0
	.global ws1_slot_0182
ws1_slot_0182:
	.word 0
	.global ws1_slot_0183
ws1_slot_0183:
	.word 0
	.global ws1_slot_0184
ws1_slot_0184:
	.word 0
	.global ws1_slot_0185
ws1_slot_0185:
	.word 0
	.global ws1_slot_0186
ws1_slot_0186:
	.word 0
	.global ws1_slot_0187
ws1_slot_0187:
	.word 0
	.global ws1_slot_0188
ws1_slot_0188:
	.word 0
	.global ws1_slot_0189
ws1_slot_0189:
	.word 0
	.global ws1_slot_0190
ws1_slot_0190:
	.word 0
	.global ws1_slot_0191
ws1_slot_0191:
	.word 0
	.global ws1_slot_0192
ws1_slot_0192:
	.word 0
	.global ws1_slot_0193
ws1_slot_0193:
	.word 0
	.global ws1_slot_0194
ws1_slot_0194:
	.word 0
	.global ws1_slot_0195
ws1_slot_0195:
	.word 0
	.global ws1_slot_0196
ws1_slot_0196:
	.word 0
	.global ws1_slot_0197
ws1_slot_0197:
	.word 0
	.global ws1_slot_0198
ws1_slot_0198:
	.word 0
	.global ws1_slot_0199
ws1_slot_0199:
	.word 0
	.global ws1_slot_0200
ws1_slot_0200:
	.word 0
	.global ws1_slot_0201
ws1_slot_0201:
	.word 0
	.global ws1_slot_0202
ws1_slot_0202:
	.word 0
	.global ws1_slot_0203
ws1_slot_0203:
	.word 0
	.global ws1_slot_0204
ws1_slot_0204:
	.word 0
	.global ws1_slot_0205
ws1_slot_0205:
	.word 0
	.global ws1_slot_0206
ws1_slot_0206:
	.word 0
	.global ws1_slot_0207
ws1_slot_0207:
	.word 0
	.global ws1_slot_0208
ws1_slot_0208:
	.word 0
	.global ws1_slot_0209
ws1_slot_0209:
	.word 0
	.global ws1_slot_0210
ws1_slot_0210:
	.word 0
	.global ws1_slot_0211
ws1_slot_0211:
	.word 0
	.global ws1_slot_0212
ws1_slot_0212:
	.word 0
	.global ws1_slot_0213
ws1_slot_0213:
	.word 0
	.global ws1_slot_0214
ws1_slot_0214:
	.word 0
	.global ws1_slot_0215
ws1_slot_0215:
	.word 0
	.global ws1_slot_0216
ws1_slot_0216:
	.word 0
	.global ws1_slot_0217
ws1_slot_0217:
	.word 0
	.global ws1_slot_0218
ws1_slot_0218:
	.word 0
	.global ws1_slot_0219
ws1_slot_0219:
	.word 0
	.global ws1_slot_0220
ws1_slot_0220:
	.word 0
	.global ws1_slot_0221
ws1_slot_0221:
	.word 0
	.global ws1_slot_0222
ws1_slot_0222:
	.word 0
	.global ws1_slot_0223
ws1_slot_0223:
	.word 0
	.global ws1_slot_0224
ws1_slot_0224:
	.word 0
	.global ws1_slot_0225
ws1_slot_0225:
	.word 0
	.global ws1_slot_0226
ws1_slot_0226:
	.word 0
	.global ws1_slot_0227
ws1_slot_0227:
	.word 0
	.global ws1_slot_0228
ws1_slot_0228:
	.word 0
	.global ws1_slot_0229
ws1_slot_0229:
	.word 0
	.global ws1_slot_0230
ws1_slot_0230:
	.word 0
	.global ws1_slot_0231
ws1_slot_0231:
	.word 0
	.global ws1_slot_0232
ws1_slot_0232:
	.word 0
	.global ws1_slot_0233
ws1_slot_0233:
	.word 0
	.global ws1_slot_0234
ws1_slot_0234:
	.word 0
	.global ws1_slot_0235
ws1_slot_0235:
	.word 0
	.global ws1_slot_0236
ws1_slot_0236:
	.word 0
	.global ws1_slot_0237
ws1_slot_0237:
	.word 0
	.global ws1_slot_0238
ws1_slot_0238:
	.word 0
	.global ws1_slot_0239
ws1_slot_0239:
	.word 0
	.global ws1_slot_0240
ws1_slot_0240:
	.word 0
	.global ws1_slot_0241
ws1_slot_0241:
	.word 0
	.global ws1_slot_0242
ws1_slot_0242:
	.word 0
	.global ws1_slot_0243
ws1_slot_0243:
	.word 0
	.global ws1_slot_0244
ws1_slot_0244:
	.word 0
	.global ws1_slot_0245
ws1_slot_0245:
	.word 0
	.global ws1_slot_0246
ws1_slot_0246:
	.word 0
	.global ws1_slot_0247
ws1_slot_0247:
	.word 0
	.global ws1_slot_0248
ws1_slot_0248:
	.word 0
	.global ws1_slot_0249
ws1_slot_0249:
	.word 0
	.global ws1_slot_0250
ws1_slot_0250:
	.word 0
	.global ws1_slot_0251
ws1_slot_0251:
	.word 0
	.global ws1_slot_0252
ws1_slot_0252:
	.word 0
	.global ws1_slot_0253
ws1_slot_0253:
	.word 0
	.global ws1_slot_0254
ws1_slot_0254:
	.word 0
	.global ws1_slot_0255
ws1_slot_0255:
	.word 0
	.global ws1_slot_0256
ws1_slot_0256:
	.word 0
	.global ws1_slot_0257
ws1_slot_0257:
	.word 0
	.global ws1_slot_0258
ws1_slot_0258:
	.word 0
	.global ws1_slot_0259
ws1_slot_0259:
	.word 0
	.global ws1_slot_0260
ws1_slot_0260:
	.word 0
	.global ws1_slot_0261
ws1_slot_0261:
	.word 0
	.global ws1_slot_0262
ws1_slot_0262:
	.word 0
	.global ws1_slot_0263
ws1_slot_0263:
	.word 0
	.global ws1_slot_0264
ws1_slot_0264:
	.word 0
	.global ws1_slot_0265
ws1_slot_0265:
	.word 0
	.global ws1_slot_0266
ws1_slot_0266:
	.word 0
	.global ws1_slot_0267
ws1_slot_0267:
	.word 0
	.global ws1_slot_0268
ws1_slot_0268:
	.word 0
	.global ws1_slot_0269
ws1_slot_0269:
	.word 0
	.global ws1_slot_0270
ws1_slot_0270:
	.word 0
	.global ws1_slot_0271
ws1_slot_0271:
	.word 0
	.global ws1_slot_0272
ws1_slot_0272:
	.word 0
	.global ws1_slot_0273
ws1_slot_0273:
	.word 0
	.global ws1_slot_0274
ws1_slot_0274:
	.word 0
	.global ws1_slot_0275
ws1_slot_0275:
	.word 0
	.global ws1_slot_0276
ws1_slot_0276:
	.word 0
	.global ws1_slot_0277
ws1_slot_0277:
	.word 0
	.global ws1_slot_0278
ws1_slot_0278:
	.word 0
	.global ws1_slot_0279
ws1_slot_0279:
	.word 0
	.global ws1_slot_0280
ws1_slot_0280:
	.word 0
	.global ws1_slot_0281
ws1_slot_0281:
	.word 0
	.global ws1_slot_0282
ws1_slot_0282:
	.word 0
	.global ws1_slot_0283
ws1_slot_0283:
	.word 0
	.global ws1_slot_0284
ws1_slot_0284:
	.word 0
	.global ws1_slot_0285
ws1_slot_0285:
	.word 0
	.global ws1_slot_0286
ws1_slot_0286:
	.word 0
	.global ws1_slot_0287
ws1_slot_0287:
	.word 0
	.global ws1_slot_0288
ws1_slot_0288:
	.word 0
	.global ws1_slot_0289
ws1_slot_0289:
	.word 0
	.global ws1_slot_0290
ws1_slot_0290:
	.word 0
	.global ws1_slot_0291
ws1_slot_0291:
	.word 0
	.global ws1_slot_0292
ws1_slot_0292:
	.word 0
	.global ws1_slot_0293
ws1_slot_0293:
	.word 0
	.global ws1_slot_0294
ws1_slot_0294:
	.word 0
	.global ws1_slot_0295
ws1_slot_0295:
	.word 0
	.global ws1_slot_0296
ws1_slot_0296:
	.word 0
	.global ws1_slot_0297
ws1_slot_0297:
	.word 0
	.global ws1_slot_0298
ws1_slot_0298:
	.word 0
	.global ws1_slot_0299
ws1_slot_0299:
	.word 0
	.global ws1_slot_0300
ws1_slot_0300:
	.word 0
	.global ws1_slot_0301
ws1_slot_0301:
	.word 0
	.global ws1_slot_0302
ws1_slot_0302:
	.word 0
	.global ws1_slot_0303
ws1_slot_0303:
	.word 0
	.global ws1_slot_0304
ws1_slot_0304:
	.word 0
	.global ws1_slot_0305
ws1_slot_0305:
	.word 0
	.global ws1_slot_0306
ws1_slot_0306:
	.word 0
	.global ws1_slot_0307
ws1_slot_0307:
	.word 0
	.global ws1_slot_0308
ws1_slot_0308:
	.word 0
	.global ws1_slot_0309
ws1_slot_0309:
	.word 0
	.global ws1_slot_0310
ws1_slot_0310:
	.word 0
	.global ws1_slot_0311
ws1_slot_0311:
	.word 0
	.global ws1_slot_0312
ws1_slot_0312:
	.word 0
	.global ws1_slot_0313
ws1_slot_0313:
	.word 0
	.global ws1_slot_0314
ws1_slot_0314:
	.word 0
	.global ws1_slot_0315
ws1_slot_0315:
	.word 0
	.global ws1_slot_0316
ws1_slot_0316:
	.word 0
	.global ws1_slot_0317
ws1_slot_0317:
	.word 0
	.global ws1_slot_0318
ws1_slot_0318:
	.word 0
	.global ws1_slot_0319
ws1_slot_0319:
	.word 0
	.global ws1_slot_0320
ws1_slot_0320:
	.word 0
	.global ws1_slot_0321
ws1_slot_0321:
	.word 0
	.global ws1_slot_0322
ws1_slot_0322:
	.word 0
	.global ws1_slot_0323
ws1_slot_0323:
	.word 0
	.global ws1_slot_0324
ws1_slot_0324:
	.word 0
	.global ws1_slot_0325
ws1_slot_0325:
	.word 0
	.global ws1_slot_0326
ws1_slot_0326:
	.word 0
	.global ws1_slot_0327
ws1_slot_0327:
	.word 0
	.global ws1_slot_0328
ws1_slot_0328:
	.word 0
	.global ws1_slot_0329
ws1_slot_0329:
	.word 0
	.global ws1_slot_0330
ws1_slot_0330:
	.word 0
	.global ws1_slot_0331
ws1_slot_0331:
	.word 0
	.global ws1_slot_0332
ws1_slot_0332:
	.word 0
	.global ws1_slot_0333
ws1_slot_0333:
	.word 0
	.global ws1_slot_0334
ws1_slot_0334:
	.word 0
	.global ws1_slot_0335
ws1_slot_0335:
	.word 0
	.global ws1_slot_0336
ws1_slot_0336:
	.word 0
	.global ws1_slot_0337
ws1_slot_0337:
	.word 0
	.global ws1_slot_0338
ws1_slot_0338:
	.word 0
	.global ws1_slot_0339
ws1_slot_0339:
	.word 0
	.global ws1_slot_0340
ws1_slot_0340:
	.word 0
	.global ws1_slot_0341
ws1_slot_0341:
	.word 0
	.global ws1_slot_0342
ws1_slot_0342:
	.word 0
	.global ws1_slot_0343
ws1_slot_0343:
	.word 0
	.global ws1_slot_0344
ws1_slot_0344:
	.word 0
	.global ws1_slot_0345
ws1_slot_0345:
	.word 0
	.global ws1_slot_0346
ws1_slot_0346:
	.word 0
	.global ws1_slot_0347
ws1_slot_0347:
	.word 0
	.global ws1_slot_0348
ws1_slot_0348:
	.word 0
	.global ws1_slot_0349
ws1_slot_0349:
	.word 0
	.global ws1_slot_0350
ws1_slot_0350:
	.word 0
	.global ws1_slot_0351
ws1_slot_0351:
	.word 0
	.global ws1_slot_0352
ws1_slot_0352:
	.word 0
	.global ws1_slot_0353
ws1_slot_0353:
	.word 0
	.global ws1_slot_0354
ws1_slot_0354:
	.word 0
	.global ws1_slot_0355
ws1_slot_0355:
	.word 0
	.global ws1_slot_0356
ws1_slot_0356:
	.word 0
	.global ws1_slot_0357
ws1_slot_0357:
	.word 0
	.global ws1_slot_0358
ws1_slot_0358:
	.word 0
	.global ws1_slot_0359
ws1_slot_0359:
	.word 0
	.global ws1_slot_0360
ws1_slot_0360:
	.word 0
	.global ws1_slot_0361
ws1_slot_0361:
	.word 0
	.global ws1_slot_0362
ws1_slot_0362:
	.word 0
	.global ws1_slot_0363
ws1_slot_0363:
	.word 0
	.global ws1_slot_0364
ws1_slot_0364:
	.word 0
	.global ws1_slot_0365
ws1_slot_0365:
	.word 0
	.global ws1_slot_0366
ws1_slot_0366:
	.word 0
	.global ws1_slot_0367
ws1_slot_0367:
	.word 0
	.global ws1_slot_0368
ws1_slot_0368:
	.word 0
	.global ws1_slot_0369
ws1_slot_0369:
	.word 0
	.global ws1_slot_0370
ws1_slot_0370:
	.word 0
	.global ws1_slot_0371
ws1_slot_0371:
	.word 0
	.global ws1_slot_0372
ws1_slot_0372:
	.word 0
	.global ws1_slot_0373
ws1_slot_0373:
	.word 0
	.global ws1_slot_0374
ws1_slot_0374:
	.word 0
	.global ws1_slot_0375
ws1_slot_0375:
	.word 0
	.global ws1_slot_0376
ws1_slot_0376:
	.word 0
	.global ws1_slot_0377
ws1_slot_0377:
	.word 0
	.global ws1_slot_0378
ws1_slot_0378:
	.word 0
	.global ws1_slot_0379
ws1_slot_0379:
	.word 0
	.global ws1_slot_0380
ws1_slot_0380:
	.word 0
	.global ws1_slot_0381
ws1_slot_0381:
	.word 0
	.global ws1_slot_0382
ws1_slot_0382:
	.word 0
	.global ws1_slot_0383
ws1_slot_0383:
	.word 0
	.global ws1_slot_0384
ws1_slot_0384:
	.word 0
	.global ws1_slot_0385
ws1_slot_0385:
	.word 0
	.global ws1_slot_0386
ws1_slot_0386:
	.word 0
	.global ws1_slot_0387
ws1_slot_0387:
	.word 0
	.global ws1_slot_0388
ws1_slot_0388:
	.word 0
	.global ws1_slot_0389
ws1_slot_0389:
	.word 0
	.global ws1_slot_0390
ws1_slot_0390:
	.word 0
	.global ws1_slot_0391
ws1_slot_0391:
	.word 0
	.global ws1_slot_0392
ws1_slot_0392:
	.word 0
	.global ws1_slot_0393
ws1_slot_0393:
	.word 0
	.global ws1_slot_0394
ws1_slot_0394:
	.word 0
	.global ws1_slot_0395
ws1_slot_0395:
	.word 0
	.global ws1_slot_0396
ws1_slot_0396:
	.word 0
	.global ws1_slot_0397
ws1_slot_0397:
	.word 0
	.global ws1_slot_0398
ws1_slot_0398:
	.word 0
	.global ws1_slot_0399
ws1_slot_0399:
	.word 0
	.global ws1_slot_0400
ws1_slot_0400:
	.word 0
	.global ws1_slot_0401
ws1_slot_0401:
	.word 0
	.global ws1_slot_0402
ws1_slot_0402:
	.word 0
	.global ws1_slot_0403
ws1_slot_0403:
	.word 0
	.global ws1_slot_0404
ws1_slot_0404:
	.word 0
	.global ws1_slot_0405
ws1_slot_0405:
	.word 0
	.global ws1_slot_0406
ws1_slot_0406:
	.word 0
	.global ws1_slot_0407
ws1_slot_0407:
	.word 0
	.global ws1_slot_0408
ws1_slot_0408:
	.word 0
	.global ws1_slot_0409
ws1_slot_0409:
	.word 0
	.global ws1_slot_0410
ws1_slot_0410:
	.word 0
	.global ws1_slot_0411
ws1_slot_0411:
	.word 0
	.global ws1_slot_0412
ws1_slot_0412:
	.word 0
	.global ws1_slot_0413
ws1_slot_0413:
	.word 0
	.global ws1_slot_0414
ws1_slot_0414:
	.word 0
	.global ws1_slot_0415
ws1_slot_0415:
	.word 0
	.global ws1_slot_0416
ws1_slot_0416:
	.word 0
	.global ws1_slot_0417
ws1_slot_0417:
	.word 0
	.global ws1_slot_0418
ws1_slot_0418:
	.word 0
	.global ws1_slot_0419
ws1_slot_0419:
	.word 0
	.global ws1_slot_0420
ws1_slot_0420:
	.word 0
	.global ws1_slot_0421
ws1_slot_0421:
	.word 0
	.global ws1_slot_0422
ws1_slot_0422:
	.word 0
	.global ws1_slot_0423
ws1_slot_0423:
	.word 0
	.global ws1_slot_0424
ws1_slot_0424:
	.word 0
	.global ws1_slot_0425
ws1_slot_0425:
	.word 0
	.global ws1_slot_0426
ws1_slot_0426:
	.word 0
	.global ws1_slot_0427
ws1_slot_0427:
	.word 0
	.global ws1_slot_0428
ws1_slot_0428:
	.word 0
	.global ws1_slot_0429
ws1_slot_0429:
	.word 0
	.global ws1_slot_0430
ws1_slot_0430:
	.word 0
	.global ws1_slot_0431
ws1_slot_0431:
	.word 0
	.global ws1_slot_0432
ws1_slot_0432:
	.word 0
	.global ws1_slot_0433
ws1_slot_0433:
	.word 0
	.global ws1_slot_0434
ws1_slot_0434:
	.word 0
	.global ws1_slot_0435
ws1_slot_0435:
	.word 0
	.global ws1_slot_0436
ws1_slot_0436:
	.word 0
	.global ws1_slot_0437
ws1_slot_0437:
	.word 0
	.global ws1_slot_0438
ws1_slot_0438:
	.word 0
	.global ws1_slot_0439
ws1_slot_0439:
	.word 0
	.global ws1_slot_0440
ws1_slot_0440:
	.word 0
	.global ws1_slot_0441
ws1_slot_0441:
	.word 0
	.global ws1_slot_0442
ws1_slot_0442:
	.word 0
	.global ws1_slot_0443
ws1_slot_0443:
	.word 0
	.global ws1_slot_0444
ws1_slot_0444:
	.word 0
	.global ws1_slot_0445
ws1_slot_0445:
	.word 0
	.global ws1_slot_0446
ws1_slot_0446:
	.word 0
	.global ws1_slot_0447
ws1_slot_0447:
	.word 0
	.global ws1_slot_0448
ws1_slot_0448:
	.word 0
	.global ws1_slot_0449
ws1_slot_0449:
	.word 0
	.global ws1_slot_0450
ws1_slot_0450:
	.word 0
	.global ws1_slot_0451
ws1_slot_0451:
	.word 0
	.global ws1_slot_0452
ws1_slot_0452:
	.word 0
	.global ws1_slot_0453
ws1_slot_0453:
	.word 0
	.global ws1_slot_0454
ws1_slot_0454:
	.word 0
	.global ws1_slot_0455
ws1_slot_0455:
	.word 0
	.global ws1_slot_0456
ws1_slot_0456:
	.word 0
	.global ws1_slot_0457
ws1_slot_0457:
	.word 0
	.global ws1_slot_0458
ws1_slot_0458:
	.word 0
	.global ws1_slot_0459
ws1_slot_0459:
	.word 0
	.global ws1_slot_0460
ws1_slot_0460:
	.word 0
	.global ws1_slot_0461
ws1_slot_0461:
	.word 0
	.global ws1_slot_0462
ws1_slot_0462:
	.word 0
	.global ws1_slot_0463
ws1_slot_0463:
	.word 0
	.global ws1_slot_0464
ws1_slot_0464:
	.word 0
	.global ws1_slot_0465
ws1_slot_0465:
	.word 0
	.global ws1_slot_0466
ws1_slot_0466:
	.word 0
	.global ws1_slot_0467
ws1_slot_0467:
	.word 0
	.global ws1_slot_0468
ws1_slot_0468:
	.word 0
	.global ws1_slot_0469
ws1_slot_0469:
	.word 0
	.global ws1_slot_0470
ws1_slot_0470:
	.word 0
	.global ws1_slot_0471
ws1_slot_0471:
	.word 0
	.global ws1_slot_0472
ws1_slot_0472:
	.word 0
	.global ws1_slot_0473
ws1_slot_0473:
	.word 0
	.global ws1_slot_0474
ws1_slot_0474:
	.word 0
	.global ws1_slot_0475
ws1_slot_0475:
	.word 0
	.global ws1_slot_0476
ws1_slot_0476:
	.word 0
	.global ws1_slot_0477
ws1_slot_0477:
	.word 0
	.global ws1_slot_0478
ws1_slot_0478:
	.word 0
	.global ws1_slot_0479
ws1_slot_0479:
	.word 0
	.global ws1_slot_0480
ws1_slot_0480:
	.word 0
	.global ws1_slot_0481
ws1_slot_0481:
	.word 0
	.global ws1_slot_0482
ws1_slot_0482:
	.word 0
	.global ws1_slot_0483
ws1_slot_0483:
	.word 0
	.global ws1_slot_0484
ws1_slot_0484:
	.word 0
	.global ws1_slot_0485
ws1_slot_0485:
	.word 0
	.global ws1_slot_0486
ws1_slot_0486:
	.word 0
	.global ws1_slot_0487
ws1_slot_0487:
	.word 0
	.global ws1_slot_0488
ws1_slot_0488:
	.word 0
	.global ws1_slot_0489
ws1_slot_0489:
	.word 0
	.global ws1_slot_0490
ws1_slot_0490:
	.word 0
	.global ws1_slot_0491
ws1_slot_0491:
	.word 0
	.global ws1_slot_0492
ws1_slot_0492:
	.word 0
	.global ws1_slot_0493
ws1_slot_0493:
	.word 0
	.global ws1_slot_0494
ws1_slot_0494:
	.word 0
	.global ws1_slot_0495
ws1_slot_0495:
	.word 0
	.global ws1_slot_0496
ws1_slot_0496:
	.word 0
	.global ws1_slot_0497
ws1_slot_0497:
	.word 0
	.global ws1_slot_0498
ws1_slot_0498:
	.word 0
	.global ws1_slot_0499
ws1_slot_0499:
	.word 0
	.global ws1_slot_0500
ws1_slot_0500:
	.word 0
	.global ws1_slot_0501
ws1_slot_0501:
	.word 0
	.global ws1_slot_0502
ws1_slot_0502:
	.word 0
	.global ws1_slot_0503
ws1_slot_0503:
	.word 0
	.global ws1_slot_0504
ws1_slot_0504:
	.word 0
	.global ws1_slot_0505
ws1_slot_0505:
	.word 0
	.global ws1_slot_0506
ws1_slot_0506:
	.word 0
	.global ws1_slot_0507
ws1_slot_0507:
	.word 0
	.global ws1_slot_0508
ws1_slot_0508:
	.word 0
	.global ws1_slot_0509
ws1_slot_0509:
	.word 0
	.global ws1_slot_0510
ws1_slot_0510:
	.word 0
	.global ws1_slot_0511
ws1_slot_0511:
	.word 0
	.global ws1_slot_0512
ws1_slot_0512:
	.word 0
	.global ws1_slot_0513
ws1_slot_0513:
	.word 0
	.global ws1_slot_0514
ws1_slot_0514:
	.word 0
	.global ws1_slot_0515
ws1_slot_0515:
	.word 0
	.global ws1_slot_0516
ws1_slot_0516:
	.word 0
	.global ws1_slot_0517
ws1_slot_0517:
	.word 0
	.global ws1_slot_0518
ws1_slot_0518:
	.word 0
	.global ws1_slot_0519
ws1_slot_0519:
	.word 0
	.global ws1_slot_0520
ws1_slot_0520:
	.word 0
	.global ws1_slot_0521
ws1_slot_0521:
	.word 0
	.global ws1_slot_0522
ws1_slot_0522:
	.word 0
	.global ws1_slot_0523
ws1_slot_0523:
	.word 0
	.global ws1_slot_0524
ws1_slot_0524:
	.word 0
	.global ws1_slot_0525
ws1_slot_0525:
	.word 0
	.global ws1_slot_0526
ws1_slot_0526:
	.word 0
	.global ws1_slot_0527
ws1_slot_0527:
	.word 0
	.global ws1_slot_0528
ws1_slot_0528:
	.word 0
	.global ws1_slot_0529
ws1_slot_0529:
	.word 0
	.global ws1_slot_0530
ws1_slot_0530:
	.word 0
	.global ws1_slot_0531
ws1_slot_0531:
	.word 0
	.global ws1_slot_0532
ws1_slot_0532:
	.word 0
	.global ws1_slot_0533
ws1_slot_0533:
	.word 0
	.global ws1_slot_0534
ws1_slot_0534:
	.word 0
	.global ws1_slot_0535
ws1_slot_0535:
	.word 0
	.global ws1_slot_0536
ws1_slot_0536:
	.word 0
	.global ws1_slot_0537
ws1_slot_0537:
	.word 0
	.global ws1_slot_0538
ws1_slot_0538:
	.word 0
	.global ws1_slot_0539
ws1_slot_0539:
	.word 0
	.global ws1_slot_0540
ws1_slot_0540:
	.word 0
	.global ws1_slot_0541
ws1_slot_0541:
	.word 0
	.global ws1_slot_0542
ws1_slot_0542:
	.word 0
	.global ws1_slot_0543
ws1_slot_0543:
	.word 0
	.global ws1_slot_0544
ws1_slot_0544:
	.word 0
	.global ws1_slot_0545
ws1_slot_0545:
	.word 0
	.global ws1_slot_0546
ws1_slot_0546:
	.word 0
	.global ws1_slot_0547
ws1_slot_0547:
	.word 0
	.global ws1_slot_0548
ws1_slot_0548:
	.word 0
	.global ws1_slot_0549
ws1_slot_0549:
	.word 0
	.global ws1_slot_0550
ws1_slot_0550:
	.word 0
	.global ws1_slot_0551
ws1_slot_0551:
	.word 0
	.global ws1_slot_0552
ws1_slot_0552:
	.word 0
	.global ws1_slot_0553
ws1_slot_0553:
	.word 0
	.global ws1_slot_0554
ws1_slot_0554:
	.word 0
	.global ws1_slot_0555
ws1_slot_0555:
	.word 0
	.global ws1_slot_0556
ws1_slot_0556:
	.word 0
	.global ws1_slot_0557
ws1_slot_0557:
	.word 0
	.global ws1_slot_0558
ws1_slot_0558:
	.word 0
	.global ws1_slot_0559
ws1_slot_0559:
	.word 0
	.global ws1_slot_0560
ws1_slot_0560:
	.word 0
	.global ws1_slot_0561
ws1_slot_0561:
	.word 0
	.global ws1_slot_0562
ws1_slot_0562:
	.word 0
	.global ws1_slot_0563
ws1_slot_0563:
	.word 0
	.global ws1_slot_0564
ws1_slot_0564:
	.word 0
	.global ws1_slot_0565
ws1_slot_0565:
	.word 0
	.global ws1_slot_0566
ws1_slot_0566:
	.word 0
	.global ws1_slot_0567
ws1_slot_0567:
	.word 0
	.global ws1_slot_0568
ws1_slot_0568:
	.word 0
	.global ws1_slot_0569
ws1_slot_0569:
	.word 0
	.global ws1_slot_0570
ws1_slot_0570:
	.word 0
	.global ws1_slot_0571
ws1_slot_0571:
	.word 0
	.global ws1_slot_0572
ws1_slot_0572:
	.word 0
	.global ws1_slot_0573
ws1_slot_0573:
	.word 0
	.global ws1_slot_0574
ws1_slot_0574:
	.word 0
	.global ws1_slot_0575
ws1_slot_0575:
	.word 0
	.global ws1_slot_0576
ws1_slot_0576:
	.word 0
	.global ws1_slot_0577
ws1_slot_0577:
	.word 0
	.global ws1_slot_0578
ws1_slot_0578:
	.word 0
	.global ws1_slot_0579
ws1_slot_0579:
	.word 0
	.global ws1_slot_0580
ws1_slot_0580:
	.word 0
	.global ws1_slot_0581
ws1_slot_0581:
	.word 0
	.global ws1_slot_0582
ws1_slot_0582:
	.word 0
	.global ws1_slot_0583
ws1_slot_0583:
	.word 0
	.global ws1_slot_0584
ws1_slot_0584:
	.word 0
	.global ws1_slot_0585
ws1_slot_0585:
	.word 0
	.global ws1_slot_0586
ws1_slot_0586:
	.word 0
	.global ws1_slot_0587
ws1_slot_0587:
	.word 0
	.global ws1_slot_0588
ws1_slot_0588:
	.word 0
	.global ws1_slot_0589
ws1_slot_0589:
	.word 0
	.global ws1_slot_0590
ws1_slot_0590:
	.word 0
	.global ws1_slot_0591
ws1_slot_0591:
	.word 0
	.global ws1_slot_0592
ws1_slot_0592:
	.word 0
	.global ws1_slot_0593
ws1_slot_0593:
	.word 0
	.global ws1_slot_0594
ws1_slot_0594:
	.word 0
	.global ws1_slot_0595
ws1_slot_0595:
	.word 0
	.global ws1_slot_0596
ws1_slot_0596:
	.word 0
	.global ws1_slot_0597
ws1_slot_0597:
	.word 0
	.global ws1_slot_0598
ws1_slot_0598:
	.word 0
	.global ws1_slot_0599
ws1_slot_0599:
	.word 0
	.global ws1_slot_0600
ws1_slot_0600:
	.word 0
	.global ws1_slot_0601
ws1_slot_0601:
	.word 0
	.global ws1_slot_0602
ws1_slot_0602:
	.word 0
	.global ws1_slot_0603
ws1_slot_0603:
	.word 0
	.global ws1_slot_0604
ws1_slot_0604:
	.word 0
	.global ws1_slot_0605
ws1_slot_0605:
	.word 0
	.global ws1_slot_0606
ws1_slot_0606:
	.word 0
	.global ws1_slot_0607
ws1_slot_0607:
	.word 0
	.global ws1_slot_0608
ws1_slot_0608:
	.word 0
	.global ws1_slot_0609
ws1_slot_0609:
	.word 0
	.global ws1_slot_0610
ws1_slot_0610:
	.word 0
	.global ws1_slot_0611
ws1_slot_0611:
	.word 0
	.global ws1_slot_0612
ws1_slot_0612:
	.word 0
	.global ws1_slot_0613
ws1_slot_0613:
	.word 0
	.global ws1_slot_0614
ws1_slot_0614:
	.word 0
	.global ws1_slot_0615
ws1_slot_0615:
	.word 0
	.global ws1_slot_0616
ws1_slot_0616:
	.word 0
	.global ws1_slot_0617
ws1_slot_0617:
	.word 0
	.global ws1_slot_0618
ws1_slot_0618:
	.word 0
	.global ws1_slot_0619
ws1_slot_0619:
	.word 0
	.global ws1_slot_0620
ws1_slot_0620:
	.word 0
	.global ws1_slot_0621
ws1_slot_0621:
	.word 0
	.global ws1_slot_0622
ws1_slot_0622:
	.word 0
	.global ws1_slot_0623
ws1_slot_0623:
	.word 0
	.global ws1_slot_0624
ws1_slot_0624:
	.word 0
	.global ws1_slot_0625
ws1_slot_0625:
	.word 0
	.global ws1_slot_0626
ws1_slot_0626:
	.word 0
	.global ws1_slot_0627
ws1_slot_0627:
	.word 0
	.global ws1_slot_0628
ws1_slot_0628:
	.word 0
	.global ws1_slot_0629
ws1_slot_0629:
	.word 0
	.global ws1_slot_0630
ws1_slot_0630:
	.word 0
	.global ws1_slot_0631
ws1_slot_0631:
	.word 0
	.global ws1_slot_0632
ws1_slot_0632:
	.word 0
	.global ws1_slot_0633
ws1_slot_0633:
	.word 0
	.global ws1_slot_0634
ws1_slot_0634:
	.word 0
	.global ws1_slot_0635
ws1_slot_0635:
	.word 0
	.global ws1_slot_0636
ws1_slot_0636:
	.word 0
	.global ws1_slot_0637
ws1_slot_0637:
	.word 0
	.global ws1_slot_0638
ws1_slot_0638:
	.word 0
	.global ws1_slot_0639
ws1_slot_0639:
	.word 0
	.global ws1_slot_0640
ws1_slot_0640:
	.word 0
	.global ws1_slot_0641
ws1_slot_0641:
	.word 0
	.global ws1_slot_0642
ws1_slot_0642:
	.word 0
	.global ws1_slot_0643
ws1_slot_0643:
	.word 0
	.global ws1_slot_0644
ws1_slot_0644:
	.word 0
	.global ws1_slot_0645
ws1_slot_0645:
	.word 0
	.global ws1_slot_0646
ws1_slot_0646:
	.word 0
	.global ws1_slot_0647
ws1_slot_0647:
	.word 0
	.global ws1_slot_0648
ws1_slot_0648:
	.word 0
	.global ws1_slot_0649
ws1_slot_0649:
	.word 0
	.global ws1_slot_0650
ws1_slot_0650:
	.word 0
	.global ws1_slot_0651
ws1_slot_0651:
	.word 0
	.global ws1_slot_0652
ws1_slot_0652:
	.word 0
	.global ws1_slot_0653
ws1_slot_0653:
	.word 0
	.global ws1_slot_0654
ws1_slot_0654:
	.word 0
	.global ws1_slot_0655
ws1_slot_0655:
	.word 0
	.global ws1_slot_0656
ws1_slot_0656:
	.word 0
	.global ws1_slot_0657
ws1_slot_0657:
	.word 0
	.global ws1_slot_0658
ws1_slot_0658:
	.word 0
	.global ws1_slot_0659
ws1_slot_0659:
	.word 0
	.global ws1_slot_0660
ws1_slot_0660:
	.word 0
	.global ws1_slot_0661
ws1_slot_0661:
	.word 0
	.global ws1_slot_0662
ws1_slot_0662:
	.word 0
	.global ws1_slot_0663
ws1_slot_0663:
	.word 0
	.global ws1_slot_0664
ws1_slot_0664:
	.word 0
	.global ws1_slot_0665
ws1_slot_0665:
	.word 0
	.global ws1_slot_0666
ws1_slot_0666:
	.word 0
	.global ws1_slot_0667
ws1_slot_0667:
	.word 0
	.global ws1_slot_0668
ws1_slot_0668:
	.word 0
	.global ws1_slot_0669
ws1_slot_0669:
	.word 0
	.global ws1_slot_0670
ws1_slot_0670:
	.word 0
	.global ws1_slot_0671
ws1_slot_0671:
	.word 0
	.global ws1_slot_0672
ws1_slot_0672:
	.word 0
	.global ws1_slot_0673
ws1_slot_0673:
	.word 0
	.global ws1_slot_0674
ws1_slot_0674:
	.word 0
	.global ws1_slot_0675
ws1_slot_0675:
	.word 0
	.global ws1_slot_0676
ws1_slot_0676:
	.word 0
	.global ws1_slot_0677
ws1_slot_0677:
	.word 0
	.global ws1_slot_0678
ws1_slot_0678:
	.word 0
	.global ws1_slot_0679
ws1_slot_0679:
	.word 0
	.global ws1_slot_0680
ws1_slot_0680:
	.word 0
	.global ws1_slot_0681
ws1_slot_0681:
	.word 0
	.global ws1_slot_0682
ws1_slot_0682:
	.word 0
	.global ws1_slot_0683
ws1_slot_0683:
	.word 0
	.global ws1_slot_0684
ws1_slot_0684:
	.word 0
	.global ws1_slot_0685
ws1_slot_0685:
	.word 0
	.global ws1_slot_0686
ws1_slot_0686:
	.word 0
	.global ws1_slot_0687
ws1_slot_0687:
	.word 0
	.global ws1_slot_0688
ws1_slot_0688:
	.word 0
	.global ws1_slot_0689
ws1_slot_0689:
	.word 0
	.global ws1_slot_0690
ws1_slot_0690:
	.word 0
	.global ws1_slot_0691
ws1_slot_0691:
	.word 0
	.global ws1_slot_0692
ws1_slot_0692:
	.word 0
	.global ws1_slot_0693
ws1_slot_0693:
	.word 0
	.global ws1_slot_0694
ws1_slot_0694:
	.word 0
	.global ws1_slot_0695
ws1_slot_0695:
	.word 0
	.global ws1_slot_0696
ws1_slot_0696:
	.word 0
	.global ws1_slot_0697
ws1_slot_0697:
	.word 0
	.global ws1_slot_0698
ws1_slot_0698:
	.word 0
	.global ws1_slot_0699
ws1_slot_0699:
	.word 0
	.global ws1_slot_0700
ws1_slot_0700:
	.word 0
	.global ws1_slot_0701
ws1_slot_0701:
	.word 0
	.global ws1_slot_0702
ws1_slot_0702:
	.word 0
	.global ws1_slot_0703
ws1_slot_0703:
	.word 0
	.global ws1_slot_0704
ws1_slot_0704:
	.word 0
	.global ws1_slot_0705
ws1_slot_0705:
	.word 0
	.global ws1_slot_0706
ws1_slot_0706:
	.word 0
	.global ws1_slot_0707
ws1_slot_0707:
	.word 0
	.global ws1_slot_0708
ws1_slot_0708:
	.word 0
	.global ws1_slot_0709
ws1_slot_0709:
	.word 0
	.global ws1_slot_0710
ws1_slot_0710:
	.word 0
	.global ws1_slot_0711
ws1_slot_0711:
	.word 0
	.global ws1_slot_0712
ws1_slot_0712:
	.word 0
	.global ws1_slot_0713
ws1_slot_0713:
	.word 0
	.global ws1_slot_0714
ws1_slot_0714:
	.word 0
	.global ws1_slot_0715
ws1_slot_0715:
	.word 0
	.global ws1_slot_0716
ws1_slot_0716:
	.word 0
	.global ws1_slot_0717
ws1_slot_0717:
	.word 0
	.global ws1_slot_0718
ws1_slot_0718:
	.word 0
	.global ws1_slot_0719
ws1_slot_0719:
	.word 0
	.global ws1_slot_0720
ws1_slot_0720:
	.word 0
	.global ws1_slot_0721
ws1_slot_0721:
	.word 0
	.global ws1_slot_0722
ws1_slot_0722:
	.word 0
	.global ws1_slot_0723
ws1_slot_0723:
	.word 0
	.global ws1_slot_0724
ws1_slot_0724:
	.word 0
	.global ws1_slot_0725
ws1_slot_0725:
	.word 0
	.global ws1_slot_0726
ws1_slot_0726:
	.word 0
	.global ws1_slot_0727
ws1_slot_0727:
	.word 0
	.global ws1_slot_0728
ws1_slot_0728:
	.word 0
	.global ws1_slot_0729
ws1_slot_0729:
	.word 0
	.global ws1_slot_0730
ws1_slot_0730:
	.word 0
	.global ws1_slot_0731
ws1_slot_0731:
	.word 0
	.global ws1_slot_0732
ws1_slot_0732:
	.word 0
	.global ws1_slot_0733
ws1_slot_0733:
	.word 0
	.global ws1_slot_0734
ws1_slot_0734:
	.word 0
	.global ws1_slot_0735
ws1_slot_0735:
	.word 0
	.global ws1_slot_0736
ws1_slot_0736:
	.word 0
	.global ws1_slot_0737
ws1_slot_0737:
	.word 0
	.global ws1_slot_0738
ws1_slot_0738:
	.word 0
	.global ws1_slot_0739
ws1_slot_0739:
	.word 0
	.global ws1_slot_0740
ws1_slot_0740:
	.word 0
	.global ws1_slot_0741
ws1_slot_0741:
	.word 0
	.global ws1_slot_0742
ws1_slot_0742:
	.word 0
	.global ws1_slot_0743
ws1_slot_0743:
	.word 0
	.global ws1_slot_0744
ws1_slot_0744:
	.word 0
	.global ws1_slot_0745
ws1_slot_0745:
	.word 0
	.global ws1_slot_0746
ws1_slot_0746:
	.word 0
	.global ws1_slot_0747
ws1_slot_0747:
	.word 0
	.global ws1_slot_0748
ws1_slot_0748:
	.word 0
	.global ws1_slot_0749
ws1_slot_0749:
	.word 0
	.global ws1_slot_0750
ws1_slot_0750:
	.word 0
	.global ws1_slot_0751
ws1_slot_0751:
	.word 0
	.global ws1_slot_0752
ws1_slot_0752:
	.word 0
	.global ws1_slot_0753
ws1_slot_0753:
	.word 0
	.global ws1_slot_0754
ws1_slot_0754:
	.word 0
	.global ws1_slot_0755
ws1_slot_0755:
	.word 0
	.global ws1_slot_0756
ws1_slot_0756:
	.word 0
	.global ws1_slot_0757
ws1_slot_0757:
	.word 0
	.global ws1_slot_0758
ws1_slot_0758:
	.word 0
	.global ws1_slot_0759
ws1_slot_0759:
	.word 0
	.global ws1_slot_0760
ws1_slot_0760:
	.word 0
	.global ws1_slot_0761
ws1_slot_0761:
	.word 0
	.global ws1_slot_0762
ws1_slot_0762:
	.word 0
	.global ws1_slot_0763
ws1_slot_0763:
	.word 0
	.global ws1_slot_0764
ws1_slot_0764:
	.word 0
	.global ws1_slot_0765
ws1_slot_0765:
	.word 0
	.global ws1_slot_0766
ws1_slot_0766:
	.word 0
	.global ws1_slot_0767
ws1_slot_0767:
	.word 0
	.global ws1_slot_0768
ws1_slot_0768:
	.word 0
	.global ws1_slot_0769
ws1_slot_0769:
	.word 0
	.global ws1_slot_0770
ws1_slot_0770:
	.word 0
	.global ws1_slot_0771
ws1_slot_0771:
	.word 0
	.global ws1_slot_0772
ws1_slot_0772:
	.word 0
	.global ws1_slot_0773
ws1_slot_0773:
	.word 0
	.global ws1_slot_0774
ws1_slot_0774:
	.word 0
	.global ws1_slot_0775
ws1_slot_0775:
	.word 0
	.global ws1_slot_0776
ws1_slot_0776:
	.word 0
	.global ws1_slot_0777
ws1_slot_0777:
	.word 0
	.global ws1_slot_0778
ws1_slot_0778:
	.word 0
	.global ws1_slot_0779
ws1_slot_0779:
	.word 0
	.global ws1_slot_0780
ws1_slot_0780:
	.word 0
	.global ws1_slot_0781
ws1_slot_0781:
	.word 0
	.global ws1_slot_0782
ws1_slot_0782:
	.word 0
	.global ws1_slot_0783
ws1_slot_0783:
	.word 0
	.global ws1_slot_0784
ws1_slot_0784:
	.word 0
	.global ws1_slot_0785
ws1_slot_0785:
	.word 0
	.global ws1_slot_0786
ws1_slot_0786:
	.word 0
	.global ws1_slot_0787
ws1_slot_0787:
	.word 0
	.global ws1_slot_0788
ws1_slot_0788:
	.word 0
	.global ws1_slot_0789
ws1_slot_0789:
	.word 0
	.global ws1_slot_0790
ws1_slot_0790:
	.word 0
	.global ws1_slot_0791
ws1_slot_0791:
	.word 0
	.global ws1_slot_0792
ws1_slot_0792:
	.word 0
	.global ws1_slot_0793
ws1_slot_0793:
	.word 0
	.global ws1_slot_0794
ws1_slot_0794:
	.word 0
	.global ws1_slot_0795
ws1_slot_0795:
	.word 0
	.global ws1_slot_0796
ws1_slot_0796:
	.word 0
	.global ws1_slot_0797
ws1_slot_0797:
	.word 0
	.global ws1_slot_0798
ws1_slot_0798:
	.word 0
	.global ws1_slot_0799
ws1_slot_0799:
	.word 0
	.global ws1_slot_0800
ws1_slot_0800:
	.word 0
	.global ws1_slot_0801
ws1_slot_0801:
	.word 0
	.global ws1_slot_0802
ws1_slot_0802:
	.word 0
	.global ws1_slot_0803
ws1_slot_0803:
	.word 0
	.global ws1_slot_0804
ws1_slot_0804:
	.word 0
	.global ws1_slot_0805
ws1_slot_0805:
	.word 0
	.global ws1_slot_0806
ws1_slot_0806:
	.word 0
	.global ws1_slot_0807
ws1_slot_0807:
	.word 0
	.global ws1_slot_0808
ws1_slot_0808:
	.word 0
	.global ws1_slot_0809
ws1_slot_0809:
	.word 0
	.global ws1_slot_0810
ws1_slot_0810:
	.word 0
	.global ws1_slot_0811
ws1_slot_0811:
	.word 0
	.global ws1_slot_0812
ws1_slot_0812:
	.word 0
	.global ws1_slot_0813
ws1_slot_0813:
	.word 0
	.global ws1_slot_0814
ws1_slot_0814:
	.word 0
	.global ws1_slot_0815
ws1_slot_0815:
	.word 0
	.global ws1_slot_0816
ws1_slot_0816:
	.word 0
	.global ws1_slot_0817
ws1_slot_0817:
	.word 0
	.global ws1_slot_0818
ws1_slot_0818:
	.word 0
	.global ws1_slot_0819
ws1_slot_0819:
	.word 0
	.global ws1_slot_0820
ws1_slot_0820:
	.word 0
	.global ws1_slot_0821
ws1_slot_0821:
	.word 0
	.global ws1_slot_0822
ws1_slot_0822:
	.word 0
	.global ws1_slot_0823
ws1_slot_0823:
	.word 0
	.global ws1_slot_0824
ws1_slot_0824:
	.word 0
	.global ws1_slot_0825
ws1_slot_0825:
	.word 0
	.global ws1_slot_0826
ws1_slot_0826:
	.word 0
	.global ws1_slot_0827
ws1_slot_0827:
	.word 0
	.global ws1_slot_0828
ws1_slot_0828:
	.word 0
	.global ws1_slot_0829
ws1_slot_0829:
	.word 0
	.global ws1_slot_0830
ws1_slot_0830:
	.word 0
	.global ws1_slot_0831
ws1_slot_0831:
	.word 0
	.global ws1_slot_0832
ws1_slot_0832:
	.word 0
	.global ws1_slot_0833
ws1_slot_0833:
	.word 0
	.global ws1_slot_0834
ws1_slot_0834:
	.word 0
	.global ws1_slot_0835
ws1_slot_0835:
	.word 0
	.global ws1_slot_0836
ws1_slot_0836:
	.word 0
	.global ws1_slot_0837
ws1_slot_0837:
	.word 0
	.global ws1_slot_0838
ws1_slot_0838:
	.word 0
	.global ws1_slot_0839
ws1_slot_0839:
	.word 0
	.global ws1_slot_0840
ws1_slot_0840:
	.word 0
	.global ws1_slot_0841
ws1_slot_0841:
	.word 0
	.global ws1_slot_0842
ws1_slot_0842:
	.word 0
	.global ws1_slot_0843
ws1_slot_0843:
	.word 0
	.global ws1_slot_0844
ws1_slot_0844:
	.word 0
	.global ws1_slot_0845
ws1_slot_0845:
	.word 0
	.global ws1_slot_0846
ws1_slot_0846:
	.word 0
	.global ws1_slot_0847
ws1_slot_0847:
	.word 0
	.global ws1_slot_0848
ws1_slot_0848:
	.word 0
	.global ws1_slot_0849
ws1_slot_0849:
	.word 0
	.global ws1_slot_0850
ws1_slot_0850:
	.word 0
	.global ws1_slot_0851
ws1_slot_0851:
	.word 0
	.global ws1_slot_0852
ws1_slot_0852:
	.word 0
	.global ws1_slot_0853
ws1_slot_0853:
	.word 0
	.global ws1_slot_0854
ws1_slot_0854:
	.word 0
	.global ws1_slot_0855
ws1_slot_0855:
	.word 0
	.global ws1_slot_0856
ws1_slot_0856:
	.word 0
	.global ws1_slot_0857
ws1_slot_0857:
	.word 0
	.global ws1_slot_0858
ws1_slot_0858:
	.word 0
	.global ws1_slot_0859
ws1_slot_0859:
	.word 0
	.global ws1_slot_0860
ws1_slot_0860:
	.word 0
	.global ws1_slot_0861
ws1_slot_0861:
	.word 0
	.global ws1_slot_0862
ws1_slot_0862:
	.word 0
	.global ws1_slot_0863
ws1_slot_0863:
	.word 0
	.global ws1_slot_0864
ws1_slot_0864:
	.word 0
	.global ws1_slot_0865
ws1_slot_0865:
	.word 0
	.global ws1_slot_0866
ws1_slot_0866:
	.word 0
	.global ws1_slot_0867
ws1_slot_0867:
	.word 0
	.global ws1_slot_0868
ws1_slot_0868:
	.word 0
	.global ws1_slot_0869
ws1_slot_0869:
	.word 0
	.global ws1_slot_0870
ws1_slot_0870:
	.word 0
	.global ws1_slot_0871
ws1_slot_0871:
	.word 0
	.global ws1_slot_0872
ws1_slot_0872:
	.word 0
	.global ws1_slot_0873
ws1_slot_0873:
	.word 0
	.global ws1_slot_0874
ws1_slot_0874:
	.word 0
	.global ws1_slot_0875
ws1_slot_0875:
	.word 0
	.global ws1_slot_0876
ws1_slot_0876:
	.word 0
	.global ws1_slot_0877
ws1_slot_0877:
	.word 0
	.global ws1_slot_0878
ws1_slot_0878:
	.word 0
	.global ws1_slot_0879
ws1_slot_0879:
	.word 0
	.global ws1_slot_0880
ws1_slot_0880:
	.word 0
	.global ws1_slot_0881
ws1_slot_0881:
	.word 0
	.global ws1_slot_0882
ws1_slot_0882:
	.word 0
	.global ws1_slot_0883
ws1_slot_0883:
	.word 0
	.global ws1_slot_0884
ws1_slot_0884:
	.word 0
	.global ws1_slot_0885
ws1_slot_0885:
	.word 0
	.global ws1_slot_0886
ws1_slot_0886:
	.word 0
	.global ws1_slot_0887
ws1_slot_0887:
	.word 0
	.global ws1_slot_0888
ws1_slot_0888:
	.word 0
	.global ws1_slot_0889
ws1_slot_0889:
	.word 0
	.global ws1_slot_0890
ws1_slot_0890:
	.word 0
	.global ws1_slot_0891
ws1_slot_0891:
	.word 0
	.global ws1_slot_0892
ws1_slot_0892:
	.word 0
	.global ws1_slot_0893
ws1_slot_0893:
	.word 0
	.global ws1_slot_0894
ws1_slot_0894:
	.word 0
	.global ws1_slot_0895
ws1_slot_0895:
	.word 0
	.global ws1_slot_0896
ws1_slot_0896:
	.word 0
	.global ws1_slot_0897
ws1_slot_0897:
	.word 0
	.global ws1_slot_0898
ws1_slot_0898:
	.word 0
	.global ws1_slot_0899
ws1_slot_0899:
	.word 0
	.global ws1_slot_0900
ws1_slot_0900:
	.word 0
	.global ws1_slot_0901
ws1_slot_0901:
	.word 0
	.global ws1_slot_0902
ws1_slot_0902:
	.word 0
	.global ws1_slot_0903
ws1_slot_0903:
	.word 0
	.global ws1_slot_0904
ws1_slot_0904:
	.word 0
	.global ws1_slot_0905
ws1_slot_0905:
	.word 0
	.global ws1_slot_0906
ws1_slot_0906:
	.word 0
	.global ws1_slot_0907
ws1_slot_0907:
	.word 0
	.global ws1_slot_0908
ws1_slot_0908:
	.word 0
	.global ws1_slot_0909
ws1_slot_0909:
	.word 0
	.global ws1_slot_0910
ws1_slot_0910:
	.word 0
	.global ws1_slot_0911
ws1_slot_0911:
	.word 0
	.global ws1_slot_0912
ws1_slot_0912:
	.word 0
	.global ws1_slot_0913
ws1_slot_0913:
	.word 0
	.global ws1_slot_0914
ws1_slot_0914:
	.word 0
	.global ws1_slot_0915
ws1_slot_0915:
	.word 0
	.global ws1_slot_0916
ws1_slot_0916:
	.word 0
	.global ws1_slot_0917
ws1_slot_0917:
	.word 0
	.global ws1_slot_0918
ws1_slot_0918:
	.word 0
	.global ws1_slot_0919
ws1_slot_0919:
	.word 0
	.global ws1_slot_0920
ws1_slot_0920:
	.word 0
	.global ws1_slot_0921
ws1_slot_0921:
	.word 0
	.global ws1_slot_0922
ws1_slot_0922:
	.word 0
	.global ws1_slot_0923
ws1_slot_0923:
	.word 0
	.global ws1_slot_0924
ws1_slot_0924:
	.word 0
	.global ws1_slot_0925
ws1_slot_0925:
	.word 0
	.global ws1_slot_0926
ws1_slot_0926:
	.word 0
	.global ws1_slot_0927
ws1_slot_0927:
	.word 0
	.global ws1_slot_0928
ws1_slot_0928:
	.word 0
	.global ws1_slot_0929
ws1_slot_0929:
	.word 0
	.global ws1_slot_0930
ws1_slot_0930:
	.word 0
	.global ws1_slot_0931
ws1_slot_0931:
	.word 0
	.global ws1_slot_0932
ws1_slot_0932:
	.word 0
	.global ws1_slot_0933
ws1_slot_0933:
	.word 0
	.global ws1_slot_0934
ws1_slot_0934:
	.word 0
	.global ws1_slot_0935
ws1_slot_0935:
	.word 0
	.global ws1_slot_0936
ws1_slot_0936:
	.word 0
	.global ws1_slot_0937
ws1_slot_0937:
	.word 0
	.global ws1_slot_0938
ws1_slot_0938:
	.word 0
	.global ws1_slot_0939
ws1_slot_0939:
	.word 0
	.global ws1_slot_0940
ws1_slot_0940:
	.word 0
	.global ws1_slot_0941
ws1_slot_0941:
	.word 0
	.global ws1_slot_0942
ws1_slot_0942:
	.word 0
	.global ws1_slot_0943
ws1_slot_0943:
	.word 0
	.global ws1_slot_0944
ws1_slot_0944:
	.word 0
	.global ws1_slot_0945
ws1_slot_0945:
	.word 0
	.global ws1_slot_0946
ws1_slot_0946:
	.word 0
	.global ws1_slot_0947
ws1_slot_0947:
	.word 0
	.global ws1_slot_0948
ws1_slot_0948:
	.word 0
	.global ws1_slot_0949
ws1_slot_0949:
	.word 0
	.global ws1_slot_0950
ws1_slot_0950:
	.word 0
	.global ws1_slot_0951
ws1_slot_0951:
	.word 0
	.global ws1_slot_0952
ws1_slot_0952:
	.word 0
	.global ws1_slot_0953
ws1_slot_0953:
	.word 0
	.global ws1_slot_0954
ws1_slot_0954:
	.word 0
	.global ws1_slot_0955
ws1_slot_0955:
	.word 0
	.global ws1_slot_0956
ws1_slot_0956:
	.word 0
	.global ws1_slot_0957
ws1_slot_0957:
	.word 0
	.global ws1_slot_0958
ws1_slot_0958:
	.word 0
	.global ws1_slot_0959
ws1_slot_0959:
	.word 0
	.global ws1_slot_0960
ws1_slot_0960:
	.word 0
	.global ws1_slot_0961
ws1_slot_0961:
	.word 0
	.global ws1_slot_0962
ws1_slot_0962:
	.word 0
	.global ws1_slot_0963
ws1_slot_0963:
	.word 0
	.global ws1_slot_0964
ws1_slot_0964:
	.word 0
	.global ws1_slot_0965
ws1_slot_0965:
	.word 0
	.global ws1_slot_0966
ws1_slot_0966:
	.word 0
	.global ws1_slot_0967
ws1_slot_0967:
	.word 0
	.global ws1_slot_0968
ws1_slot_0968:
	.word 0
	.global ws1_slot_0969
ws1_slot_0969:
	.word 0
	.global ws1_slot_0970
ws1_slot_0970:
	.word 0
	.global ws1_slot_0971
ws1_slot_0971:
	.word 0
	.global ws1_slot_0972
ws1_slot_0972:
	.word 0
	.global ws1_slot_0973
ws1_slot_0973:
	.word 0
	.global ws1_slot_0974
ws1_slot_0974:
	.word 0
	.global ws1_slot_0975
ws1_slot_0975:
	.word 0
	.global ws1_slot_0976
ws1_slot_0976:
	.word 0
	.global ws1_slot_0977
ws1_slot_0977:
	.word 0
	.global ws1_slot_0978
ws1_slot_0978:
	.word 0
	.global ws1_slot_0979
ws1_slot_0979:
	.word 0
	.global ws1_slot_0980
ws1_slot_0980:
	.word 0
	.global ws1_slot_0981
ws1_slot_0981:
	.word 0
	.global ws1_slot_0982
ws1_slot_0982:
	.word 0
	.global ws1_slot_0983
ws1_slot_0983:
	.word 0
	.global ws1_slot_0984
ws1_slot_0984:
	.word 0
	.global ws1_slot_0985
ws1_slot_0985:
	.word 0
	.global ws1_slot_0986
ws1_slot_0986:
	.word 0
	.global ws1_slot_0987
ws1_slot_0987:
	.word 0
	.global ws1_slot_0988
ws1_slot_0988:
	.word 0
	.global ws1_slot_0989
ws1_slot_0989:
	.word 0
	.global ws1_slot_0990
ws1_slot_0990:
	.word 0
	.global ws1_slot_0991
ws1_slot_0991:
	.word 0
	.global ws1_slot_0992
ws1_slot_0992:
	.word 0
	.global ws1_slot_0993
ws1_slot_0993:
	.word 0
	.global ws1_slot_0994
ws1_slot_0994:
	.word 0
	.global ws1_slot_0995
ws1_slot_0995:
	.word 0
	.global ws1_slot_0996
ws1_slot_0996:
	.word 0
	.global ws1_slot_0997
ws1_slot_0997:
	.word 0
	.global ws1_slot_0998
ws1_slot_0998:
	.word 0
	.global ws1_slot_0999
ws1_slot_0999:
	.word 0
	.global ws1_slot_1000
ws1_slot_1000:
	.word 0
	.global ws1_slot_1001
ws1_slot_1001:
	.word 0
	.global ws1_slot_1002
ws1_slot_1002:
	.word 0
	.global ws1_slot_1003
ws1_slot_1003:
	.word 0
	.global ws1_slot_1004
ws1_slot_1004:
	.word 0
	.global ws1_slot_1005
ws1_slot_1005:
	.word 0
	.global ws1_slot_1006
ws1_slot_1006:
	.word 0
	.global ws1_slot_1007
ws1_slot_1007:
	.word 0
	.global ws1_slot_1008
ws1_slot_1008:
	.word 0
	.global ws1_slot_1009
ws1_slot_1009:
	.word 0
	.global ws1_slot_1010
ws1_slot_1010:
	.word 0
	.global ws1_slot_1011
ws1_slot_1011:
	.word 0
	.global ws1_slot_1012
ws1_slot_1012:
	.word 0
	.global ws1_slot_1013
ws1_slot_1013:
	.word 0
	.global ws1_slot_1014
ws1_slot_1014:
	.word 0
	.global ws1_slot_1015
ws1_slot_1015:
	.word 0
	.global ws1_slot_1016
ws1_slot_1016:
	.word 0
	.global ws1_slot_1017
ws1_slot_1017:
	.word 0
	.global ws1_slot_1018
ws1_slot_1018:
	.word 0
	.global ws1_slot_1019
ws1_slot_1019:
	.word 0
	.global ws1_slot_1020
ws1_slot_1020:
	.word 0
	.global ws1_slot_1021
ws1_slot_1021:
	.word 0
	.global ws1_slot_1022
ws1_slot_1022:
	.word 0
	.global ws1_slot_1023
ws1_slot_1023:
	.word 0
	.global ws1_slot_1024
ws1_slot_1024:
	.word 0
	.global ws1_slot_1025
ws1_slot_1025:
	.word 0
	.global ws1_slot_1026
ws1_slot_1026:
	.word 0
	.global ws1_slot_1027
ws1_slot_1027:
	.word 0
	.global ws1_slot_1028
ws1_slot_1028:
	.word 0
	.global ws1_slot_1029
ws1_slot_1029:
	.word 0
	.global ws1_slot_1030
ws1_slot_1030:
	.word 0
	.global ws1_slot_1031
ws1_slot_1031:
	.word 0
	.global ws1_slot_1032
ws1_slot_1032:
	.word 0
	.global ws1_slot_1033
ws1_slot_1033:
	.word 0
	.global ws1_slot_1034
ws1_slot_1034:
	.word 0
	.global ws1_slot_1035
ws1_slot_1035:
	.word 0
	.global ws1_slot_1036
ws1_slot_1036:
	.word 0
	.global ws1_slot_1037
ws1_slot_1037:
	.word 0
	.global ws1_slot_1038
ws1_slot_1038:
	.word 0
	.global ws1_slot_1039
ws1_slot_1039:
	.word 0
	.global ws1_slot_1040
ws1_slot_1040:
	.word 0
	.global ws1_slot_1041
ws1_slot_1041:
	.word 0
	.global ws1_slot_1042
ws1_slot_1042:
	.word 0
	.global ws1_slot_1043
ws1_slot_1043:
	.word 0
	.global ws1_slot_1044
ws1_slot_1044:
	.word 0
	.global ws1_slot_1045
ws1_slot_1045:
	.word 0
	.global ws1_slot_1046
ws1_slot_1046:
	.word 0
	.global ws1_slot_1047
ws1_slot_1047:
	.word 0
	.global ws1_slot_1048
ws1_slot_1048:
	.word 0
	.global ws1_slot_1049
ws1_slot_1049:
	.word 0
	.global ws1_slot_1050
ws1_slot_1050:
	.word 0
	.global ws1_slot_1051
ws1_slot_1051:
	.word 0
	.global ws1_slot_1052
ws1_slot_1052:
	.word 0
	.global ws1_slot_1053
ws1_slot_1053:
	.word 0
	.global ws1_slot_1054
ws1_slot_1054:
	.word 0
	.global ws1_slot_1055
ws1_slot_1055:
	.word 0
	.global ws1_slot_1056
ws1_slot_1056:
	.word 0
	.global ws1_slot_1057
ws1_slot_1057:
	.word 0
	.global ws1_slot_1058
ws1_slot_1058:
	.word 0
	.global ws1_slot_1059
ws1_slot_1059:
	.word 0
	.global ws1_slot_1060
ws1_slot_1060:
	.word 0
	.global ws1_slot_1061
ws1_slot_1061:
	.word 0
	.global ws1_slot_1062
ws1_slot_1062:
	.word 0
	.global ws1_slot_1063
ws1_slot_1063:
	.word 0
	.global ws1_slot_1064
ws1_slot_1064:
	.word 0
	.global ws1_slot_1065
ws1_slot_1065:
	.word 0
	.global ws1_slot_1066
ws1_slot_1066:
	.word 0
	.global ws1_slot_1067
ws1_slot_1067:
	.word 0
	.global ws1_slot_1068
ws1_slot_1068:
	.word 0
	.global ws1_slot_1069
ws1_slot_1069:
	.word 0
	.global ws1_slot_1070
ws1_slot_1070:
	.word 0
	.global ws1_slot_1071
ws1_slot_1071:
	.word 0
	.global ws1_slot_1072
ws1_slot_1072:
	.word 0
	.global ws1_slot_1073
ws1_slot_1073:
	.word 0
	.global ws1_slot_1074
ws1_slot_1074:
	.word 0
	.global ws1_slot_1075
ws1_slot_1075:
	.word 0
	.global ws1_slot_1076
ws1_slot_1076:
	.word 0
	.global ws1_slot_1077
ws1_slot_1077:
	.word 0
	.global ws1_slot_1078
ws1_slot_1078:
	.word 0
	.global ws1_slot_1079
ws1_slot_1079:
	.word 0
	.global ws1_slot_1080
ws1_slot_1080:
	.word 0
	.global ws1_slot_1081
ws1_slot_1081:
	.word 0
	.global ws1_slot_1082
ws1_slot_1082:
	.word 0
	.global ws1_slot_1083
ws1_slot_1083:
	.word 0
	.global ws1_slot_1084
ws1_slot_1084:
	.word 0
	.global ws1_slot_1085
ws1_slot_1085:
	.word 0
	.global ws1_slot_1086
ws1_slot_1086:
	.word 0
	.global ws1_slot_1087
ws1_slot_1087:
	.word 0
	.global ws1_slot_1088
ws1_slot_1088:
	.word 0
	.global ws1_slot_1089
ws1_slot_1089:
	.word 0
	.global ws1_slot_1090
ws1_slot_1090:
	.word 0
	.global ws1_slot_1091
ws1_slot_1091:
	.word 0
	.global ws1_slot_1092
ws1_slot_1092:
	.word 0
	.global ws1_slot_1093
ws1_slot_1093:
	.word 0
	.global ws1_slot_1094
ws1_slot_1094:
	.word 0
	.global ws1_slot_1095
ws1_slot_1095:
	.word 0
	.global ws1_slot_1096
ws1_slot_1096:
	.word 0
	.global ws1_slot_1097
ws1_slot_1097:
	.word 0
	.global ws1_slot_1098
ws1_slot_1098:
	.word 0
	.global ws1_slot_1099
ws1_slot_1099:
	.word 0
	.global ws1_slot_1100
ws1_slot_1100:
	.word 0
	.global ws1_slot_1101
ws1_slot_1101:
	.word 0
	.global ws1_slot_1102
ws1_slot_1102:
	.word 0
	.global ws1_slot_1103
ws1_slot_1103:
	.word 0
	.global ws1_slot_1104
ws1_slot_1104:
	.word 0
	.global ws1_slot_1105
ws1_slot_1105:
	.word 0
	.global ws1_slot_1106
ws1_slot_1106:
	.word 0
	.global ws1_slot_1107
ws1_slot_1107:
	.word 0
	.global ws1_slot_1108
ws1_slot_1108:
	.word 0
	.global ws1_slot_1109
ws1_slot_1109:
	.word 0
	.global ws1_slot_1110
ws1_slot_1110:
	.word 0
	.global ws1_slot_1111
ws1_slot_1111:
	.word 0
	.global ws1_slot_1112
ws1_slot_1112:
	.word 0
	.global ws1_slot_1113
ws1_slot_1113:
	.word 0
	.global ws1_slot_1114
ws1_slot_1114:
	.word 0
	.global ws1_slot_1115
ws1_slot_1115:
	.word 0
	.global ws1_slot_1116
ws1_slot_1116:
	.word 0
	.global ws1_slot_1117
ws1_slot_1117:
	.word 0
	.global ws1_slot_1118
ws1_slot_1118:
	.word 0
	.global ws1_slot_1119
ws1_slot_1119:
	.word 0
	.global ws1_slot_1120
ws1_slot_1120:
	.word 0
	.global ws1_slot_1121
ws1_slot_1121:
	.word 0
	.global ws1_slot_1122
ws1_slot_1122:
	.word 0
	.global ws1_slot_1123
ws1_slot_1123:
	.word 0
	.global ws1_slot_1124
ws1_slot_1124:
	.word 0
	.global ws1_slot_1125
ws1_slot_1125:
	.word 0
	.global ws1_slot_1126
ws1_slot_1126:
	.word 0
	.global ws1_slot_1127
ws1_slot_1127:
	.word 0
	.global ws1_slot_1128
ws1_slot_1128:
	.word 0
	.global ws1_slot_1129
ws1_slot_1129:
	.word 0
	.global ws1_slot_1130
ws1_slot_1130:
	.word 0
	.global ws1_slot_1131
ws1_slot_1131:
	.word 0
	.global ws1_slot_1132
ws1_slot_1132:
	.word 0
	.global ws1_slot_1133
ws1_slot_1133:
	.word 0
	.global ws1_slot_1134
ws1_slot_1134:
	.word 0
	.global ws1_slot_1135
ws1_slot_1135:
	.word 0
	.global ws1_slot_1136
ws1_slot_1136:
	.word 0
	.global ws1_slot_1137
ws1_slot_1137:
	.word 0
	.global ws1_slot_1138
ws1_slot_1138:
	.word 0
	.global ws1_slot_1139
ws1_slot_1139:
	.word 0
	.global ws1_slot_1140
ws1_slot_1140:
	.word 0
	.global ws1_slot_1141
ws1_slot_1141:
	.word 0
	.global ws1_slot_1142
ws1_slot_1142:
	.word 0
	.global ws1_slot_1143
ws1_slot_1143:
	.word 0
	.global ws1_slot_1144
ws1_slot_1144:
	.word 0
	.global ws1_slot_1145
ws1_slot_1145:
	.word 0
	.global ws1_slot_1146
ws1_slot_1146:
	.word 0
	.global ws1_slot_1147
ws1_slot_1147:
	.word 0
	.global ws1_slot_1148
ws1_slot_1148:
	.word 0
	.global ws1_slot_1149
ws1_slot_1149:
	.word 0
	.global ws1_slot_1150
ws1_slot_1150:
	.word 0
	.global ws1_slot_1151
ws1_slot_1151:
	.word 0
	.global ws1_slot_1152
ws1_slot_1152:
	.word 0
	.global ws1_slot_1153
ws1_slot_1153:
	.word 0
	.global ws1_slot_1154
ws1_slot_1154:
	.word 0
	.global ws1_slot_1155
ws1_slot_1155:
	.word 0
	.global ws1_slot_1156
ws1_slot_1156:
	.word 0
	.global ws1_slot_1157
ws1_slot_1157:
	.word 0
	.global ws1_slot_1158
ws1_slot_1158:
	.word 0
	.global ws1_slot_1159
ws1_slot_1159:
	.word 0
	.global ws1_slot_1160
ws1_slot_1160:
	.word 0
	.global ws1_slot_1161
ws1_slot_1161:
	.word 0
	.global ws1_slot_1162
ws1_slot_1162:
	.word 0
	.global ws1_slot_1163
ws1_slot_1163:
	.word 0
	.global ws1_slot_1164
ws1_slot_1164:
	.word 0
	.global ws1_slot_1165
ws1_slot_1165:
	.word 0
	.global ws1_slot_1166
ws1_slot_1166:
	.word 0
	.global ws1_slot_1167
ws1_slot_1167:
	.word 0
	.global ws1_slot_1168
ws1_slot_1168:
	.word 0
	.global ws1_slot_1169
ws1_slot_1169:
	.word 0
	.global ws1_slot_1170
ws1_slot_1170:
	.word 0
	.global ws1_slot_1171
ws1_slot_1171:
	.word 0
	.global ws1_slot_1172
ws1_slot_1172:
	.word 0
	.global ws1_slot_1173
ws1_slot_1173:
	.word 0
	.global ws1_slot_1174
ws1_slot_1174:
	.word 0
	.global ws1_slot_1175
ws1_slot_1175:
	.word 0
	.global ws1_slot_1176
ws1_slot_1176:
	.word 0
	.global ws1_slot_1177
ws1_slot_1177:
	.word 0
	.global ws1_slot_1178
ws1_slot_1178:
	.word 0
	.global ws1_slot_1179
ws1_slot_1179:
	.word 0
	.global ws1_slot_1180
ws1_slot_1180:
	.word 0
	.global ws1_slot_1181
ws1_slot_1181:
	.word 0
	.global ws1_slot_1182
ws1_slot_1182:
	.word 0
	.global ws1_slot_1183
ws1_slot_1183:
	.word 0
	.global ws1_slot_1184
ws1_slot_1184:
	.word 0
	.global ws1_slot_1185
ws1_slot_1185:
	.word 0
	.global ws1_slot_1186
ws1_slot_1186:
	.word 0
	.global ws1_slot_1187
ws1_slot_1187:
	.word 0
	.global ws1_slot_1188
ws1_slot_1188:
	.word 0
	.global ws1_slot_1189
ws1_slot_1189:
	.word 0
	.global ws1_slot_1190
ws1_slot_1190:
	.word 0
	.global ws1_slot_1191
ws1_slot_1191:
	.word 0
	.global ws1_slot_1192
ws1_slot_1192:
	.word 0
	.global ws1_slot_1193
ws1_slot_1193:
	.word 0
	.global ws1_slot_1194
ws1_slot_1194:
	.word 0
	.global ws1_slot_1195
ws1_slot_1195:
	.word 0
	.global ws1_slot_1196
ws1_slot_1196:
	.word 0
	.global ws1_slot_1197
ws1_slot_1197:
	.word 0
	.global ws1_slot_1198
ws1_slot_1198:
	.word 0
	.global ws1_slot_1199
ws1_slot_1199:
	.word 0
	.global ws1_slot_1200
ws1_slot_1200:
	.word 0
	.global ws1_slot_1201
ws1_slot_1201:
	.word 0
	.global ws1_slot_1202
ws1_slot_1202:
	.word 0
	.global ws1_slot_1203
ws1_slot_1203:
	.word 0
	.global ws1_slot_1204
ws1_slot_1204:
	.word 0
	.global ws1_slot_1205
ws1_slot_1205:
	.word 0
	.global ws1_slot_1206
ws1_slot_1206:
	.word 0
	.global ws1_slot_1207
ws1_slot_1207:
	.word 0
	.global ws1_slot_1208
ws1_slot_1208:
	.word 0
	.global ws1_slot_1209
ws1_slot_1209:
	.word 0
	.global ws1_slot_1210
ws1_slot_1210:
	.word 0
	.global ws1_slot_1211
ws1_slot_1211:
	.word 0
	.global ws1_slot_1212
ws1_slot_1212:
	.word 0
	.global ws1_slot_1213
ws1_slot_1213:
	.word 0
	.global ws1_slot_1214
ws1_slot_1214:
	.word 0
	.global ws1_slot_1215
ws1_slot_1215:
	.word 0
	.global ws1_slot_1216
ws1_slot_1216:
	.word 0
	.global ws1_slot_1217
ws1_slot_1217:
	.word 0
	.global ws1_slot_1218
ws1_slot_1218:
	.word 0
	.global ws1_slot_1219
ws1_slot_1219:
	.word 0
	.global ws1_slot_1220
ws1_slot_1220:
	.word 0
	.global ws1_slot_1221
ws1_slot_1221:
	.word 0
	.global ws1_slot_1222
ws1_slot_1222:
	.word 0
	.global ws1_slot_1223
ws1_slot_1223:
	.word 0
	.global ws1_slot_1224
ws1_slot_1224:
	.word 0
	.global ws1_slot_1225
ws1_slot_1225:
	.word 0
	.global ws1_slot_1226
ws1_slot_1226:
	.word 0
	.global ws1_slot_1227
ws1_slot_1227:
	.word 0
	.global ws1_slot_1228
ws1_slot_1228:
	.word 0
	.global ws1_slot_1229
ws1_slot_1229:
	.word 0
	.global ws1_slot_1230
ws1_slot_1230:
	.word 0
	.global ws1_slot_1231
ws1_slot_1231:
	.word 0
	.global ws1_slot_1232
ws1_slot_1232:
	.word 0
	.global ws1_slot_1233
ws1_slot_1233:
	.word 0
	.global ws1_slot_1234
ws1_slot_1234:
	.word 0
	.global ws1_slot_1235
ws1_slot_1235:
	.word 0
	.global ws1_slot_1236
ws1_slot_1236:
	.word 0
	.global ws1_slot_1237
ws1_slot_1237:
	.word 0
	.global ws1_slot_1238
ws1_slot_1238:
	.word 0
	.global ws1_slot_1239
ws1_slot_1239:
	.word 0
	.global ws1_slot_1240
ws1_slot_1240:
	.word 0
	.global ws1_slot_1241
ws1_slot_1241:
	.word 0
	.global ws1_slot_1242
ws1_slot_1242:
	.word 0
	.global ws1_slot_1243
ws1_slot_1243:
	.word 0
	.global ws1_slot_1244
ws1_slot_1244:
	.word 0
	.global ws1_slot_1245
ws1_slot_1245:
	.word 0
	.global ws1_slot_1246
ws1_slot_1246:
	.word 0
	.global ws1_slot_1247
ws1_slot_1247:
	.word 0
	.global ws1_slot_1248
ws1_slot_1248:
	.word 0
	.global ws1_slot_1249
ws1_slot_1249:
	.word 0
	.global ws1_slot_1250
ws1_slot_1250:
	.word 0
	.global ws1_slot_1251
ws1_slot_1251:
	.word 0
	.global ws1_slot_1252
ws1_slot_1252:
	.word 0
	.global ws1_slot_1253
ws1_slot_1253:
	.word 0
	.global ws1_slot_1254
ws1_slot_1254:
	.word 0
	.global ws1_slot_1255
ws1_slot_1255:
	.word 0
	.global ws1_slot_1256
ws1_slot_1256:
	.word 0
	.global ws1_slot_1257
ws1_slot_1257:
	.word 0
	.global ws1_slot_1258
ws1_slot_1258:
	.word 0
	.global ws1_slot_1259
ws1_slot_1259:
	.word 0
	.global ws1_slot_1260
ws1_slot_1260:
	.word 0
	.global ws1_slot_1261
ws1_slot_1261:
	.word 0
	.global ws1_slot_1262
ws1_slot_1262:
	.word 0
	.global ws1_slot_1263
ws1_slot_1263:
	.word 0
	.global ws1_slot_1264
ws1_slot_1264:
	.word 0
	.global ws1_slot_1265
ws1_slot_1265:
	.word 0
	.global ws1_slot_1266
ws1_slot_1266:
	.word 0
	.global ws1_slot_1267
ws1_slot_1267:
	.word 0
	.global ws1_slot_1268
ws1_slot_1268:
	.word 0
	.global ws1_slot_1269
ws1_slot_1269:
	.word 0
	.global ws1_slot_1270
ws1_slot_1270:
	.word 0
	.global ws1_slot_1271
ws1_slot_1271:
	.word 0
	.global ws1_slot_1272
ws1_slot_1272:
	.word 0
	.global ws1_slot_1273
ws1_slot_1273:
	.word 0
	.global ws1_slot_1274
ws1_slot_1274:
	.word 0
	.global ws1_slot_1275
ws1_slot_1275:
	.word 0
	.global ws1_slot_1276
ws1_slot_1276:
	.word 0
	.global ws1_slot_1277
ws1_slot_1277:
	.word 0
	.global ws1_slot_1278
ws1_slot_1278:
	.word 0
	.global ws1_slot_1279
ws1_slot_1279:
	.word 0
	.global ws1_slot_1280
ws1_slot_1280:
	.word 0
	.global ws1_slot_1281
ws1_slot_1281:
	.word 0
	.global ws1_slot_1282
ws1_slot_1282:
	.word 0
	.global ws1_slot_1283
ws1_slot_1283:
	.word 0
	.global ws1_slot_1284
ws1_slot_1284:
	.word 0
	.global ws1_slot_1285
ws1_slot_1285:
	.word 0
	.global ws1_slot_1286
ws1_slot_1286:
	.word 0
	.global ws1_slot_1287
ws1_slot_1287:
	.word 0
	.global ws1_slot_1288
ws1_slot_1288:
	.word 0
	.global ws1_slot_1289
ws1_slot_1289:
	.word 0
	.global ws1_slot_1290
ws1_slot_1290:
	.word 0
	.global ws1_slot_1291
ws1_slot_1291:
	.word 0
	.global ws1_slot_1292
ws1_slot_1292:
	.word 0
	.global ws1_slot_1293
ws1_slot_1293:
	.word 0
	.global ws1_slot_1294
ws1_slot_1294:
	.word 0
	.global ws1_slot_1295
ws1_slot_1295:
	.word 0
	.global ws1_slot_1296
ws1_slot_1296:
	.word 0
	.global ws1_slot_1297
ws1_slot_1297:
	.word 0
	.global ws1_slot_1298
ws1_slot_1298:
	.word 0
	.global ws1_slot_1299
ws1_slot_1299:
	.word 0
	.global ws1_slot_1300
ws1_slot_1300:
	.word 0
	.global ws1_slot_1301
ws1_slot_1301:
	.word 0
	.global ws1_slot_1302
ws1_slot_1302:
	.word 0
	.global ws1_slot_1303
ws1_slot_1303:
	.word 0
	.global ws1_slot_1304
ws1_slot_1304:
	.word 0
	.global ws1_slot_1305
ws1_slot_1305:
	.word 0
	.global ws1_slot_1306
ws1_slot_1306:
	.word 0
	.global ws1_slot_1307
ws1_slot_1307:
	.word 0
	.global ws1_slot_1308
ws1_slot_1308:
	.word 0
	.global ws1_slot_1309
ws1_slot_1309:
	.word 0
	.global ws1_slot_1310
ws1_slot_1310:
	.word 0
	.global ws1_slot_1311
ws1_slot_1311:
	.word 0
	.global ws1_slot_1312
ws1_slot_1312:
	.word 0
	.global ws1_slot_1313
ws1_slot_1313:
	.word 0
	.global ws1_slot_1314
ws1_slot_1314:
	.word 0
	.global ws1_slot_1315
ws1_slot_1315:
	.word 0
	.global ws1_slot_1316
ws1_slot_1316:
	.word 0
	.global ws1_slot_1317
ws1_slot_1317:
	.word 0
	.global ws1_slot_1318
ws1_slot_1318:
	.word 0
	.global ws1_slot_1319
ws1_slot_1319:
	.word 0
	.global ws1_slot_1320
ws1_slot_1320:
	.word 0
	.global ws1_slot_1321
ws1_slot_1321:
	.word 0
	.global ws1_slot_1322
ws1_slot_1322:
	.word 0
	.global ws1_slot_1323
ws1_slot_1323:
	.word 0
	.global ws1_slot_1324
ws1_slot_1324:
	.word 0
	.global ws1_slot_1325
ws1_slot_1325:
	.word 0
	.global ws1_slot_1326
ws1_slot_1326:
	.word 0
	.global ws1_slot_1327
ws1_slot_1327:
	.word 0
	.global ws1_slot_1328
ws1_slot_1328:
	.word 0
	.global ws1_slot_1329
ws1_slot_1329:
	.word 0
	.global ws1_slot_1330
ws1_slot_1330:
	.word 0
	.global ws1_slot_1331
ws1_slot_1331:
	.word 0
	.global ws1_slot_1332
ws1_slot_1332:
	.word 0
	.global ws1_slot_1333
ws1_slot_1333:
	.word 0
	.global ws1_slot_1334
ws1_slot_1334:
	.word 0
	.global ws1_slot_1335
ws1_slot_1335:
	.word 0
	.global ws1_slot_1336
ws1_slot_1336:
	.word 0
	.global ws1_slot_1337
ws1_slot_1337:
	.word 0
	.global ws1_slot_1338
ws1_slot_1338:
	.word 0
	.global ws1_slot_1339
ws1_slot_1339:
	.word 0
	.global ws1_slot_1340
ws1_slot_1340:
	.word 0
	.global ws1_slot_1341
ws1_slot_1341:
	.word 0
	.global ws1_slot_1342
ws1_slot_1342:
	.word 0
	.global ws1_slot_1343
ws1_slot_1343:
	.word 0
	.global ws1_slot_1344
ws1_slot_1344:
	.word 0
	.global ws1_slot_1345
ws1_slot_1345:
	.word 0
	.global ws1_slot_1346
ws1_slot_1346:
	.word 0
	.global ws1_slot_1347
ws1_slot_1347:
	.word 0
	.global ws1_slot_1348
ws1_slot_1348:
	.word 0
	.global ws1_slot_1349
ws1_slot_1349:
	.word 0
	.global ws1_slot_1350
ws1_slot_1350:
	.word 0
	.global ws1_slot_1351
ws1_slot_1351:
	.word 0
	.global ws1_slot_1352
ws1_slot_1352:
	.word 0
	.global ws1_slot_1353
ws1_slot_1353:
	.word 0
	.global ws1_slot_1354
ws1_slot_1354:
	.word 0
	.global ws1_slot_1355
ws1_slot_1355:
	.word 0
	.global ws1_slot_1356
ws1_slot_1356:
	.word 0
	.global ws1_slot_1357
ws1_slot_1357:
	.word 0
	.global ws1_slot_1358
ws1_slot_1358:
	.word 0
	.global ws1_slot_1359
ws1_slot_1359:
	.word 0
	.global ws1_slot_1360
ws1_slot_1360:
	.word 0
	.global ws1_slot_1361
ws1_slot_1361:
	.word 0
	.global ws1_slot_1362
ws1_slot_1362:
	.word 0
	.global ws1_slot_1363
ws1_slot_1363:
	.word 0
	.global ws1_slot_1364
ws1_slot_1364:
	.word 0
	.global ws1_slot_1365
ws1_slot_1365:
	.word 0
	.global ws1_slot_1366
ws1_slot_1366:
	.word 0
	.global ws1_slot_1367
ws1_slot_1367:
	.word 0
	.global ws1_slot_1368
ws1_slot_1368:
	.word 0
	.global ws1_slot_1369
ws1_slot_1369:
	.word 0
	.global ws1_slot_1370
ws1_slot_1370:
	.word 0
	.global ws1_slot_1371
ws1_slot_1371:
	.word 0
	.global ws1_slot_1372
ws1_slot_1372:
	.word 0
	.global ws1_slot_1373
ws1_slot_1373:
	.word 0
	.global ws1_slot_1374
ws1_slot_1374:
	.word 0
	.global ws1_slot_1375
ws1_slot_1375:
	.word 0
	.global ws1_slot_1376
ws1_slot_1376:
	.word 0
	.global ws1_slot_1377
ws1_slot_1377:
	.word 0
	.global ws1_slot_1378
ws1_slot_1378:
	.word 0
	.global ws1_slot_1379
ws1_slot_1379:
	.word 0
	.global ws1_slot_1380
ws1_slot_1380:
	.word 0
	.global ws1_slot_1381
ws1_slot_1381:
	.word 0
	.global ws1_slot_1382
ws1_slot_1382:
	.word 0
	.global ws1_slot_1383
ws1_slot_1383:
	.word 0
	.global ws1_slot_1384
ws1_slot_1384:
	.word 0
	.global ws1_slot_1385
ws1_slot_1385:
	.word 0
	.global ws1_slot_1386
ws1_slot_1386:
	.word 0
	.global ws1_slot_1387
ws1_slot_1387:
	.word 0
	.global ws1_slot_1388
ws1_slot_1388:
	.word 0
	.global ws1_slot_1389
ws1_slot_1389:
	.word 0
	.global ws1_slot_1390
ws1_slot_1390:
	.word 0
	.global ws1_slot_1391
ws1_slot_1391:
	.word 0
	.global ws1_slot_1392
ws1_slot_1392:
	.word 0
	.global ws1_slot_1393
ws1_slot_1393:
	.word 0
	.global ws1_slot_1394
ws1_slot_1394:
	.word 0
	.global ws1_slot_1395
ws1_slot_1395:
	.word 0
	.global ws1_slot_1396
ws1_slot_1396:
	.word 0
	.global ws1_slot_1397
ws1_slot_1397:
	.word 0
	.global ws1_slot_1398
ws1_slot_1398:
	.word 0
	.global ws1_slot_1399
ws1_slot_1399:
	.word 0
	.global ws1_slot_1400
ws1_slot_1400:
	.word 0
	.global ws1_slot_1401
ws1_slot_1401:
	.word 0
	.global ws1_slot_1402
ws1_slot_1402:
	.word 0
	.global ws1_slot_1403
ws1_slot_1403:
	.word 0
	.global ws1_slot_1404
ws1_slot_1404:
	.word 0
	.global ws1_slot_1405
ws1_slot_1405:
	.word 0
	.global ws1_slot_1406
ws1_slot_1406:
	.word 0
	.global ws1_slot_1407
ws1_slot_1407:
	.word 0
	.global ws1_slot_1408
ws1_slot_1408:
	.word 0
	.global ws1_slot_1409
ws1_slot_1409:
	.word 0
	.global ws1_slot_1410
ws1_slot_1410:
	.word 0
	.global ws1_slot_1411
ws1_slot_1411:
	.word 0
	.global ws1_slot_1412
ws1_slot_1412:
	.word 0
	.global ws1_slot_1413
ws1_slot_1413:
	.word 0
	.global ws1_slot_1414
ws1_slot_1414:
	.word 0
	.global ws1_slot_1415
ws1_slot_1415:
	.word 0
	.global ws1_slot_1416
ws1_slot_1416:
	.word 0
	.global ws1_slot_1417
ws1_slot_1417:
	.word 0
	.global ws1_slot_1418
ws1_slot_1418:
	.word 0
	.global ws1_slot_1419
ws1_slot_1419:
	.word 0
	.global ws1_slot_1420
ws1_slot_1420:
	.word 0
	.global ws1_slot_1421
ws1_slot_1421:
	.word 0
	.global ws1_slot_1422
ws1_slot_1422:
	.word 0
	.global ws1_slot_1423
ws1_slot_1423:
	.word 0
	.global ws1_slot_1424
ws1_slot_1424:
	.word 0
	.global ws1_slot_1425
ws1_slot_1425:
	.word 0
	.global ws1_slot_1426
ws1_slot_1426:
	.word 0
	.global ws1_slot_1427
ws1_slot_1427:
	.word 0
	.global ws1_slot_1428
ws1_slot_1428:
	.word 0
	.global ws1_slot_1429
ws1_slot_1429:
	.word 0
	.global ws1_slot_1430
ws1_slot_1430:
	.word 0
	.global ws1_slot_1431
ws1_slot_1431:
	.word 0
	.global ws1_slot_1432
ws1_slot_1432:
	.word 0
	.global ws1_slot_1433
ws1_slot_1433:
	.word 0
	.global ws1_slot_1434
ws1_slot_1434:
	.word 0
	.global ws1_slot_1435
ws1_slot_1435:
	.word 0
	.global ws1_slot_1436
ws1_slot_1436:
	.word 0
	.global ws1_slot_1437
ws1_slot_1437:
	.word 0
	.global ws1_slot_1438
ws1_slot_1438:
	.word 0
	.global ws1_slot_1439
ws1_slot_1439:
	.word 0
	.global ws1_slot_1440
ws1_slot_1440:
	.word 0
	.global ws1_slot_1441
ws1_slot_1441:
	.word 0
	.global ws1_slot_1442
ws1_slot_1442:
	.word 0
	.global ws1_slot_1443
ws1_slot_1443:
	.word 0
	.global ws1_slot_1444
ws1_slot_1444:
	.word 0
	.global ws1_slot_1445
ws1_slot_1445:
	.word 0
	.global ws1_slot_1446
ws1_slot_1446:
	.word 0
	.global ws1_slot_1447
ws1_slot_1447:
	.word 0
	.global ws1_slot_1448
ws1_slot_1448:
	.word 0
	.global ws1_slot_1449
ws1_slot_1449:
	.word 0
	.global ws1_slot_1450
ws1_slot_1450:
	.word 0
	.global ws1_slot_1451
ws1_slot_1451:
	.word 0
	.global ws1_slot_1452
ws1_slot_1452:
	.word 0
	.global ws1_slot_1453
ws1_slot_1453:
	.word 0
	.global ws1_slot_1454
ws1_slot_1454:
	.word 0
	.global ws1_slot_1455
ws1_slot_1455:
	.word 0
	.global ws1_slot_1456
ws1_slot_1456:
	.word 0
	.global ws1_slot_1457
ws1_slot_1457:
	.word 0
	.global ws1_slot_1458
ws1_slot_1458:
	.word 0
	.global ws1_slot_1459
ws1_slot_1459:
	.word 0
	.global ws1_slot_1460
ws1_slot_1460:
	.word 0
	.global ws1_slot_1461
ws1_slot_1461:
	.word 0
	.global ws1_slot_1462
ws1_slot_1462:
	.word 0
	.global ws1_slot_1463
ws1_slot_1463:
	.word 0
	.global ws1_slot_1464
ws1_slot_1464:
	.word 0
	.global ws1_slot_1465
ws1_slot_1465:
	.word 0
	.global ws1_slot_1466
ws1_slot_1466:
	.word 0
	.global ws1_slot_1467
ws1_slot_1467:
	.word 0
	.global ws1_slot_1468
ws1_slot_1468:
	.word 0
	.global ws1_slot_1469
ws1_slot_1469:
	.word 0
	.global ws1_slot_1470
ws1_slot_1470:
	.word 0
	.global ws1_slot_1471
ws1_slot_1471:
	.word 0
	.global ws1_slot_1472
ws1_slot_1472:
	.word 0
	.global ws1_slot_1473
ws1_slot_1473:
	.word 0
	.global ws1_slot_1474
ws1_slot_1474:
	.word 0
	.global ws1_slot_1475
ws1_slot_1475:
	.word 0
	.global ws1_slot_1476
ws1_slot_1476:
	.word 0
	.global ws1_slot_1477
ws1_slot_1477:
	.word 0
	.global ws1_slot_1478
ws1_slot_1478:
	.word 0
	.global ws1_slot_1479
ws1_slot_1479:
	.word 0
	.global ws1_slot_1480
ws1_slot_1480:
	.word 0
	.global ws1_slot_1481
ws1_slot_1481:
	.word 0
	.global ws1_slot_1482
ws1_slot_1482:
	.word 0
	.global ws1_slot_1483
ws1_slot_1483:
	.word 0
	.global ws1_slot_1484
ws1_slot_1484:
	.word 0
	.global ws1_slot_1485
ws1_slot_1485:
	.word 0
	.global ws1_slot_1486
ws1_slot_1486:
	.word 0
	.global ws1_slot_1487
ws1_slot_1487:
	.word 0
	.global ws1_slot_1488
ws1_slot_1488:
	.word 0
	.global ws1_slot_1489
ws1_slot_1489:
	.word 0
	.global ws1_slot_1490
ws1_slot_1490:
	.word 0
	.global ws1_slot_1491
ws1_slot_1491:
	.word 0
	.global ws1_slot_1492
ws1_slot_1492:
	.word 0
	.global ws1_slot_1493
ws1_slot_1493:
	.word 0
	.global ws1_slot_1494
ws1_slot_1494:
	.word 0
	.global ws1_slot_1495
ws1_slot_1495:
	.word 0
	.global ws1_slot_1496
ws1_slot_1496:
	.word 0
	.global ws1_slot_1497
ws1_slot_1497:
	.word 0
	.global ws1_slot_1498
ws1_slot_1498:
	.word 0
	.global ws1_slot_1499
ws1_slot_1499:
	.word 0
	.global ws1_slot_1500
ws1_slot_1500:
	.word 0
	.global ws1_slot_1501
ws1_slot_1501:
	.word 0
	.global ws1_slot_1502
ws1_slot_1502:
	.word 0
	.global ws1_slot_1503
ws1_slot_1503:
	.word 0
	.global ws1_slot_1504
ws1_slot_1504:
	.word 0
	.global ws1_slot_1505
ws1_slot_1505:
	.word 0
	.global ws1_slot_1506
ws1_slot_1506:
	.word 0
	.global ws1_slot_1507
ws1_slot_1507:
	.word 0
	.global ws1_slot_1508
ws1_slot_1508:
	.word 0
	.global ws1_slot_1509
ws1_slot_1509:
	.word 0
	.global ws1_slot_1510
ws1_slot_1510:
	.word 0
	.global ws1_slot_1511
ws1_slot_1511:
	.word 0
	.global ws1_slot_1512
ws1_slot_1512:
	.word 0
	.global ws1_slot_1513
ws1_slot_1513:
	.word 0
	.global ws1_slot_1514
ws1_slot_1514:
	.word 0
	.global ws1_slot_1515
ws1_slot_1515:
	.word 0
	.global ws1_slot_1516
ws1_slot_1516:
	.word 0
	.global ws1_slot_1517
ws1_slot_1517:
	.word 0
	.global ws1_slot_1518
ws1_slot_1518:
	.word 0
	.global ws1_slot_1519
ws1_slot_1519:
	.word 0
	.global ws1_slot_1520
ws1_slot_1520:
	.word 0
	.global ws1_slot_1521
ws1_slot_1521:
	.word 0
	.global ws1_slot_1522
ws1_slot_1522:
	.word 0
	.global ws1_slot_1523
ws1_slot_1523:
	.word 0
	.global ws1_slot_1524
ws1_slot_1524:
	.word 0
	.global ws1_slot_1525
ws1_slot_1525:
	.word 0
	.global ws1_slot_1526
ws1_slot_1526:
	.word 0
	.global ws1_slot_1527
ws1_slot_1527:
	.word 0
	.global ws1_slot_1528
ws1_slot_1528:
	.word 0
	.global ws1_slot_1529
ws1_slot_1529:
	.word 0
	.global ws1_slot_1530
ws1_slot_1530:
	.word 0
	.global ws1_slot_1531
ws1_slot_1531:
	.word 0
	.global ws1_slot_1532
ws1_slot_1532:
	.word 0
	.global ws1_slot_1533
ws1_slot_1533:
	.word 0
	.global ws1_slot_1534
ws1_slot_1534:
	.word 0
	.global ws1_slot_1535
ws1_slot_1535:
	.word 0
	.global ws1_slot_1536
ws1_slot_1536:
	.word 0
	.global ws1_slot_1537
ws1_slot_1537:
	.word 0
	.global ws1_slot_1538
ws1_slot_1538:
	.word 0
	.global ws1_slot_1539
ws1_slot_1539:
	.word 0
	.global ws1_slot_1540
ws1_slot_1540:
	.word 0
	.global ws1_slot_1541
ws1_slot_1541:
	.word 0
	.global ws1_slot_1542
ws1_slot_1542:
	.word 0
	.global ws1_slot_1543
ws1_slot_1543:
	.word 0
	.global ws1_slot_1544
ws1_slot_1544:
	.word 0
	.text

