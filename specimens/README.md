# Classic Android runtime specimens (persisted)

Source device: PRD-64100 BlackBerry Classic, OS 10.3.3, rooted userland.
Pulled via `__root` cat-bridge (devroot.py/pull.py) over SSH, byte-exact.
Persisted 2026-09-13. Verify with `sha256sum -c MANIFEST.sha256`.

These are the RIM Android 4.3 runtime C-specimens. All are QNX-native
ARM ELF executables/shared objects (interpreter `/usr/lib/ldqnx.so.2`,
NEEDED QNX libc.so.3 etc.) that re-implement the Android userland.

## Grouping

- libbionic.so — bionic -> QNX bridge (the core interposer, 85244 B)
- binder — QNX resource manager implementing /dev/binder (userland)
- libbinder.so — bionic-linked Android binder library
- liblog.so, libdl.so — Android log/dl interposers over QNX (slog2?/ldqnx)
- libgralloc_screen.so, libframebuffer_screen.so, libhwcwindow.so,
  libEGL.so, libGLESv1_CM.so, libGLESv2.so, libGLES_android.so,
  gralloc.Adreno.so, gralloc.SGX.so, gralloc.default.so,
  hwcomposer.default.so — graphics/EGL stack bridge to QNX libscreen+libimg
- libandroid_runtime.so, libandroidloader.so — JNI/loader glue
- libsurfaceflinger.so, surfaceflinger — SF QNX-linked
- app_process, linker, servicemanager, mediaserver, android_resmgr,
  android_launcher, shrimp, epolld, adbd — runtime daemons/binaries
- sensors.default.so — sensor HAL -> QNX libpps.so.1
- camera.default.so — camera HAL -> QNX libcamapi.so.1 + libcsm.so.1
- audio.primary.default.so — audio HAL -> QNX libasound.so.2 + libaudio_manager.so.1
- init.cfg — the Android service/zygote config for the runtime
- qnx_libc.so.3, qnx_libpps.so.1, qnx_libscreen.so.1 — reference QNX
  libs (from /proc/boot/libc.so.3, /proc/boot/libpps.so.1,
  /usr/lib/libscreen.so.1) needed for symbol-matching during RE

## 0-byte device paths (symlink placeholders on device, NOT re-pulled)

Pulled names that were 0 bytes on-device (still on device but not copied
— dead symlinks / wrong path guesses; the real QNX libs were found at
/proc/boot and /usr/lib as noted above):

- lbsexec_android  (was a symlink target that didn't resolve)
- libc.so          (real QNX libc is /proc/boot/libc.so.3 = qnx_libc.so.3 here)
- libpps.so        (real QNX libpps is /proc/boot/libpps.so.1 = qnx_libpps.so.1)
- libscreen.so     (real QNX libscreen is /usr/lib/libscreen.so.1 = qnx_libscreen.so.1)

To re-pull any of these later, use the __root cat-bridge with the correct
absolute path on device (not the runtime's /system/lib/... rootfs path).