# session72 — full A11 chain REGENERATED from committed source (reflash-recovery proven)
2026-09-21. Classic 10.3.3, Dev Mode re-enabled this session (device had rebooted; per-boot re-enable).
Context Q: "if I ever reflash the device, do we keep all binder+progress?" — ANSWER: yes, and proven
by a from-scratch rebuild this session. Device SSH link was DOWN at start (Dev Mode per-boot);
re-established via blackberry-connect 169.254.0.1:4455 (device pw) + fresh 4096 RSA + sshPublicKey
push, paramiko rsa-sha2 disabled + server_sig_algs=False. Link then live at 169.254.0.2<->169.254.0.1.

## THE reflash-survival proof: full rebuild from git, nothing else
  runtime/a11-build/build.sh     (compile 36 TUs -> /tmp/a11obj/aosp/*.o)   RC=0, ~1m28s
  runtime/a11-build/qnx-link.sh  (QNX-ELF relink whole chain)              RC=0
  Outputs (QNX-format, NEEDED libc.so.3-first order): libbase/liblog/libcutils/libutils/libbinder
  (libbinder 2.4MB incl AIDL cpp; libc++ .so relinked from static libc++/abi/unwind + aeabi stubs)
  Intact inputs needed for rebuild (NOT in git, but public + on-disk):
    ~/android-mine/ndk/android-ndk-r23c             NDK r23c clang (armv7a-linux-androideabi30)
    ~/android-mine/aosp/{frameworks_native, system_core, bionic, libcxx, logging, libbase, fmtlib}
  Device-side deploy target: /accounts/1000/shared/misc/android/qnx/  (devuser-owned, survives into
  container mount). NOTE: earlier sessions staged at /tmp/a11run — /tmp is per-boot wiped; the
  shared dir is the durable deploy path across reboots.
  Probe: runtime/a11-build/test/tb_a11.c -> ProcessState::self()  [committed this session]
  On-device binder node confirmed STILL PRESENT after reboot: /dev/binder nrw-rw---- 1000:10011
  (owner 1000:10011 = the A11 container identity, same as session71).

## What is NOT recoverable from git (honest list; all regenerable/ritual):
  * NDK + AOSP src trees (large, public downloads) — if lost, re-download (exact r23c + AOSP 11 dirs
    above). Everything else (glue, resolver, build harness, notes, probes) IS committed.
  * On-device /tmp + shared-dir lib copies — re-push from the committed rebuild (~90s).
  * /dev/binder node + /accounts/1000/... container mount — re-created by re-enabling Dev Mode at
    each boot; required before the binder chain probe can run ProcessState::self().

## Takeaway for a reflash
    1. re-enable Dev Mode (device pw). 2. blackberry-connect 4455 -> SSH up, push new key.
    3. host: bash runtime/a11-build/build.sh && qnx-link.sh  (both RC=0). 
    4. push the .so chain + tb_a11 to /accounts/1000/shared/misc/android/qnx/.
    5. run tb_a11 -> PROBE the binder node (next milestone: ProcessState::self() succeeding, which
       was the session71 wall; /dev/binder being present on-device is the newly-unblocked input).
