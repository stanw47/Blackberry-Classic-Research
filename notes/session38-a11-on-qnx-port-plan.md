# Session 38 - A11-on-QNX port: locked plan, status, and critical path

Device: PRD-64100 Classic, OS 10.3.3.3216, grounded userland, QNX root via `/base/bin/__root`.
Date: 2026-09-14. Supersedes the "hard-ceiling" verdict of sessions 29/30 for the keep-QNX path.

## Why this session exists

User re-locked scope and corrected two things the earlier notes left open:

1. **Passport cannot run A11 without a HW mod** (eMMC chip out; boot0 fused/write-protected).
   => The Passport wseries 18.1 image is "evidence of raw SoC capability" ONLY, not our base.
2. **There is no Android port for Classic** (same fused-boot wall; Classic cannot boot a
   new kernel/Linux userland).
   => The **only** viable path is to modernize the Android runtime that ALREADY runs here:
   swap the 4.3 userland for an A11 userland, built the way RIM built 4.3 (QNX-native ELFs).

**THE ONE-LINE GOAL:** Replace `/apps/sys.android.*.ns/native/system/` (AOSP 4.3) with an
**AOSP Android 11 userland compiled for QNX**, iterating hot in the container while the QNX
microkernel + all native BB10 software keep the phone running.

## Three load-bearing facts (all confirmed in notes)

- **F1 — no kernel-swap.** Classic has NO Linux boot path; boot0 is fused. Any "A11" must ride
  the existing QNX microkernel, as pure userland. (session7d/7l, 9a, 10a, 32)
- **F2 — QNX runs fine WITHOUT the Android runtime.** The 4.3 runtime is a swappable userland
  module in the `.ns` container; killing it leaves dialer/mail/browser/native apps working.
  (user-asserted; to re-confirm live on device this session). This is what makes the swap
  iterative and non-bricking: the A11 userland is hot-swappable inside the container.
- **F3 — A11 exists as 32-bit armeabi-v7a and is the exact ABI twin here.** The `bacon`
  (OnePlus One) 18.1 A11 build is 32-bit-only (`ro.product.cpu.abilist=armeabi-v7a,armeabi`),
  Krait ARMv7 = same class as the Classic's target. Reference: full `system.img` = **529 native
  `.so` in `/system/lib` + 44 framework jars in `/system/framework`**, extracted and listable now
  (debugfs). (session33, 37)

## The RIM port model (what we are recreating, confirmed from binaries)

Android processes on BB10 are **QNX-native ELFs** (interp `/usr/lib/ldqnx.so.2`) linked against
**QNX `libc.so.3`**, with a single interposer `libbionic.so` providing the Android bionic ABI
on top. Every Linux syscall/IPC/HAL endpoint is re-pointed at a QNX primitive:

| AOSP subsystem | 4.3 RIM realization | A11 target realization (ours) |
|---|---|---|
| libc/bionic | `libbionic.so` 85KB, 403 exports, delegates to libc.so.3/libm/socket/pps | **WS1** rebuild A11 bionic ABI over QNX (FOUNDATION) |
| binder IPC | `/dev/binder` = QNX resmgr (resmgr_attach/MsgSend*/shm); `binder_devctl`; BINDER_WRITE_READ 0xc0186201 | **WS2** DONE host-validated; cross-compile to ARM |
| compositor/graphics | `libgralloc_screen/libframebuffer_screen/libhwcwindow` -> QNX screen+img, EGL | **WS3** A11 gralloc4 + hwcomposer2 bridge (gralloc1 stub exists) |
| props/log/native VFS | `android_resmgr` (QNX resmgr: VFS+/proc+/dev, PPS nodes); props->PPS; log->slog2 | **WS4** A11 `android_resmgr`/property_context/`/dev` shim |
| ART runtime | Dalvik (`libdvm`) | **WS5** A11 `libart.so` (JIT/GC) recompiled on QNX pthreads (BIGGEST) |
| process model/init | `android_launcher`->`app_process -Xzygote`; init.cfg by QNX init-eq | **WS6** A11 zygote `pre_zygote`/`app_process` + AOSP rc -> QNX init.cfg |
| HAL crossings | sensors->PPS, camera->camapi, audio->asound, gps->GNSS | **WS7** A11 `hardware.*` HALs -> same QNX services |
| framework/boot | BOOTCLASSPATH 4.3 jars; BOOTCLASSPATH 4.3 | **WS8** A11 bootclasspath + odex + mainline APEX artifacts |

## Status (honest running total, as of now)

| WS | Piece | State | Evidence |
|---|---|---|---|
| WS2 | A11 binder-on-QNX resmgr | **DONE + host-verified** (ABI all-pass; 23/23 unit; 6/6 glue; ASan/UBSan clean) | `binder/{src,tests,BUILD.md}` (session37) |
| WS3 | gralloc1-over-QNX Screen | partial: `graphics/build/libgralloc_qnx.so` 30KB, **no device test** | `graphics/` |
| RE  | 4.3 port full RE | done: 42 C-specimens link/import map + binder/screen disasm | `specimens/`, (session26/27/34/35/36) |
| ref | A11 reference pulled | `specimens/a11_art_apex/` (ART APEX) + `specimens/passport_a11/` (hwbinder/aiddl) | `specimens/` |
| src | A11 AOSP libbinder/servicemanager | staged in tree | `graft/a11-frameworks-native/` |
| WS1 | A11 libbionic-on-QNX | **NOT STARTED** = the true foundation | -- |
| WS4,WS5,WS6,WS7,WS8 | resmgr-VFS, ART, zygote/init, HAL, framework | NOT STARTED | -- |

