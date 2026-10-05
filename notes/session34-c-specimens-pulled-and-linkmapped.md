# Session 34 - C-specimens hauled from device; bionic/screen/IPC link-maps confirmed

Device: PRD-64100 Classic, OS 10.3.3, rooted userland, QNX root via `/base/bin/__root`.
Date: 2026-09-13.  RSSI/cable: LAN 169.254.0.1.

## WHAT HAPPENED

Connected over SSH (ritual session7w, fresh 4096-bit key per session), used root pipe
`echo "cmd" | /base/bin/__root` to walk the live Android runtime container
`/apps/sys.android.gYABgKAOw1czN6neiAT72SGO.ns/native/` and pulled the full set of
C-specimens from the CLASSIC's own 4.3 runtime (not a gist, not a sim). All verified
byte-exact into `/tmp/opencode/spec/`.

## RUNTIME LAYOUT (on-device verified)

- Runtime container: `/apps/sys.android.gYABgKAOw1czN6neiAT72SGO.ns/` with
  `META-INF/` (`MANIFEST.MF` = 1084 packaged assets + SHA1s), `native/init.cfg`,
  `native/system/` (Android root), `native/sbin/` (adbd, etc.).
- Android system root = `native/system/`; library search path per init.cfg =
  `/system/lib:/proc/boot:/lib:/usr/lib:/lib/dll`.
- QNX libs live at `/proc/boot/libc.so.3`, `/proc/boot/libpps.so.1`,
  `/usr/lib/libscreen.so.1`.
- QNX ELF interpreter everywhere: `/usr/lib/ldqnx.so.2`.

## C-SPECIMENS PULLED (all in /tmp/opencode/spec/, ELF ARM EABI5 QNX, stripped)

| File | Size | Role / finding |
|---|---|---|
| `libbionic.so` | 85244 | **cArECORE.** 403 exported bionic symbols over QNX. NEEDED: libslog2, libc.so.3, libnbutil, libmmrndclient, libsocket.so.3, libstrm.so.1, libpps.so.1, libforensics, libm.so.2, libcpp-ne.so.4 |
| `binder` (bin) | 30440 | QNX binder driver/command. Interp ldqnx so.2 |
| `libbinder.so` | 196008 | Android binder library (QNX-linked) |
| `libgralloc_screen.so` | 13724 | Android gralloc HAL + gralloc.hal API -> QNX screen |
| `libframebuffer_screen.so` | 17928 | fb HAL -> QNX screen/fb |
| `libhwcwindow.so` | 13840 | SurfaceFlinger hw composer window -> QNX screen |
| `libsurfaceflinger.so` | 246272 | QNX-linked SF; links hwcwindow+EGL+hwc |
| `libandroid_runtime.so` | 790264 | JNI system server lib, QNX-linked |
| `libandroidloader.so` | 38936 | runtime loader boot reader |
| `servicemanager` | 9780 | QNX-linked Android service mgr |
| `app_process` | 13908 | QNX-linked zygote entry (interp ldqnx) |
| `linker` | 320088 | QNX-linked bionic linker (interp ldqnx) |
| `mediaserver` | 13888 | QNX-linked media server |
| `surfaceflinger` (bin) | 9644 | QNX-linked SF launcher stub (class 'main' disabled: started in-system per init.cfg `system_init.startsurfaceflinger 1`) |
| `android_resmgr` | 39408 | QNX resource manager (VFS+PPS) |
| `shrimp` | 71808 | QNX<->Android IPC bridge |
| `epolld` | 13808 | QNX epoll compat (interp ldqnx) |
| `adbd` | 78796 | adb daemon (path confirmed native/sbin/adbd) |
| `libdl.so` | 5316 | dlopen shim over QNX |
| `liblog.so` | 17916 | Android log -> slog2 |
| `init.cfg` | 27835 | full boot wiring read (see below) |
| `qnx_libc.so.3` | 598616 | QNX libc (the REAL libc underneath) |
| `qnx_libpps.so.1` | 29392 | QNX PPS (event/pubsub) |
| `qnx_libscreen.so.1` | 71588 | QNX screen graphics/compositor lib |

Empty (symlink/dead refs, resolved above): old `libc.so`, `libscreen.so`, `libpps.so`,
`lbsexec_android`, `libpps.so`, `libc.so`.

## KEY LINK-MAP FINDINGS (readelf -d)

1. **Everything is a QNX ELF** (interpreter `/usr/lib/ldqnx.so.2`) — the runtime processes
   are QNX binaries, not Android/Linux. `libandroid_runtime.so`, `libbinder.so`, etc. all
   link `libc.so.3` + `libcpp-ne.so.4` (+ `libm.so.2`).
2. **libbionic.so** provides the bionic API surface (403 GLOBAL exports incl. pthread_*,
   malloc, fopen, getenv, mmap, execvp, stat/fstat/lstat, setjmp, socket via libsocket)
   but is itself just a thin shim over QNX libc/llibs — confirms "bionic pointer swap",
   not an emulator.
3. **Screen/gralloc bridge**: `libgralloc_screen.so`, `libframebuffer_screen.so`,
   `libhwcwindow.so` all NEEDED: liblog, libcutils, libutils, libhardware,
   **libbionic**, libm_android, **libscreen.so.1**, **libimg.so.1**, libm, libcpp-ne,
   libc. So Android graphics HAL = QNX `screen_*` + QNX imaging (`libimg`).
4. **SurfaceFlinger** (lib): NEEDED libslog2, libcutils, liblog, libdl, libhardware,
   libutils, libEGL, libGLESv1_CM, libbinder, libui, libgui, libhwcwindow, libbionic,
   libm_android, libm, libcpp-ne, libc — uses QNX EGL + hwcwindow for the screen bridge.

## init.cfg KEY LINES (runtime boot wiring)

- `export LD_LIBRARY_PATH /system/lib:/proc/boot:/lib:/usr/lib:/lib/dll`
- `export BOOTCLASSPATH /system/framework/{core,core-junit,bouncycastle,ext,framework,
  telephony-common,voip-common,mms-common,android.policy,services,apache-xml}.jar`
- `service adbd /apps/.../native/sbin/adbd` (not /system/bin)
- `service servicemanager /system/bin/servicemanager` (class core, critical)
- `service zygote /system/bin/app_process -Xzygote /system/bin --zygote --start-system-server`
- `service media /system/bin/mediaserver`, `service drm /system/bin/drmserver`,
  `service installd`, `service keystore`, `service bootanim`, `service console`(sh).
- SurfaceFlinger NOT an init service: `setprop system_init.startsurfaceflinger 1`
- adbd gated on `persist.service.adb.enable`; flashlog logcat; HEAP props
  `dalvik.vm.heapsize 256m/384m high`.

## NEXT STEPS
- Disassemble `libbionic.so` fully (symbol-by-symbol bionic->QNX mapping) for workstream 1.
- Disassemble `binder` bin + `libbinder.so` for workstream 2 (ioctl_binder surface).
- Disassemble `libgralloc_screen/framebuffer_screen/hwcwindow` + QNX screen cross for wstream 3.
- Cross-map to A11 specimens already in /tmp/opencode/bacon_root/.