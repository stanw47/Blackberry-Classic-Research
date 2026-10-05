# Session 27 - What the Android runtime .bar actually DOES (binary-level internals)

Device: PRD-64100 Classic, OS 10.3.3 (post-re-flash baseline), rooted userland,
QNX root via `/base/bin/__root`. Date: 2026-09-13.

## Context / user directive

Before modifying the runtime container further, the user asked: do we really know
what the `sys.android` `.bar` does, IN DEPTH? This session pulled the three QNX-side
bridge binaries out of the live container and dissected them (strings + imports),
so the answer is grounded in the actual artifacts, not guesses.

Note: the container files were pulled via QNX root (SFTP as `devuser` is blocked on
`sbin/*`; root copy to `/accounts/1000/shared/misc/android/` then SFTP pull works).

## The .bar at a glance (what "the Android runtime bar" IS)

- Package: `sys.android` (10.3.3.213), BAR id `gYABgKAOw1czN6neiAT72SGO-ns`.
- It is a **QNX-native app container** (not a chroot-of-linux): OS installs it as
  `/apps/sys.android.gYABgKAOw1czN6neiAT72SGO.ns/`, and everything the Android VM
  sees (`/system`, `/data`, `/mnt/sdcard`, PPS bridge channels) is produced by the
  three binaries below.
- Entry point (from the bar manifest): `sbin/android_launcher` (QNX ELF).

## 1. `sbin/android_launcher` (QNX ELF, 18056 B, stripped) - the entry/orchestrator

Strings show it is the process QNX execs at launch. What it does:

- Sets `ANDROID_PLAYER_HOME=/apps/sys.android.<ns>/native` and `ANDROID_DATA=/data`.
- **Pins the whole VM to CPU 0** ("restricting android to CPU 0").
- **Forks four helpers** and waits on each, in order:
  1. **PPS state initializer** -> publishes `/pps/services/android/status`
     with `state::initializing` (visible live: `[n]state::running`, plus
     `fullscreen:b:false`, `mobile::CONNECTED`, `mode::daemon`, `wakelock:b:false`).
  2. **android_fsys cleaner** (first-run `/data` init) followed-by/test for the
     `.migrate_complete` marker under
     `/accounts/1000/appdata/sys.android.<ns>/data/apdata/.migrate_complete`.
  3. **android process killer** (stale-process sweep on relaunch).
  4. **daemon launcher script** -> runs
     `native/scripts/restart-android-core-wrapper.sh`.
- Teaches the child an embedded `BOOTCLASSPATH` (the short 8-jar list:
  core, bouncycastle, ext, framework, android.policy, services, core-junit)
  and `LD_LIBRARY_PATH=/system/lib:...:/system/native/lib`.
- Then `exec init` -> the Android `init` binary from `system/bin/` (from init.cfg).
- On shutdown path: `slay -fQ binder servicemanager bootanimation android_resmgr`
  then `slay -fQ init app_process`; also `pathmgr_unlink()` of `/data`.

So `android_launcher` = the QNX-side gate: PPS-ready handshake, CPU pin, process
sweep, script hand-off, then hands control to Android init.

## 2. `system/bin/android_resmgr` (QNX ELF, 39408 B) - the container root / VFS

This is the process that makes the Android `/system` and `/data` appear:

- Is a QNX resource manager (`resmgr_attach`, `resmgr_msgread`, `iofunc_*`).
- **Owns the mounts** (strings = actual fstab-style entries it applies):
  - `/dev/android/system /system ext4 ro,relatime,user_xattr,barrier=1`
  - `/dev/android/data /data ext4 rw,nosuid,nodev,noatime,...,noauto_da_alloc,discard`
  - `/dev/android/sd /mnt/sdcard fuse rw,...,user_id=1023,group_id=1023`
  - `/dev/android/extsd /mnt/sdcard/external_sd fuse rw,...`
