# Session 32 - Target locked: OUR OWN Android port on QNX; RE blueprint of RIM's porting layer

Device: PRD-64100 Classic, OS 10.3.3, rooted userland, QNX root via `/base/bin/__root`.
Date: 2026-09-13.

## THE GOAL (user-locked, final)

Make either an **Android 11 OR Android 15 port** - a NEW runtime we build ourselves,
NOT a graft on top of the 4.3 player. Method: understand RIM's existing port WELL ENOUGH to
recreate it, then build our port from AOSP source.

Hard constraints (still binding):
- We do NOT replace QNX. QNX microkernel stays. No boot image / kernel changes.
- Passport LineageOS 18.1 (real Linux A11) = evidence of raw device capability only, NOT our path.
- We target Android USERLAND ported to QNX the way RIM ported 4.3, but we do it ourselves for 11/15.

## RIM's porting layer = THE SPECIMEN (reverse-engineering targets)

The following binaries are pulled to /tmp/opencode/ and dissected (disassembly of QNX ELF):

| Specimen | What it reveals (the recreate-me surface) | Status |
|---|---|---|
| `libbionic.so` (from .bar) | The cArECORE: how bionic is re-pointed at QNX libc. zhuowei evidence: NEEDED libc.so.3, libpps.so.1, libscreen.so.1; imports MsgSendvsnc, slog*, screen_*, android_uid_to_qnx, ioctl_binder | HAVE evidence (gist) - need full RE |
| `system/bin/android_resmgr` (39408B, QNX ELF, on disk) | QNX resource manager providing container VFS; resmgr_attach/msgread/iofunc; PPS layout; virtual devices | On disk, partial strings only |
| `system/bin/shrimp` (71808B, QNX ELF, on disk) | QNX<->Android IPC bridge; PPS channels; appmanager/navigatorpoll/pushclient poll tasks; sqlite | On disk, partial strings only |
| `sbin/android_launcher` (18056B, QNX ELF, on disk) | Bootstrapper: ANDROID_PLAYER_HOME, /data, PPS status init, fork of init | On disk, partial strings only |
| QNX binder driver + `ioctl_binder` | How binder IPC travels over QNX (driver? socket? shared mem + ioctl) | NOT pulled - HIGH PRIORITY |
| Screen bridge (SurfaceFlinger<->QNX screen) | How the Android compositor drives QNX Screen Graphics Subsystem | NOT pulled - HIGH PRIORITY |
| QNX-side HAL shims (sensors/camera/radio) | How Android HAL calls cross into QNX device services | NOT pulled - HIGH PRIORITY |
| `init.cfg` (from .bar native/) | Process model + zygote spawn wiring, BOOTCLASSPATH | PULLED (notes 26/27/31) |
| property service / PPS / slog mapping | Android property & log system re-pointed at QNX PPS + slog2 | Partial |

TOP PRIORITY: the binder + screen bridge + HAL crossings. Those three define the ABI we must
recreate; everything else (libc mapping, property/log) is mechanical once we see the pattern.

## DELIVERABLE OF THIS PHASE

A written "RIM port architecture" document (pairing each AOSP subsystem with its QNX mapping),
sufficient that a fresh engineer could recreate the port from AOSP source. Signature analysis:
disassemble each child lib, enumerate bionic->QNX import mappings, identify the binder/screen
IPC surfaces, and document the serve (device-driver) side.

## TARGET SELECTION (A11 vs A15) - decision criteria

| Criterion | Android 11 (R, API 30) | Android 15 (V, API 35) |
|---|---|---|
| Userland size / surface to port | Much smaller; ART still lean; classic binder | Huge; GKI-era, full hwcomposer/HIDL-AIDL both |
| Existing msm8974-only reference | LineageOS 18.1 (Passport) zip in Downloads | none |
| ART on QNX tractability | ART 11 = manageable | ART 15 = far harder |
| Kernel deps moved to userland ours | fewer | more (everything modern needs later ABI) |

RECOMMENDATION: **Android 11 first** (tractable proof the port-recreation works), 15 as the
stretch/goal after the architecture RE is done and the QNX porting skeleton is proven.

## WORKSTREAMS (DAG order)

1. RE core: libbionic-on-QNX (cArECORE) — map every bionic symbol to its QNX realization.
2. RE IPC: `ioctl_binder` + binder driver + servicemanager over QNX.
3. RE compositor: SurfaceFlinger/EGL -> QNX screen bridge; note hwcomposer equivalent.
4. RE resource mgmt: android_resmgr VFS + PPS layout + property/log mapping.
5. RE HAL: how android HAL modules call into QNX (sensors/camera/radio/gps) + uid mapping.
6. RE process model: android_launcher -> init -> zygote on QNX; signal/exit/daemon policies.
7. Write the architecture doc (the recreate-me blueprint), pairing AOSP 11 subsystems to QNX.
8. Set up AOSP 11 build on this box, wafer the port layer per blueprint, iterate on device.

## NEXT ACTION
Begin workstreams 1-2 by pulling the remaining .bar children from the device (libbionic.so,
libandroid_runtime.so, libbinder child libs, qnx binder driver binary, screen bridge HAL libs)
and capturing `ioctl_binder` usage + PPS endpoints. Requires device SSH (currently failing:
"Authentication failed" from this box; re-verify LAN/ARP or retry ritual from session7w).

## REFERENCES
- gist.github.com/zhuowei/2664727 - qlibbionic_headers.txt (NEEDED libs + import list).
- notes/session26 (runtime map), session27 (bar internals), session31 (scope) supersedes 29/30.
- ~/Downloads/lineage-18.1-20250101-UNOFFICIAL-wseries.zip (Passport A11 Linux evidence only).
- work/classic_root.0.lst + tools/check_autoloader.py (UFS / autoloader tooling for flashing
  a NEW runtime container if we ship on-device as a .bar replacement).