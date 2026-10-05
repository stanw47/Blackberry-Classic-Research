# Session 38b — GATE A (QNX ARM sysroot) status — 2026-09-14

STATUS: ~70% done on this box. Remaining ~30% needs the QNX SDP (dev credentials).

## What we DID (this session)
### Connected the Classic (PRD-64100, QNX 8.0.0 2018-02-21 rev 11, MSM8960)
  - blackberry-connect ritual -> SSH :22 open; root via /base/bin/__root.
### Pulled the real on-device QNX runtime libs (soft-float ARM32) into a local sysroot
  - sysroot/target/lib/libc.so.3        (598,616 B)  [real QNX C runtime]
  - sysroot/target/lib/libstdc++.so.6.0.19  (682,140 B)
  - sysroot/target/lib/libimg.so.1       (50,984 B)
  - ABI verified:  ELF32, ARM, EABI5, SOFT-FLOAT, flags 0x5000200 / System V
### Proved the build recipe (helloqnx -> libhello.so)
  - arm-none-eabi-gcc  ... -shared -nostdlib -march=armv7-a
    -Wl,-soname,libhello.so -o libhello.so hello.c
    -L sysroot/target/lib -Wl,-
  - Result:  ELF 32-bit ARM, EABI5, SOFT-FLOAT, SONAME libhello.so, NEEDED [libc.so.3]
    -> ABI-identical to libc.so.3.  The DEVICE pulls cleanly.
### Confirmed toolchain + got 3 of the needed QNX headers
  - /tmp/opencode: resmgr.h (12478 B), iofunc.h (26422 B), iomsg.h (20848 B)
    + x86 syscall table, gcompat.h (bonus).  (Copied into sysroot/target/include.)

## What is BLOCKED (the ~30%)
  - resmgr.h / iofunc.h NEED ~a dozen missing QNX <sys/*.h> headers:
      sys/platform.h, sys/neutrino.h, sys/iomgr.h, sys/iomsg.h, sys/resmgr.h,
      sys/resmgr_compat.h, sys/srcversion.h, sys/ftype.h, pack64.h, ...
    and the real QNX pm.h (not the MIT GPL one).
  - Those live ONLY in a QNX SDP.  The device /usr/include is EMPTY; they are NOT
    on this box.  -> a real resmgr/img/pps-using source cannot compile yet.
  - No QNX qcc / NTO linker on this box (host qcc from SDP).

## The ONE input needed to unblock WS1..WS8 (all real compiling)
  A QNX SDP (or at its minimum, the QNX target include tree + qcc):
  - Best match for this Classic:  QNX 8.0.0 / BB10 10.3 build (host for a
    PRD-64100, soft-float ARM).   Requires your BlackBerry-Access / QNX dev creds.
  - Until it lands, all WS1-WS8 stay in "design"/template form (no real ARM compile).

## Next (no device, no SDP):
  1. Draft WS1 (libbionic-on-QNX) as ready-to-compile C + a Makefile pinned to
     the flags above, so it compiles the instant the SDP include/ + qcc appear.
  2. When the SDP lands:  extract its <target>/usinclude + qcc, drop into
     sysroot/, re-run the helloqnx probe (now linking real resmgr), then start WS2.
