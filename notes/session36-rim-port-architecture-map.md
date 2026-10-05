# Session 36 - RIM port architecture: AOSP subsystem -> QNX mapping (recreate-me blueprint)

Device: PRD-64100 Classic, OS 10.3.3, rooted userland, QNX root via `/base/bin/__root`.
Date: 2026-09-13.
Reference userland of our own port: AOSP Android 11 (bacon rig evidence, /tmp/opencode/bacon_root/).

This is the DELIVERABLE of the session32 RE blueprint: how RIM ported Android 4.3 onto QNX,
proven from on-device binaries (all in /tmp/opencode/spec/, link/import maps + selected
disassembly). A fresh engineer can recreate the port from AOSP source following this map.

## 0. OVERALL MODEL (the one-line unlock)

Android processes on BB10 are **QNX-native ELF processes** (interpreter `/usr/lib/ldqnx.so.2`)
linked against **QNX libc.so.3** with `libbionic.so` (and `lib*_android.so` vendored libs)
interposed to provide the Android API surface. Every Android syscall/IPC/HAL endpoint is
re-pointed at a QNX primitive: binder->QNX resmgr+MsgSend, properties->PPS, log->slog2,
epoll/futex/eventfd->QNX IPC, graphics->QNX screen+img, sensors->PPS, audio->QNX ALSA,
camera->QNX camapi, GPS/radio->QNX services.

## 1. LIBC / BIONIC (cArECORE) — workstream 1 (done)

Specimen: `libbionic.so` (85KB, 403 exports / 144 QNX imports/263 unique imports).
- All of Android libc (pthread,_*stat,exec*,mmap,futex,property,epoll,eventfd,time*,signal)
  re-exported; internals delegate to QNX libc.so.3 + libm.so.2 + libsocket.so.3.
- NEEDED: libslog2, libc.so.3, libnbutil, libmmrndclient, libsocket.so.3, libstrm,
  libpps.so.1, libforensics, libm.so.2, libcpp-ne.so.4.
- QNX threading: imports SyncCondvar/SyncCondvarWait/SchedCtl/SchedGet/SchedSet/
  ThreadCtl_r/TimerTimeout. futex is 540B implemented over QNX condvar+wait.
- QNX IPC directly in libc surface: ChannelCreate/ConnectAttach/MsgSendv*/MsgReceivePulse/
  ConnectClientInfo/ConnectDetach. (Android has no such API; RIM exposed it via these.)
- QNX capability model per-daemon: `retain*SystemCapabilities` for binder, java,
  android_resmgr, system_server, media, init, bootanim, keystore, dexopt, lowmemorykiller,
  rild, system, minimal, adbd, epolld; plus `defineAppSandbox`, `setPermissions`,
  `dynamicUserCapabilities`, `checkAppCapabilities`.
- uid/gid mapping: `android_uid_to_qnx`, `qnx_gid_to_android`, `getAccountGid`,
  `getAndroidPlayerGid`, `getAppGidFromApkSymlink`, `getAppGidFromAppDataSymlink`,
  `getAccountPerimeterGid`, `injectAppGidIntoSupplementaryGroups` -> the Android app sandbox
  (uid 10000+n) is backed by QNX accounts/perimeters.
- properties: `__system_property_*` + `__system_properties_init` (PPS-backed).
- platform calls: `authman_send`, `procmgr_ability`, `sendQuipEvent`, `forensics_logworthy_async`.

## 2. BINDER / IPC — workstream 2 (done)

Specimen: `binder` (30KB QNX resmgr binary) + `libbionic.ioctl_binder` (532B) + `libbinder.so`.
- `/dev/binder` is a **QNX resource manager** (resmgr_attach/iofunc/dispatch_*);
  exports `binder_devctl`, `binder_transaction_log`, `binder_transaction_log_failed`.
- ioctl_binder dispatches BINDER_WRITE_READ (0xc0186201) and BINDER_VERSION (0xc108620c),
  calls QNX `ioctl` and `MsgSendv_r`. Payloads via shm (shm_open/shm_ctl + mmap_peer).
- QNX <-> Android side: xid/thread mapping, `retainBinderSystemCapabilities`.
- Conclusion: binder ABI preserved at Android API level; transport = QNX message passing +
  shared memory in userland. Recreate: a QNX resmgr exposing /dev/binder and a libbinder
  linked to QNX IPC.

## 3. GRAPHICS / SURFACEFLINGER — workstream 3 (done)

Specimens: `libsurfaceflinger.so`, `libgralloc_screen.so`, `libframebuffer_screen.so`,
`libhwcwindow.so`, `libEGL.so`, `libGLESv2.so`, `libGLESv1_CM.so`, `libGLES_android.so`,
`gralloc.*.so`, `egl.cfg`, QNX `libscreen.so.1`, `libimg.so.1`.
- SurfaceFlinger is a **QNX-linked service** (NEEDED libEGL, libGLESv1_CM, libbinder, libui,
  libgui, libhwcwindow, libslog2, libc...). Started by system_server (init.cfg:
  `setprop system_init.startsurfaceflinger 1`), class disabled from init service.
- Gralloc = `libgralloc_screen.so` (exports gralloc_alloc/free/register/unregister_screen_buffer,
  gralloc_garbage_collect) built on `screen_create_window*`, `screen_get_buffer_property_*`,
  `screen_set_window_property_iv`, shm_* (+ mem_offset64/mlock for the phys buffer).
