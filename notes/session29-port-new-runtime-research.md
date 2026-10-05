# Session 29 - Research: how we would port a COMPLETELY NEW Android runtime ("grafting is not good enough")

Device: PRD-64100 Classic, OS 10.3.3, rooted. Date: 2026-09-13.

## User directive

Previous sessions approached "PXXIS modern Android" by grafting (BaseBundle HTML5 +
DesugarCollections + j$/ shims layered into `framework-extra.jar`). User directive this
session: that is not good enough — research (online + existing artifacts) how we would
**completely modify and port a completely new Android runtime**. Do the research BEFORE
any decisions.

## What the research settled (the load-bearing facts)

### FACT 1: The BB10/PlayBook Android runtime does NOT run stock AOSP binaries.
It is a **genuine QNX port** of the Android userland.

Decisive evidence — zhuowei's gist (ELF headers of `libbionic.so` from PlayBook 2.0.1
Android Player): gist.github.com/zhuowei/2664727 (`qlibbionic_headers.txt`):

- `NEEDED libscreen.so.1 libimg.so.1 libmmrndclient.so.1 libstrm.so.1 libpps.so.1
  libstdc++.so.6 libm.so.2 libc.so.3` — i.e. it links QNX system libraries
  (`libc.so.3` is the QNX libc versioned name), NOT the AOSP/bionic tree.
- Undefined/exported functions include QNX kernel/IPC primitives:
  `MsgSendvsnc`, `vopen`, `slogsend`/`slogi` (`_slog*`), `screen_*` Screen APIs,
  plus Android-face functions written as QNX integrations:
  `ioctl_binder`, `lmk_set_oomadj`, `android_uid_to_qnx`, `qnx_gid_to_android`,
  `map_android_id_to_qnx`, `injectGidIntoSupplementaryGroups`, `authman_send`,
  `__system_property_find`, `retainBootAnimSystemCapabilities`.
- Build env symbols: `BUILDENV_qss`, `VARIANT_v7/le/a` — QNX compiler convention.

Same pattern in our own pulled binaries (`android_launcher`, `android_resmgr`, `shrimp`
are QNX ELF ARM with QNX buildids). Android 4.3 core on this device (build.cfg sdk=18,
"Linux version 3.2.41-QNX" banner faked by android_resmgr) is the same design.

**Consequence:** the Android userland is recompiled FOR QNX. There is NO Linux ELF /
Linux-syscall compatibility layer in the QNX procnto here to accept stock AOSP binaries.
You cannot drop a stock AOSP 4.4/5.x `/system` in and have it exec.

### FACT 2: The `.dex`/`.jar` Java layer is the only portably-rebuildable slice.
Dalvik executes DEX bytecode; the framework jars are Java. Java-level APIs terminate at
the native layer (libandroid_runtime, libdvm, binder services, HALs). Anything a newer
Android needs that is NOT already serviced by the 4.3-era QNX native bridge
(android_resmgr / shrimp / servicemanager services / Screen bridge) has no native layer
to land on. So "API 19/21 class exists" (graftable) vs "the system behaviour works"
(native-bound) are different claims.

### FACT 3: The API ceiling is a native ceiling, not a version number.
Community consensus (Everything-Blackberry, Vivaldi thread, Wikipedia): BB10 Player =
Android 4.3 / API 18; "true API support" 18; apps 19-22 sometimes, 23+ fail. This is
not RIM choosing a number — it is the point where a native rebuild was abandoned.
RIM stopped porting the userland after 4.3 (and even that: 2.3.3 -> 4.1 -> 4.3 was
already a multi-release repoint of the SAME QNX port; phonescoop 2013; Wikipedia
10.3 "Android 4.3 runtime with multicore support").

### FACT 4: No hypervisor escape hatch.
Modern QNX solves Android-version-bumping via the **QNX Hypervisor** (qvm) running a
real Android/Linux guest with unmodified kernel — but that requires QNX SDP 7/8
hypervisor builds. This device runs QNX Neutrino 6.x-era (10.3.3); qvm/hypervisor is
not present in the image and cannot be synthesized. Thus "modern Android in a VM beside
BB10" is out-of-reach on THIS hardware/image.

