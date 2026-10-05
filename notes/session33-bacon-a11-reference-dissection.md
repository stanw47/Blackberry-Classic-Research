# Session 33 - OnePlus One (bacon) LineageOS 18.1 = our Android 11 reference, fully extracted

Device: PRD-64100 Classic, OS 10.3.3, rooted userland, QNX root via `/base/bin/__root`.
Date: 2026-09-13.

## WHY BACON IS THE REFERENCE

- **armeabi-v7a, 32-bit ARM, SDK 30 (Android 11)** = exact ABI twin of the Classic's QNX runtime
  target. `ro.product.cpu.abilist=armeabi-v7a,armeabi` (32-bit only, no arm64).
- MSM8974AC (Snapdragon 801) = same SoC family as the Passport's qcom port (msm8974xxx HALs).
- Clean A11 userland to dissect: every subsystem we must recreate is present as a real file.
- User downloaded `lineage-18.1-20210106-UNOFFICIAL-Tom-bacon-signed.zip` (464 MB, 2021-01-06).

## EXTRACTION PIPELINE (memory-safe, watched the OOM this time)

1. `system.new.dat.br` 457 MB -> streaming brotli decompress (chunked `brotli.Decompressor`,
   8 MB chunks, peak RSS 133 MB) -> `system.new.dat` 1,071,357,952 B.
2. `sdat2img.py system.transfer.list system.new.dat system.img` -> 1,388,314,624 B ext4.
3. `debugfs -R "dump <src> <dst>"` per-file extraction (no mount needed, no root).
4. Layout is **system-as-root**: dirs live at `/system/*`, native libs under
   `/system/apex/<pkg>/` (flattened APEX), `/system/lib/libc.so` is a symlink to
   `/apex/com.android.runtime/lib/bionic/libc.so`.

Reference tree: `/home/stanw47/Downloads/lineage-18.1-20210106-UNOFFICIAL-Tom-bacon-signed/`
(system.img + boot.img + transfer list). Harvested dissection copies: `/tmp/opencode/bacon_root/`
(138 MB). NOTE: `/tmp/opencode` is scratch - move bacon_root somewhere persistent if we need it
long-term.

## HARVESTED REFERENCE FILES

| Area | Files (in /tmp/opencode/bacon_root/) | Purpose for the port |
|---|---|---|
| Framework jars | `framework/framework.jar` (27 MB), `framework-res.apk`, `services.jar` (16 MB) | Real A11 framework bytecode to port/compile against |
| ART runtime | `apex/art/{libart,libart-compiler,libart-dexlayout,libart-disassembler,libartbase,libartpalette,libbase,libdexfile,libdexfile_external}.so` + `apex/art/javalib/{core-oj,core-libart,core-icu4j,apache-xml,bouncycastle,okhttp}.jar` | The j$/java.util + desugar source ground-truth (our framework-extra graft source) |
| ART precompile | `boot-framework.vdex`, `boot-framework.oat` candidates | OAT/VDEX layout to understand what the runtime needs |
| Bionic | `system_apex/runtime/bionic/{libc,libdl,libm}.so` (libc=852 KB real A11 bionic) + `runtime/bin/linker` (1 MB) | The bionic libc we must re-point at QNX - the cArECORE specimen |
| Core native | `lib/{libbinder,libhwbinder,libbinder_ndk,libhwui,libandroid_runtime,libandroid,libandroid_servers,libandroidfw,libvulkan,libEGL,libGLESv2,libGLESv3,libmedia_jni,libjnigraphics,libaudioeffect_jni}.so` | The JNI+binder+UI stack we recreate the QNX crossings for |
| System UI | `system_ext/priv-app/SystemUI/SystemUI.apk` (25 MB) | A11 UI reference |
| Boot chain | `boot.img` kernel 5.76 MB + ramdisk, `/system/bin/{app_process32,installd,servicemanager,surfaceflinger,dalvikvm,dex2oat}`, `etc/init/{zygote,servicemanager,surfaceflinger,bootstat}.rc`, `etc/public.libraries.txt` | Process model + zygote spawn + boot config = session32 deliverable D |

## FULL HIDL HAL SURFACE CATALOG (from /system/lib)

40+ interface families, all present in this image (this is the session32 "HAL crossings" map):
graphics.{allocator@2/3/4, common@1/1.1/1.2, composer@2.1-2.4, mapper@2-4}, camera.{common,device@1-3.6,provider@2.4-2.6},
sensors@1-2.1, keymaster@3-4.1, wifi@1.0-1.4, audio@2-6, power@1.0-1.3, vibrator@1.0-1.3,
bluetooth@1.0-1.1, gnss@1.0-2.1, health@2.0-2.1, thermal@1, light@2, memtrack@1, nfc@1-1.2,
vulkan (libvulkan.so driver), plus radio@1.x, drm, cas, confirmationui, usb, vr, ir, tv.

Vendor impls in `/vendor/lib/hw`: gralloc.msm8974, hwcomposer.msm8974, camera.msm8974,
sensors.msm8974, audio.primary.msm8974, lights.msm8974, power.default, vibrator.default, gps.msm8974,
etc. -> these map to QNX services in the port.

## GLES / GRAPHICS CEILING (re-confirmed against real A11 image)

libGLESv3 present as a real 67 KB shim lib, libEGL 137 KB, libvulkan 119 KB, libhwui 6.2 MB.
Graphics HAL stack = allocator/mapper/composer HIDL -> hwcomposer.msm8974 -> (msm8974 gralloc).
Matches session31: Adreno 225 GLES2 ceiling + software/extension fallbacks only.

## NEXT STEPS IN THE PORT PIPELINE

1. (session32 workstream 1) Open `framework.jar`/`core-libart.jar` -> enumerate exact
   classes/services vs fw43 gap list (SELECTION.report 226 A15 / 32 A11 shims). Ground-truth the
   j$ src from core-oj.jar instead of binary-splicing.
2. Boot-chain: read `app_process32` + zygote.rc + servicemanager.rc -> document the A11 zygote
   spawn wiring vs the .bar init.cfg (session26/27 evidence).
3. Dissect real A11 `libc.so` (852 KB) against QNX libc.3/pips/screen imports (zhuowei gist) ->
   first concrete bionic->QNX symbol mapping.
4. Cross-walk the HIDL catalog above vs QNX services the .bar exposes -> produce the HAL
   compatibility matrix (which android.hardware.*_impl get QNX-side servings).

## STATUS

DONE: bacon ROM verified + fully extracted + dissection files harvested. System-as-root layout
understood. HIDL catalog enumerated. Boot image verified.
TODO: use the harvested pieces to drive session32 workstreams 1-4; AOSP 11 source build setup
still outstanding; device SSH lane still blocked.