- Translates QNX<->Android UIDs (`qnx_uid_to_android`), consults
  `/proc/mounts`, `getAndroidPlayerGid`, `retainAndroidResmgrSystemCapabilities`.
- Fakes the kernel banner: "Linux version 3.2.41-QNX (android-player@blackberry.com)
  (gcc 4.6.3) #1 SMP Thu Oct 10 10:10:10 EST 2013" (i.e. the Android VM is told it is
  Linux 3.2.41 even though real kernel is QNX).
- CPU hotplug/thermal stats exposed via `/sys/devices/system/cpu/*`.
- PPS link to `/pps/services/carriermanager/config_status`.

So `android_resmgr` = the Qtty/resmgr that provides the container's virtual devices,
fs mounts and the /system + /data bindings.

## 3. `system/bin/shrimp` (QNX ELF, 71808 B) - the QNX<->Android IPC/bridge daemon

Source paths visible in strings: `device/rim/common/system/shrimp/{main,appmanager,
navigatorpolltask,pollmanager,pushclient,shrimppolltask}.cpp`.

- Bridges **two PPS namespaces**:
  - `/pps/services/android/shrimp` (QNX-side channel for Android<->QNX messages;
    live file exists, mode `-rw-rw---- android_system`).
  - `/pps/system/navigator/control` (QNX navigator).
- `ShrimpPollTask` -> listens for PPS msgs from the Android side, forwards to QNX.
- `NavigatorPollTask` -> watches navigator/control, forwards into Android.
- `AppManager` backed by a sqlite db:
  `/accounts/1000/appdata/sys.android.<ns>/data/apdata/system/qnx/shrimp.sqlite`
  (with `shrimp.pid`). Handles app "count" / message / invocation registrations,
  push-client sessions (`PushClient::startService/createSession` ...).
- PID/bookkeeping for the android process set; startup timeout
  ("Android file system not ready or Android failed to launch").

So `shrimp` = the message bus that lets QNX launch Android apps and Android report
state/counts back into the BB10 navigator registry.

## 4. What this means for the container edit lanes (COMPAT-relevant)

- The real `/system` you see inside Android comes from the container's own
  `native/system` tree, bound ro by `android_resmgr`. Outright replacement =
  replacing files under `native/system/*` while the runtime is DOWN (the ro bind
  is then authoritative on next launch). Same conclusion as before, now proven.
- `init.cfg` at `native/` is consumed by the forked `init` after android_launcher's
  exec -> our BOOTCLASSPATH graft point is the true boot path.
- `/data` is a sealed ext4 rw bind owned by the VM -> dalvik-cache can only be
  re-authored by the VM's own PM (matches session23's rule).
- `shrimp`/`PPS` channels are the only way an app appears/launches on the BB10 side
  -> consistent with the OFFICIAL install lane (session22) being the only lane that
  produces grid entries.

## 5. Artifacts pulled this session

| File | Host path | md5 |
|---|---|---|
| `sbin/android_launcher` | `/tmp/opencode/bar_sbin_android_launcher` | (see buildid df2ffc35...) |
| `system/bin/android_resmgr` | `/tmp/opencode/bar_system_bin_android_resmgr` | buildid bbcbdb3e... |
| `system/bin/shrimp` | `/tmp/opencode/bar_system_bin_shrimp` | buildid d1c042b8... |

(Also captured: `appdetails/applications` dump at `/tmp/opencode/appdetails_dump.txt`,
registry dump at `/tmp/opencode/reg_dump.txt`, live `/pps/services/android/status`
state, `packages.list` at `/tmp/opencode/pkgslist.txt`.)

## Status
- Done: binary-level understanding of the .bar's three QNX processes, grounded in
  pulled artifacts.
- Optional next: byte-level disassembly (objdump) of the three binaries if ever
  needed for the replacement lane.
- Standing reminder: the current device state is POST-RE-FLASH -> only factory
  Android apps remain (see separate APK->drawer flow doc).