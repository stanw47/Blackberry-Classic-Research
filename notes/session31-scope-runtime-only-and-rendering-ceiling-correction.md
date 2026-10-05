# Session 31 - Scope: build OUR OWN Android 11/15 port on QNX (not a graft); GLES2.0 rendering ceiling DEMOTED

Device: PRD-64100 Classic, OS 10.3.3, rooted userland, adb `169.254.0.1:5555`, QNX root via
`/base/bin/__root`. Date: 2026-09-13.

## USER GOAL (authoritative, supersedes the "graft-on-4.3" reading of sessions 29/30)

> We should make either an Android 11 OR Android 15 port. We are NOT building on top of what is
> here (the 4.3 player). We build OUR OWN port by understanding what is already done WELL ENOUGH
> to be able to create our own port.
>
> And: we are NOT trying to REPLACE QNX. We keep the QNX kernel. We port a modern Android
> userland to run ON QNX the way RIM ported 4.3, but from Android 11/15 AOSP source ourselves.

Consequences:
- Deliverable = a NEW runtime: modern Android (ART-era) userland that runs as QNX processes,
  reproducing RIM's porting layer (bionic-on-QNX, resmgr, screen bridge, binder over QNX, init)
  from our OWN rebuild - not the prebuilt 4.3 `.bar`.
- RIM's installed 4.3 runtime (which we have root over) is the STUDY SPECIMEN: the target of
  full reverse-engineering until we can recreate the port.
- We do NOT boot Linux. QNX microkernel stays (no boot image / kernel changes). The Passport
  LineageOS 18.1 port (real Linux A11) is evidence of the devices' raw capability, not our path.
- The API-ceiling grafting (framework-extra.jar) is demoted to an optional interim step, NOT the
  goal.
- Android 11 vs 15: decide after the port-layer RE is complete (A11 is the more tractable
  first target - last pre-GKI userland, Lineage 18.1 msm8974 reference exists; A15 is the stretch).

## REFERENCE EVIDENCE RE-INTERPRETED

### Passport LineageOS 18.1 (Android 11) - VERIFIED REAL, but OUT OF SCOPE
Inspected `~/Downloads/lineage-18.1-20250101-UNOFFICIAL-wseries.zip` directly:
- `boot.img` = genuine `ANDROID!` boot image, 5.3 MB kernel, real AOSP Android 11.
- `pre-device=wolverine,wichita,oslo,keian` (Passport family, MSM8974).
- This is a FULL-OS port: Linux kernel + LineageOS running INSTEAD of BB10 (per xwtk/balika011
  / Haprocrat "BlackBerry Android Hideout"; requires prototype/unlocked bootloader or eMMC
  desolder). It proves MSM8974 coN can run real A11 - NOT that a QNX runtime can host A11.
- User confirmed this is NOT our path (we keep QNX). Value: calibration only.

### Why "newest Android possible" is now ceiling-mapped per-layer, not per-version
Version labels (A11/A15) describe a whole OS image. On QNX we cannot become "Android 11"; we
can only lift the runtime's Java/framework surface + rendering surface to the highest level the
QNX-native 4.3 core can host. So the honest deliverable is "API surface = newest feasible",
from the per-class selection already done (see below).

## GLES2.0 CEILING - DEMOTED (was the #1 "hardware" objection)

User's three userspace fallbacks - ALL CONFIRMED, ALL USERSAPCE-ONLY (inside our boundary):

1. **Extension-based partial GLES3 coverage.** Many GLES3 features exist as GLES2 extensions on
   Adreno 200-series. A thin `libGLESv3` userspace shim (eglGetProcAddress/function ptrs) that
   routes GLES3 entrypoints to the extension equivalents where present is standard technique.
2. **Manifest requirements stripping + app fallback.** Verified: Godot GLES2 renderer is
   explicitly "compatible with virtually all active Android devices" and is chosen when the
   GLES3 context can't be created; Unity supports GLES2 in Auto graphics API. So by stripping
   `android:glEsVersion="0x00030000"` / `uses-feature` and/or failing ES3 context creation,
   well-architected apps downgrade themselves rather than crash.
3. **SwiftShader software rendering.** Confirmed: Apache-2.0, "x86 and ARM, 32-bit and 64-bit",
   ARMv7 supported, dEQP-conformant OpenGL ES 3.0 (via ANGLE/SwANGLE stack) and Vulkan 1.3. Drop
   in as the EGL library under the runtime. Pure CPU, no kernel involvement.

RESULT: rendering is NOT a terminal surface. The really terminal surfaces are the
QNX-native-bound services (screen bridge properties, RIL/telephony, camera/radio path,
sensors, some HALs and binder services that have no Java standin), because those have no
userspace Java re-implementation.

## API CEILING MAP - the actual deliverable (already largely built)

`~/android-mine/SELECTION.report` (from "newest-feasible per-class selection" pass, Telegram
300 real framework gaps analyzed vs fw43 + 37 graft-capable java shims):

```
{'A15+shims': 226, 'A11+shims': 32, 'HARD': 31, 'NEITHER': 11}
```

- A15+shims (226): classes compilable from A15 bytecode, graftable with java shims.
- A11<A15 (32): need an A11-level source but still graftable.
- HARD (31): reference hard-native boundary (interface stubs, binder Service(.java)/I*Service,
  native-framework pull-ins like `android/os/PowerWhitelistManager`).
- NEITHER (11): not present at A15/A11 or impossible to satisfy reference.

This IS the "which API 19-22 surfaces are terminal vs native-bound" map. Each row also carries
the exact closure deps (`selection.txt` lists gap -> deps needed), so we know precisely which
pull-ins still fail (usually binder `I*Manager` classes that need an actual service).

## NEXT STEPS (no further clarification needed)
1. Complete a full RE blueprint of RIM's porting layer from the installed 4.3 runtime (specimen):
   every QNX-specific component, ABI mapping, and process boundary (list in session 32 goal).
   This is the "understand it well enough to recreate" phase.
2. Choose the port target (A11 recommended first; A15 stretch) and pull the corresponding AOSP
   source for cross-referencing during the RE.
3. Define the port-layer reproduction plan: which pieces map 1:1, what must be rebuilt, and the
   bootstrapping order (libc/bionic surface -> binder -> resmgr/screen bridge -> zygote/ART).
4. (Optional interim, NOT the goal) the framework-extra.jar graft at
   `/accounts/1000/shared/misc/android/framework-extra.jar` stays available if we ever want a
   stopgap while the port layer is being RE'd.

## REFERENCES
- SwiftShader: khronos "SwiftShader reference implementation and fallback" (ARM 32/64 dEQP VK
  conformant); googlesource README (Vulkan 1.3, ANGLE for GLES3.1 "SwANGLE"); Apache-2.0.
- Godot renderer options (GLES2 fallback / compatibility); Unity Android requirements (GLES2 in
  Auto graphics API).
- `~/android-mine/SELECTION.report`, `~/android-mine/selection.txt`, `~/android-mine/fw43_*`.
- Passport Lineage zip on device: `~/Downloads/lineage-18.1-20250101-UNOFFICIAL-wseries.zip`.