# Session 26 - Android runtime COMPLETE map | re-flash recovery checkpoint

Device: PRD-64100 Classic, OS 10.3.3, rooted userland (btool pathtrust), QNX root via
`/base/bin/__root`. Date: 2026-09-12.

## Context

This session comes after the re-flash (autoloader reflash) that:
- Deliberately broke the previous graft deadlock (graft had broken the Android
  container boot -> btool pathtrust not applied -> no root -> no rollback).
- Wiped the previous on-device graft (compat.jar, init.cfg edit), logs, and
  installed apps. Device returned to a CLEAN BASELINE stock state.

The session had two parts:
1. Re-establish root after re-flash (done in the session - see below).
2. USER DIRECTIVE: review the existing Android-OS notes AND then map out the
   ENTIRE Android runtime thoroughly - record functions in the notes AND in a
   separate document.

Deliverables of this session (both written):
- This note (chronological record).
- `/home/stanw47/Documents/blackberry-research/notes/ANDROID-RUNTIME-COMPLETE-MAP.md`
  (the standalone, self-contained runtime map with per-component functions).

## Part 1 - Root re-establishment after re-flash (btool line-31 patch)

### What the re-flash changed

- Restored the STOCK `getroot`-style btool, whose whitelist contains
  `launcher_patcher` + `mod_nvram` but **NOT** our line
  `/proc/boot/pathtrust !/base/bin/__root`. Without that line, `__root` is not
  trusted -> its setuid fails -> root is gone.

### Why offline patch works

- Re-flashed device still has the Android runtime container at
  `/apps/sys.android.gYABgKAOw1czN6neiAT72SGO.ns/native` (world-writable tree),
  including `/system/xbin/btool`. btool's ACL on its own file + the container's
  world-writable tree lets root's helper edit it.
- Verified btool is world-writable and its line 25 grants itself traversal ACL.
- So we replaced the on-device btool with the verified patched copy.

### Procedure

1. Connect (fresh `/tmp/bb_key` per session, `blackberry-connect` tunnel as
   documented in `/home/stanw47/bb-repo/docs/ssh-connection-linux.md`).
2. Locate btool: `/apps/sys.android.gYABgKAOw1czN6neiAT72SGO.ns/native/system/xbin/btool`
   (also reachable as `/base/scripts/ota_info_pps.sh` symlink -> that file).
3. Backed up stock btool to `/accounts/devuser/rootdata/btool.stock.bak`.
   Stock = 1893 B, md5 `324fa46189f68f40601c7eeb9ec41201`.
4. Wrote the host-side verified patched btool
   (`notes/session12-passport-root/classic/btool.patched`, 1932 B,
   md5 `3ee07f4a4969c1fc44d42fc188fd888c`) onto the device path.
5. Verified on device: file size 1932 B, line 31 present:
   `/proc/boot/pathtrust !/base/bin/__root`.
6. Rebooted the device, re-enabled Dev Mode, re-ran the SSH ritual.

### Verification (post-reboot)

- `/proc/boot/pathtrust -t /base/bin/__root` -> `trusted`
- `__root` returns `ROOT_OK` (real uid-0 shell)
- btool line 31 confirmed present on device
- `android_resmgr` + Android container running (system awake, VM up)

### Graft state after re-flash (IMPORTANT, for the record)

- The re-flash returned the device to **pristine baseline**:
  - NO `compat.jar` in `/system/framework`
  - NO `compat` entry in `init.cfg` BOOTCLASSPATH
  - NO `com.amazon.venezia`? -- actually Amazon venezia WAS present post-flash
    (installed via the clean image by the OS). Note below.
- Host-side graft artifacts all survive: `/home/stanw47/android-mine/certs/compat.ks`,
  `tg2/tg121pyx-fixed.apk`, pristine `device/init.cfg`, `/tmp/graft/`.
- The graft deadlock is RESOLVED (runtime is healthy baseline).

## Part 2 - Android runtime complete map (summary + pointer)

Per the user directive I ran a full live sweep (as QNX root) of:
- The whole container tree `/apps/sys.android.../native/` (system, scripts, sbin, images, etc.)
- The runtime "/system" hierarchy (`app/ bin/ etc/ fonts/ framework/ lib/ media/ native/ scripts/ sbin/ tts/ usr/ xbin/`)
- `init.cfg` (full capture), `build.cfg`, `version.txt`
- The Android process tree (live, `pidin ar`)
- The Android data layer (`/accounts/1000/appdata/<ns>/data/apdata`, dalvik-cache, packages, qnx configs)

