# Session 38a - Repo audit + A11 golden-reference status (accompanies session38)

Date 2026-09-14. Companion to `session38-a11-on-qnx-port-plan.md`. Documents what is
ALREADY on-disk vs. what the live device must supply.

## A. Repo audit (answered "should the sysroot already be here?")

The QNX ARM build sysroot is NOT on disk. Only this:
- `specimens/qnx_libc.so.3`, `qnx_libpps.so.1`, `qnx_libscreen.so.1` = 4.3 QNX-link targets (raw).
- `/tmp/opencode/resmgr.h`, `iofunc.h`, `iomsg.h` = 3 QNX headers recovered earlier.
- `priv-research/bbndk-tools/bbndk.win32.tools.zip` (305 MB) = **win32-host-only** NDK:
  `host_10_3_1_12/win32/x86/usr/bin/ntoarmv7-gcc-4.8.3.exe` etc. NO ARM target tree
  (no libc.so.3, no ldqnx.so.2, no target `usr/include`) — the target package is a
  separate NDK download not present.
- `priv-research/kernel/bb_kernel_AAO474` = BB kernel AOSP-source (Linux), not QNX.
- No extracted 4.3 or A11 system rootfs anywhere on disk.

Conclusion: **Gate A (buildable QNX ARM sysroot) REQUIRES the live Classic.** Pull targets:
  /lib/libc.so.3, /usr/lib/ldqnx.so.2, /lib/libm.so.2, /lib/libsocket.so.3, /lib/libimg.so.1,
  /lib/libforensics, /lib/libmmrndclient.so.1, /lib/libstrm.so.1, libc++.so/.a (find real name),
  /usr/include/{resmgr,iofunc,iomsg,screen,pps,slog,stdio,stdlib,unistd,fcntl,sys/uio,sys/shm,sys/mman}.h
  (the last 3 + libc headers are the ABI the QNX libc actually exposes to bionic-recompile).

## B. A11 golden reference status (local, done)

Pulled to `ref/a11_core/` from `lineage-18.1-Tom-bacon system.img` (32-bit, SDK30):
  11 core natives: libbinder.so(452K), libbinder_ndk.so, libandroid_runtime.so(1.19M),
  libbase.so, libcutils.so, libutils.so, libui.so, liblog.so, librs_jni.so, libEGL.so,
  libGLESv2.so (+ libstdc++.so from /system/lib).
Found: A11 **APEXes are stored as EXTRACTED DIRECTORIES** `/system/apex/com.android.<X>/{lib,bin,javalib,etc,apex_manifest.pb}` —
  NO `.apex` container unpacking needed (big simplification for our port: the "already-made image"
  is directly readable). A11 bionic (`libc.so`/`libm.so`/`libdl.so` in `/system/lib`) are SYMLINKS
  into an APEX (exact target to pull next: likely `com.android.i18n` or a bionic apex).
  ART lives in `com.android.art.release/lib`. Remaining to pull for WS1: the real `libc.so`
  (bionic) + `libart.so`/`libartbase.so` — fast follow-on here.

## C. Immediate decision

Everything local is in place to DESIGN WS1 (A11 libbionic on QNX): we have A11 bionic-surface
in hand + the 4.3 `libbionic.so` 403-export/import map to recreate. The single blocker to
PRODUCE runnable ARM QNX ELFs is Gate A (device sysroot pull) — cannot be done locally.

## NEXT (ranked)
1. (Gate A) Connect Classic: `blackberry-connect 169.254.0.1 -password 61482501 -sshPublicKey id_rsa.pub`
   then `connect_now.py`; `__root` ksh; pull the QNX libs+headers in §A to `sysroot/`; hello-ARM
   probe linking our 4.3 qnx_libc.so.3 + resmgr.h.
2. (WS1-close) Pull A11 bionic `libc.so` + ART from the bacon image (local) and finish the ABI map.
3. (F2 verify) On-device: stop the 4.3 runtime player, confirm the phone keeps running; prove
   A/B swap of the `native/system` tree is safe + instant-revert.