- Framebuffer HAL = `libframebuffer_screen.so` (fb_device_open/lock/post, mapFrameBufferLocked)
  on `screen_post_window`, `screen_wait_vsync`, `screen_create_window_buffer`,
  `screen_get_display_property_*`, `img_load_resize_file` (splash).
- HWC = `libhwcwindow.so` (HWCWindow class: prepare(hwc_display_contents_1), commit(),
  makeInvisible, screenWindowCreated/Destroyed) -> QNX screen window property + flush.
- EGL/GLES2: `libEGL.so` (wraps libGLES_trace + dlopen'd driver), `libGLESv2/v1_CM` -> libEGL,
  `egl.cfg`: "0 0 android; 0 1 QNX" (impl 0 = software libGLES_android.so, impl 1 = QNX hw).
- gralloc.Adreno/SGX stubs -> libframebuffer_screen + libgralloc_screen + screen+img.
- Takeaway: swap QNX `screen_*`/`libimg`/EGL for whatever we ship; our A11 (HardwareModule
  gralloc3 + hwcomposer) must expose the same screen ops we already saw RIM's do, OR we ship
  SwiftShader + a framebuffer screen bridge as planned in session31.
- GLES2.0 ceiling: hardware GL = QNX EGL (Adreno through libscreen), software fallback =
  libGLES_android (GLES1 emulated); GLES3 libs in tree but eglish only GLES2.

## 4. PROCESS MODEL / INIT — from init.cfg (pulled)

- Android init is NOT Linux init; init.cfg is run by QNX init-equivalent. Parses
  `service <name> /system/bin/<bin>` -> forks QNX process via `/usr/lib/ldqnx.so.2`.
- service map: adbd (native/sbin/adbd), servicemanager, zygote = `/system/bin/app_process
  -Xzygote /system/bin --zygote --start-system-server`, media = mediaserver, drm, installd,
  keystore, bootanim, console(/system/bin/sh), flashlog (logcat), dumplog.
- env: LD_LIBRARY_PATH=/system/lib:/proc/boot:/lib:/usr/lib:/lib/dll;
  BOOTCLASSPATH = 4.3 framework (core,fw,services,...) ; ANDROID_ROOT=/system; ANDROID_DATA=/data.
- zygote on QNX: app_process forks child zygotes (still QNX procs). `class_start core/main`.
- NOTE for A11: replate BOOTCLASSPATH with A11 jars + zygote/api-level handoffs.

## 5. QNX RESOURCE MANAGERS / VFS

- `android_resmgr` (39KB): QNX resmgr providing the android VFS (/system,/data mount shim,
  PPS nodes, virtual /proc, /dev). Import class: resmgr_attach/msgread/iofunc/iofdinfo;
  QNX devctl + ionotify.
- `epolld` (13KB): userland epoll daemon shim for apps that assume epoll; classic app_launcher
  companion.
- `shrimp` (71KB): Android<->QNX bridge daemon (PPS channels, appmanager/navigatorpoll/
  pushclient polls, sqlite).

## 6. HAL -> QNX DEVICE SERVICES

- sensors.default -> QNX **libpps.so.1** (sensor events = PPS nodes) + libui + libbionic.
- camera.default -> QNX **libcamapi.so.1** + libcsm.so.1 + libexif.so.1 + libjpeg_android,
  libmedia/libui/libbinder (binder to cameraservice). (libcamera_config-*classic.so present.)
- audio.primary.default -> QNX **libasound.so.2** (ALSA-ish) + libaudio_manager.so.1.
- bluetooth.default -> QNX BT stack; nfc via libnfc.so.1 (runtime main container links it).
- gps.default -> QNX GNSS (via PPS/location services).
- power/keystore/local_time -> stubs over QNX.
- Key recreation task: map each A11 `android.hardware.*` HAL/`hal3` sensor→PPS schema,
  camera→camapi, audio→QNX asound, gps→PNP, BT/NFC as available.

## 7. A11-SPECIFIC GAPS to solve ourselves (lecture; this doc is the foundation)

The 4.3 port predates: HIDL/AIDL, Treble, SurfaceFlinger-hwc2, VNDK, APEX, ART-runtime
vs dalvik, per-app ld.config, scoped storage, zygote fork descriptor, mainline modules.
Our A11 port must recreate on the SAME skeleton: binder via the resmgr+MsgSendv pattern a
fresh libbinder for AIDL (binder 1.0 C ABI plus hwbinder), property system over PPS with
property_context + props for 11, ART (libart) on QNX (recompile JIT/GC on QNX pthreads),
hwcomposer2->QNX screen bridge, gralloc4->QNX buffer allocator, etc.

## 8. FILES
- /tmp/opencode/spec/ : all 42 pulled specimens (ELF QNX arm).
- notes/session34 (haul+linkmaps), session35 (binder/ioctl disasm), this doc.
- /tmp/opencode/bacon_root/ : A11 reference files (prev sessions).
- README roadmap: swap each AOSP 11 userland component onto the QNX skeleton above.

## NEXT ACTION
Choose first A11 component to wafer onto the skeleton (recommend: libbinder-with-AIDL over
the QNX resmgr pattern, or the property/PPS shim) and set up AOSP 11 tree build on this box.