### Key numbers

- Runtime version: `10.3.3.213` (`version.txt`), `ro.build.version.release=4.3`,
  `ro.build.version.sdk=18`, player `player-2.0.0_dev.eng.SER`, upstream date 2016-04-25.
- Android core is AOSP 4.3 with the QNX/Audience fork binaries (`android_resmgr`,
  `shrimp`, `epolld`, `exe_shim`, NBLA VMs).

### Filesystem feet (very abridged; full table in the standalone map doc)

```
/apps/sys.android.<ns>/native/
  init.cfg          # Android init.rc-equivalent (BOOTCLASSPATH, services, props)
  build.cfg         # build.prop source (sdk=18, release=4.3)
  version.txt       # version:sys.android=10.3.3.213
  scripts/          # QNX-side lifecycle scripts (start/stop/restart/clean core)
  sbin/             # adbd, android_launcher (QNX Android launcher helper)
  system/app/       # stock + 3rd-party system APKs + .odex
  system/bin/       # runtime daemons/tools (init, app_process, zygote, ...)
  system/etc/       # configs + permissions/*.xml + security/
  system/fonts/     # Droid/Roboto/Noto/digits
  system/framework/*.jar + .odex   # framework must be PREOPTED here
  system/lib/       # .so (android runtime, dalvik libdvm, stagefright, etc.)
  system/media/     # audio (alarms/notifications/ringtones/ui)
  system/native/lib/# bionic/arm libs used by ADROID fork
  system/tts/       # pico TTS data
  system/usr/       # icu, idc, keychars, keylayout, share
  system/xbin/btool # the autoroot btool (patched line 31)
  images/           # splash/rotation assets (bucket_8/9/10/12)
```

### Processes (live `pidin ar`)

- `android_resmgr` - Android resource manager (container lifecycle)
- `shrimp` - QNX <-> Android authentication/registry bridge
- `zygote` (app_process -Xzygote /system/bin --zygote --start-system-server)
- `system_server` (child of zygote)
- `com.android.systemapps` (AndroidViewer/system)
- `com.android.phone`
- `adbd` (from `/apps/.../native/sbin/adbd`)
- (plus `lowmemorykiller`, `binder`, `epolld`, `logd`, `installd`,
  `servicemanager`, `mediaserver`, `drmserver`, `surfaceflinger` as applicable)

### Data layer

- Real Android `/data` = `/accounts/1000/appdata/sys.android.<ns>/data/apdata`
- Layout mirrors AOSP /data: `app/`, `app-lib/`, `dalvik-cache/`, `system/`
  (packages.xml/list, permissions.db, qnx_invoke_map.db, ...), `misc/`,
  `data/`, `local/`, `property/`, `ssh/`, ...
- Post-flash: 1 installed app (`com.amazon.venezia`) present with its
  dalvik-cache entry; packages.xml/list live.

### Runtime lifecycle (verified earlier, kept here for the map)

- Cold start: OS monitor/product timer relaunches `android_resmgr` + core after
  a core kill; or anything Android from Home launches on demand.
- STOP: `kill -9 system_server` from QNX root -> core dies; data persists.
- HARD RULE: never delete/replace the runtime's `/system` object while alive
  (wedges auto-relaunch).

### Graft points identified (at this baseline)

- `init.cfg` BOOTCLASSPATH line (export BOOTCLASSPATH ...) - append compat.jar
- `/system/framework/compat.jar` location (framework dir is root-writable)
- warm dexopt requires the runtime to be up (its own PM dexopts in-domain)
- rollback = init.cfg backup restore + relaunch (never while alive)

## Artifacts

- This note
- `/home/stanw47/Documents/blackberry-research/notes/ANDROID-RUNTIME-COMPLETE-MAP.md` (deliverable)
- `/home/stanw47/Documents/blackberry-research/notes/session12-passport-root/classic/btool.patched` (1932 B, used to restore root)
- `/home/stanw47/Documents/blackberry-research/notes/session12-passport-root/classic/btool.original` (1893 B)

## Next actions

1. Baseline is clean and rooted. Re-run the install lane for the Telegram
   BaseBundle-fixed build (`tg2/tg121pyx-fixed.apk`).
2. Resume the runtime-graft plan (PAL compat.jar + DesugarCollections).
3. If needed, write note on any runtime behavior discovered during install/graft.