### FACT 5: No source exists for the porting layer.
The QNX-side Android glue (bionic-on-QNX, android_resmgr, shrimp, epolld, exe_shim,
Screen bridge, `native/scripts/*`) was never open-sourced by BlackBerry. Community
repos found are samples (`blackberry/BB10-Android-Runtime-Samples`), kernel sources for
Linux-based BlackBerry phones (`blackberry/android-linux-kernel` — NOT QNX), and
survival/optimization guides (`tranhoangtu-it/Everything-Blackberry`). No one has
published the QNX Android runtime build tree. Re-creating it = re-doing RIM's original
multi-year, multi-engineer port from scratch, with no reference build.

## Feasibility matrix — "replace the runtime" options

| Option | Requires | Verdict |
|---|---|---|
| Drop in stock AOSP 4.4/5.x image | Linux ELF exec under QNX | IMPOSSIBLE — no Linux binary compat; userland is QNX-native (FACT 1) |
| Recompile newer AOSP for QNX | The entire proprietary QNX porting layer (FACT 5) + rebuild binder/HAL/screen services for new Android | Not achievable by us; months-years w/ team + internal source |
| Run modern Android as VM guest | QNX hypervisor | Not present on this 6.x-era image (FACT 4) |
| Re-target the existing port upward (KitKat-ish) | Same as row 2; RIM abandoned this exact effort at 4.3 | Same verdict |
| Keep 4.3 native core, modernize the **Java/framework layer** we control | dalvik/art-compatible DEX + libdvm support for new APIs | Achievable — this is exactly the grafting lane (session 24/25/27) |
| Modern ART instead of Dalvik | ART compiled for QNX (native), libandroid_runtime rebuild | Not feasible — same native-port problem as row 2 |

## Synthesis (grounded answer to "how would we?")

To **completely** replace this runtime you would need BlackBerry's internal QNX
Android-port build tree + the QNX BSP/toolchain, then repeat their per-version
re-pointer of bionic/libbindervm/HAL/screen onto a newer AOSP base — an effort RIM
itself stopped doing after Android 4.3. The device gives no shortcut (no Linux compat,
no hypervisor). Therefore:

The ONLY fully-modifiable surface we possess is the **Java/Dalvik framework layer** —
which is precisely the grafted-framework approach already staged (framework-extra.jar +
BaseBundle HTML5 shim). "Completely new runtime" as a literal end-state is not
available; "newest runtime the native core can host" is the real boundary, and
grafting is that boundary, not a fallback from it.

## Decision requested from user (no action taken yet)
Re-read the full port feasibility (FACT 1-5 + matrix here), then choose the direction
for PXYIX. Staged-but-abandoned in this session: resume the framework-extra.jar live
graft (framework + BaseBundle global shim), or a different reading of "new runtime".

## References
- gist.github.com/zhuowei/2664727 — `qlibbionic_headers.txt` (PlayBook Android Player libbionic ELF = QNX-linked). Keysite evidence.
- en.wikipedia.org/wiki/BlackBerry_10 — Android runtime history, 2.3.3->4.3, API 18 cap, multicore note.
- phonescoop.com/articles/article-11888 (2013) — RIM planned runtime 2.3.3->4.1 update.
- github.com/tranhoangtu-it/Everything-Blackberry — Android_Runtime_Optimization.md (Player = 4.3/API 18), Sideloading_Masterclass.md (APK->BAR, API ≤18 best, 19-22 maybe, 23+ fail).
- github.com/blackberry/BB10-Android-Runtime-Samples; github.com/blackberry/android-linux-kernel (Linux-phone kernels, not QNX).
- forum.vivaldi.net 79976 — user-reported device identity "Java Runtime version: android runtime 0.9", API-18 reality.
- qnx.com docs (procnto, process loading) — QNX loads QNX ELF via procnto; no Linux-ABI carriers in Neutrino 6.x.