## Toolchain reality (sets what "build" currently means)

- Have: `arm-none-eabi-gcc`/`g++` 14.2 (ARM32), `debugfs`, objdump/capstone, QNX `resmgr.h/
  iofunc.h/iomsg.h`. No QNX SDP `qcc -Vgcc_ntoarmv7le` installed.
- Implication: a **full AOSP-11 tree build for QNX is not possible today** (needs QNX SDP
  7/8 toolchain + AOSP build-system re-target). What IS possible now: build **individual A11
  native libs against a hand-assembled QNX sysroot** (libc.so.3 + libc++ + libm/socket/
  screen/img/pps/slog2 headers/libs pulled from the Classic), e.g. the binder resmgr already
  demonstrated. => Plan must be per-library, not whole-tree, until QNX SDP is stood up.
- On-device: 4455 (qconnDoor) + 5555 (adbd) OPEN, 22 CLOSED (needs `blackberry-connect`
  ritual: `blackberry-connect 169.254.0.1 -password 61482501 -sshPublicKey id_rsa.pub`
  then `connect_now.py`).

## CRITICAL PATH (the 3 gates that everything downstream waits on)

- **GATE A — QNX sysroot**: pull the Classic's own QNX link targets (libc.so.3, libc++.a,
  libm.so.2, libsocket.so.3, libscreen.so.1, libimg.so.1, libpps.so.1, libslog2.so.3,
  libnbutil.so.1, libforensics.so.1, libmmrndclient.so.1, libstrm.so.1) + their headers into a
  buildable local sysroot. Without it we ship host-only. (blocks WS1)
- **GATE B — A11 3-bit libbionic-on-QNX**: rebuild the bionic ABI surface over QNX libc +
  exports (MsgSendv_*, ioctl_binder, __system_property_*, SyncCondvar-based futex, etc).
  (blocks WS5/ART, WS6/zygote, all userland) => the single most valuable next build.
- **GATE C — live swap harness**: prove (F2) empirically; preserve 4.3 container (B) and stage
  A11 userland (A) in the `.ns` container so one edit flips which `system/` the launcher loads.
  (blocks every device test)

Everything else (WS3-WS8) is downstream of A/B/C and can proceed in parallel once A is green.

## Staged milestones (honest, decodable)

- **M0 (this/next, host-side):** GATE A — pull QNX sysroot from device; extract full bacon A11
  `system/` (529 `.so`+44 jars+APEX+`/init`+`/vendor`) to a golden reference dir. Deliverable:
  a working ARM32 QNX cross-link probe (hello -> libc.so.3 + resmgr.h) from a clean tree.
- **M1:** GATE B — A11 `libbionic`-on-QNX links the binder + a printf/malloc/futex smoke.
- **M2:** A11 `libart.so`/libandroid_runtime cross-compile against that bionic (JIT/GC smoke).
- **M3:** GATE C — live A/B swap harness in the `.ns` container; 4.3 still boots (B fallback).
- **M4:** A11 binder resmgr (WS2) drops into the running container; first binder-mediated
  ping over the live resmgr.
- **M5:** A11 surfaceflinger->QNX screen (WS3) shows A11 bootanim/framebuffer; zygote foom
  reaches `system_server` (WS6/WS8).
- Beyond M5: HAL crossings (WS7) and full framework boot = the long tail to "apps run."

## What "best" means (recommended direction)

User: "use what we can from an already-made android image, adapt to run on top of QNX by
adapting it to the binder, OR the other way around, whatever you think is best."

Recommendation: **rebuild our own QNX port layer against AOSP-11 open sources, using the bacon
A11 3-bit image as the ABI golden reference** (NOT a drop-in of stock AOSP, which cannot exec on
QNX — FACT 1/33). The binder (done) is the hinge; the next foundational build is the A11
`libbionic`-on-QNX shim (WS1) because ART + every other userland piece links against bionic.

## Next concrete actions (ranked)

1. (GATE A) Pull the 12 QNX link-target libs + headers from the connected Classic into
   `sysroot/`; assemble local ARM32-QNX sysroot; hello-probe link+test.
2. (GATE C-early) Empirically confirm F2: stop the 4.3 runtime, verify phone keeps running.
3. Extract bacon A11 `system/` golden copy to `ref/a11_system/` (debugfs, read-only).
4. (GATE B) Begin WS1: map A11 bionic exports against the 4.3 libbionic 403-export map;
   author the A11 re-export -> QNX shim stub + build.

## References
- session29 (genuine QNX port, stock AOSP won't exec), 33 (bacon = 3-bit A11 twin),
  35 (binder=resmgr), 36 (RIM port architecture map), 37 (A11 binder blueprint, delivered),
  ANDROID-RUNTIME-COMPLETE-MAP.md (4.3 container layout), binder/{src,BUILD.md} (WS2 done).
- Golden A11 ref: `/home/stanw47/Downloads/lineage-18.1-20210106-UNOFFICIAL-Tom-bacon-signed/system.img`
  (529 .so in /system/lib, 44 jars in /system/framework, /vendor, /init, /apex).