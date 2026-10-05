# ANDROID RUNTIME COMPLETE MAP (BB10 Classic "Player" 4.3)

> Companion to `session26`. Standalone reference: how the packaged Android
> runtime on the Classic is laid out, what each component does, how it starts,
> where its data lives, and where the COMPAT graft points are. Gathered live on
> device 2026-09-12 (OS 10.3.3.3216, rooted userland).
>
> Container app ID: `sys.android.gYABgKAOw1czN6neiAT72SGO.ns`
> (stable across CFMs; the `.gYABgKAOw1czN6neiAT72SGO` is the "DUO"/GUID salt).

---

## 1. Identity & version

| Item | Value |
|---|---|
| Runtime package version | `10.3.3.213` (`native/version.txt` = `version:sys.android=10.3.3.213`) |
| Android release id | `10.3.3.213` (ro.build.id) |
| Android SDK | **18** (`ro.build.version.sdk=18`) |
| Android release | **4.3** (`ro.build.version.release=4.3`, codename `REL`) |
| Player build | `player-2.0.0_dev.eng.SER`, `full_playbook-user 4.3`, date 2016-04-25 |
| Type | `user` / `release-keys` |
| ABI | `armeabi-v7a` (+ `armeabi` ABI2) |

Both `init.cfg` and the native container come from the 10.3.3.3216 (build .213)
reflash baseline.

---

## 2. Container root (the "chroot" root of the Android VM)

QNX path: `/apps/sys.android.gYABgKAOw1czN6neiAT72SGO.ns/native/`

| Entry | Type | Function |
|---|---|---|
| `autolaunch.cfg` | cfg | Bootstrap autolaunch config (empty in baseline) |
| `blackberry-tablet.xml` | xml | App/container metadata for the QNX app registry |
| `default.cfg` | cfg | Default launch cfg |
| `icon.png` / `splash-*.png` / `splash-*.jpg` | asset | Container icon + boot splash renders |
| `images/` | dir | Splash/rotation assets buckets (`bucket_8/9/10/12`), `virtualkeys-*.png` |
| `init.cfg` | cfg | **ANDROID init.rc equivalent** (env, services, properties) - see §6 |
| `sbin/` | dir | `adbd` + `android_launcher` (Android daemons BB uses) |
| `scripts/` | dir | QNX-side lifecycle scripts (see §7) |
| `system/` | dir | The runtime's `/system` (see §3) |
| `version.txt` | txt | Runtime version string |

Note the container is a **full chroot**: when the player runs, `/system`,
`/data`, `/apps`, etc. are populated at QNX root from inside this tree
(via the QNX `chroot`/`exec` of `system/bin/init`). That is why the QNX-root
`/system` symlink is materialized (see lifecycle).

---

## 3. The `/system` tree

Path: `/apps/.../native/system/`

Subtree summary:

| Dir | Contents |
|---|---|
| `app/` | System apps: APK + preoptimized `.odex`, matched pairs |
| `bin/` | Native daemons/tools (`init`, `app_process`, `zygote`, `adb`, ...) |
| `build.cfg` | **build.prop source** (symlinked as `build.prop`) |
| `etc/` | Configs, `permissions/`, `security/`, `ppp/` |
| `fonts/` | Fonts |
| `framework/` | Framework jars + **framework .odex** (sealed, preopted) |
| `lib/` | `.so` shared libraries (runtime, media, graphics, ...) |
| `media/` | Audio (alarms/notifications/ringtones/ui) |
| `native/lib/` | Bionic/ARM libc-family for this fork |
| `tts/` | Pico TTS language data |
| `usr/` | ICU data, input device configs, keymaps |
| `xbin/btool` | **the autoroot btool** (patched, line 31 adds __root trust) |

---

### 3.1 `system/app/` — system applications (each APK+odex pair)

All are standard AOSP 4.3 system apps, preoptimized (odex next to APK).
Sizes listed as `apk / odex` bytes.

| APK | apk/odex (B) | Function |
|---|---|---|
| `ApplicationsProvider` | 17253/24664 | Core ContentProvider: `com.android.providers.applications`, apps DB for launcher widgets |
| `BackupRestoreConfirmation` | 104525/9536 | Post-setup "restore app data?" UI |
| `BasicDreams` | 23910/16368 | Daydream screensaver (part of launcher's built-in dreams) |
| `BlackBerryIME` | 237504/47776 | BB-branded soft keyboard IME |
| `Bluetooth` | 568537/652688 | AOSP Bluetooth app/profile management |
| `Browser` | 1908111/930048 | AOSP web browser |
| `Calculator` | 157614/362128 | AOSP calculator |
| `CalendarProvider` | 68250/388768 | Calendar data provider |
| `CertInstaller` | 116765/41920 | Certificate install UI |
| `Contacts` | 1530214/1432696 | AOSP contacts |
| `ContactsProvider` | 87749/724112 | Contacts DB provider |
| `DefaultContainerService` | 8825/20432 | Package installer service (install containment) |
| `Development` | 60103/147648 | Dev options UI |
| `DownloadProvider` | 174105/319904 | Download manager provider |
| `DownloadProviderUi` | 156841/40528 | Download UI |
| `DrmProvider` | 24473/12912 | DRM content provider |
| `FusedLocation` | 3849/12440 | Fused location provider |
| `GSF` | 6242/4392 | (Google Services Framework stub) |
| `Galaxy4` | 251957/21544 | Live wallpaper |
| `Gallery2` | 3160571/2463240 | Gallery/camera viewer |
| `HTMLViewer` | 8497/6928 | HTML file viewer |
| `HoloSpiralWallpaper` | 40079/22792 | Live wallpaper |
| `InAppBilling` | 6498/24944 | (billing stub) |
| `InputDevices` | 49390/1488 | Input device discovery telemetry (mostly no-op) |
| `KeyChain` | 47928/29512 | Keystore UI |
| `LiveWallpapers` | 1137595/81816 | Live wallpaper service |
| `LiveWallpapersPicker` | 161718/24320 | Wallpaper picker UI |
| `MagicSmokeWallpapers` | 210350/31208 | Live wallpaper |
| `MarketIntent` | 34229/4080 | Intent bridge toward market |
| `MusicFX` | 57906/86664 | Audio equalizer UI |
| `NativeBBM` | 173433/2368 | **BB custom**: BBM Hub/index bridge APK (front-end to BBM Services) |
| `NativeBrowser` | 177980/2704 | **BB custom**: Browser integration index APK |
| `NativeCalendar` | 190562/6144 | **BB custom**: Calendar integration index APK |
| `NativeCamera` | 169165/15280 | **BB custom**: Camera integration index APK |
| `NativeCellular` | 1516570/47976 | **BB custom**: Cellular/network settings integration index APK |
| `NativeContactPicker` | 173271/3536 | **BB custom**: contact picker bridge |
| `NativeEmail` | 176015/10944 | **BB custom**: Email integration index APK |
| `NativeFileViewer` | 204741/14576 | **BB custom**: file viewer bridge |
| `NativePhone` | 175786/4280 | **BB custom**: phone integration index APK |
| `NativeSmsMms` | 172053/9224 | **BB custom**: SMS/MMS integration index APK |
| `NativeSpeech` | 43814/6472 | **BB custom**: speech bridge |
| `NoiseField` | 65025/23304 | Live wallpaper |
| `OneTimeInitializer` | 2819/6424 | One-time policy init |
| `PackageInstaller` | 419031/140600 | APK install UI |
| `PhaseBeam` | 61340/22840 | Live wallpaper |
| `PhotoTable` | 425413/90864 | Photo screensaver |
| `PicoTts` | 10304/18312 | Pico TTS app |
| `Provision.odex` | (odex only) | Setup provisioning provider |
| `QNXAppLauncher` | 1553738/17744 | **BB custom**: Android Home/launcher that talks to QNX navigator/registry; "AndroidViewer" front |
| `QNXInvokeProxy` | 7674/5056 | **BB custom**: receives QNX invoke/mime and forwards to Android activities |
| `QNXLocationService` | 58127/16024 | **BB custom**: bridges QNX location to Android GPS/network provider |
| `QNXMediaProvider` | 21545/288768 | **BB custom**: Android MediaProvider over QNX media services |
| `QuickSearchBox` | 261063/504456 | Global search |
| `Settings` | 7231485/1341584 | AOSP settings |
| `SettingsProvider` | 20887/80952 | Settings DB provider |
| `SharedStorageBackup` | 2766/9088 | Backup agent |
| `Shell` | 7406/18800 | Dev shell (binder client; "adb shell") |
| `SoundRecorder` | 75576/25344 | Sound recorder |
| `SystemUI` | 1559845/533776 | Status bar/notifications UI |
| `TelephonyProvider` | 49259/103744 | Telephony DB provider |
| `UserDictionaryProvider` | 3629/15544 | User dictionary provider |
| `VideoEditor` | 4725684/390904 | Video editor |
| `VisualizationWallpapers` | 168557/38128 | Visualization wallpaper |
| `VpnDialogs` | 45334/9344 | VPN confirm dialogs |
| `WAPPushManager` | 2745/9704 | WAP push manager |

**KEY**: every app has a prebuilt `.odex` in `/system/app`. That means the
current runtime runs **fully pre-opted** system apps; `/data/dalvik-cache`
only holds odex for apps installed into `/data` (`com.amazon.venezia` after
reflash). This is why "drop an APK into /system/app and let PM rescan"
triggers dalvik-cache only if the APK is new/different.

---

### 3.2 `system/bin/` — native daemons & tools

| Binary | Function |
|---|---|
| `abcc` | Ahead-of-time bytecode compiler (Dex->odex tool) |
| `am` | Activity Manager CLI |
| `android_resmgr` | **QNX resource manager** for the container (memory/kernel hooks) |
| `app_process` | Zygote host binary (spawns `zygote`) |
| `binder` | QNX Binder resource manager (creates `/dev/binder`) |
| `bmgr` | Backup manager CLI |
| `bootanimation` | Boot animation render |
| `bu` | Backup CLI |
| `bugreport` | Bug report tool |
| `cat/chmod/chown/cmp/ln/log/ls/sleep/start/stop` | Toolbox-lite coreutils (QNX-provided or AOSP toolbox) |
| `content` | ContentResolver CLI |
| `dalvikvm` | Dalvik VM entry |
| `dexopt` | DEX optimizer (used by `installd`) |
| `drmserver` | DRM service daemon |
| `dumpstate` | State dumper |
| `dumpsys` | Service dump CLI |
| `epolld` | **QNX epoll shim daemon** (provides `/dev/android/epoll`) |
| `exe_shim` | **QNX**: exec/child-process shim for Android procs |
| `getprop` | Property get |
| `gzip` | gzip tool |
| `ime` | Input manager CLI |
| `init` | **Android init** (reads init.cfg) — process 1 of the chroot |
| `input` | Input CLI |
| `installd` | Package install daemon (socket installd) |
| `keystore` | Keystore daemon |
| `linker` | Dynamic linker (of this fork) |
| `linker_helper` | Linker shim (fork) |
| `logcat` | Log read CLI |
| `logd` | Log daemon (provides `/dev/log/main`) |
| `lowmemorykiller` | OOM killer (writes `/dev/android/lowmemorykiller`) |
| `logwrapper` | Log wrapper |
| `media` | Media CLI |
| `mediaserver` | Media services daemon (audio/video/camera) |
| `pm` | Package manager CLI (shell wrapper) |
| `settings` | Settings CLI |
| `sh` | mksh shell |
| `shrimp` | **QNX**: Android/QNX shim/registry (auth token, app metadata) |
| `surfaceflinger` | Surface compositor |
| `svc` | Service control CLI |
| `system_server` | Framework system server (fork of zygote) |
| `toolbox` | AOSP toolbox |
| `uiautomator` | UI test tool |
| `wm` | Window manager CLI |

`dexopt`, `abcc`, `dalvikvm`, `linker`, `libdvm.so` — these confirm **Dalvik**
(not ART) on this fork.

---

### 3.3 `system/framework/` — sealed framework

Every framework jar has a `.jar` (usually a 313-byte stub) plus a
**prebuilt .odex** with the real bytecode.

| Jar | odex (B) | Function |
|---|---|---|
| `core` | 3566248 | Core libs (java.*, dalvik, libcore) |
| `core-junit` | 27576 | JUnit |
| `bouncycastle` | 1099216 | Crypto provider |
| `ext` | 1510336 | Extensions (javax/crypto, javax/net, etc.) |
| `framework` | 11098392 | Android framework (android.*, services UI, etc.) |
| `telephony-common` | 1278048 | Telephony framework |
| `voip-common` | 171680 | VoIP framework |
| `mms-common` | 130440 | MMS framework |
| `android.policy` | 562984 | Policy framework (lock/keyguard layout) |
| `services` | 3463104 | System server services |
| `apache-xml` | 1378680 | Apache XML parser |
| `OSMgmaps` | 280344 | Map code |
| `am/bmgr/bu/content/ime/input/media_cmd/monkey/pm/requestsync/settings/svc/wm/uiautomator/javax.obex/...` | small | CLI/helper jars |

Extra jars in this fork: `OSMgmaps`, `com.android.location.provider`,
`android.test.runner`, `uiautomator`, `javax.obex`, `telephony-common`.
No `framework2`/`framework-res` extension jars present; `framework-res.apk`
(resources, 9.75 MB) is in-framework.

**GRAFT POINT**: this directory is root-writable and is where a PAL jar
(`compat.jar`) would be placed. See §8.

---

### 3.4 `system/lib/` — shared libraries (selected)

| Lib | Function |
|---|---|
| `libandroid_runtime.so` 790264 | Android runtime native (JNI bridge) |
| `libandroid_servers.so` | System server native |
| `libdvm.so` 941764 | **Dalvik VM** |
| `libjavacore.so`, `libnativehelper.so`, `libc.so`(native/lib) | Java core/bionic |
| `libbinder.so`, `libandroidfw.so`, `libgui.so` | Binder, asset framework, graphics |
| `libcutils.so`, `libutils.so`, `liblog.so`, `libcorkscrew.so` | Utilities |
| `libstagefright*` | Media framework |
| `libskia.so` 2188732 | Graphics/canvas |
| `libhwui.so` | HW-accelerated UI |
| `libandroidloader.so`, `libchost*.so` | **QNX fork**: android loader shim |
| `libframebuffer_screen.so`, `libgralloc_screen.so`, `libhwcwindow.so` | QNX graphics bridge |
| `libqnxlocationservice.so` | QNX location bridge |
| `libjni_BlackBerryIME.so` | BB IME native |
| `libemoji.so`, `libharfbuzz*` | Text shaping |
| `libsqlite.so` | SQLite |
| `libcrypto/ssl` | OpenSSL |
| `libselinux.so` | SELinux lib |
| `libsmartdl.so` | QNX smart dynamic loading |
| `libbluetooth_jni.so`, `libhardware_so`, hardware HALs | Bluetooth + HALs |

Plus `lib/egl` (`libGLES_android.so`), `lib/hw` HALs
(`gralloc.*.so`, `sensors.default.so`, `audio.primary.default.so`,
`camera.default.so`, `bluetooth.default.so`, `gps.default.so`,
`hwcomposer.default.so`, `keystore.default.so`), `lib/drm`
(`libfwdlockengine.so`). `/system/native/lib/` = bionic libc-family
(`libc.so`, `libm.so`, `libdl.so`, `libstdc++.so`, `libstlport.so`,
`libthread_db.so`).

---

### 3.5 `system/etc/`

- `permissions/*.xml` — feature/permission grants (incl. `platform.xml`,
  `handheld_core_hardware.xml`, BT/NFC/camera/touch, etc.)
- `security/cacerts` (CA bundle), `mac_permissions.xml` (SE policies), `otacerts.zip`
- `ppp/ip-up-vpn`
- `updatecmds`, `apns-conf.xml`, `media_codecs.xml`, `media_profiles.xml`,
  `audio_effects.conf`, `event-log-tags`, `fallback_fonts.xml`, `system_fonts.xml`,
  `hosts`, `NOTICE.html.gz`, `mkshrc`

### 3.6 `system/usr/` (input/keymaps/data)

- `icu/icudt50l.dat` (11.6 MB, ICU data for this Dalvik)
- `idc/` (`qwerty.idc`, `qwerty2.idc`)
- `keychars/` (`Generic`, `Virtual`, `qwerty`, `qwerty2`, `BlackBerry.kcm`)
- `keylayout/` (`Generic.kl`, `BlackBerry.kl`, vendor.kl, `AVRCP.kl` ...)
- `share/` (key charset deps/zone tables)

### 3.7 `system/tts/` + `system/media/`

- `tts/lang_pico/*.bin` — built-in TTS voices (en-US, en-GB, de, es, fr, it)
- `media/audio/{alarms,notifications,ringtones,ui}` — tone packs (incl.
  `Ring_Synth_04.ogg`, `pixiedust.ogg`, `Alarm_Classic.ogg` referenced from
  build.cfg)

---

## 4. `/system/build.cfg` = build.prop source

Symlink: `system/build.prop -> .../system/build.cfg`.

Key props (full file captured this session):

```
ro.build.id=10.3.3.213
ro.build.version.sdk=18
ro.build.version.release=4.3
ro.build.date=Mon Apr 25 07:23:03 UTC 2016
ro.product.cpu.abi=armeabi-v7a
dalvik.vm.dexopt-flags=m=y
dalvik.vm.stack-trace-file=/data/anr/traces.txt
keyguard.no_require_sim=true
ro.config.ringtone=Ring_Synth_04.ogg
...
```

SDK_INT is derived from `ro.build.version.sdk` in `SystemProperties` at
runtime — root-editable (see session25) — and this is a COMPAT lever.

---

## 5. Processes (live `pidin ar` snapshot, session)

```
13582551 android_resmgr          # container resource manager (QNX side)
13639904 shrimp                   # Android/QNX auth+registry bridge
13676749 zygote -Xzygote /system/bin --zygote --start-system-server
16195809 system_server            # framework server (spawned by zygote)
18210851 com.android.systemapps   # SystemUI/launcher VM process
18227434 /apps/.../native/sbin/adbd
20062451 com.android.phone
```

Plus support daemons under `init`'s control: `lowmemorykiller`, `binder`,
`epolld`, `logd`, `servicemanager`, `installd`, `mediaserver`, `drmserver`,
`surfaceflinger`.

Lifecycle notes (verified earlier, session22/desktop log):
- QNX `android_resmgr` is the container's `.*nresmgr`: starts `init` inside
  the chroot -> `app_process` zygote -> `system_server`.
- Kill `system_server` and the core dies (zygote, adbd, VM apps). Data persists.
- OS monitor auto-relaunches in ~2-4 min, or any Android grid tap cold-starts it.

---

## 6. `init.cfg` (Android init.rc equivalent) — boot-critical config

Full file was captured this session. Key elements:

### 6.1 Environment / BOOTCLASSPATH

```
export PATH /sbin:/system/sbin:/system/bin:/system/xbin
export ANDROID_ROOT /system
export ANDROID_DATA /data
export EXTERNAL_STORAGE /mnt/sdcard
export ASEC_MOUNTPOINT /mnt/sdcard
export BOOTCLASSPATH /system/framework/core.jar:core-junit.jar:bouncycastle.jar:ext.jar:framework.jar:telephony-common.jar:voip-common.jar:mms-common.jar:android.policy.jar:services.jar:apache-xml.jar
export DOWNLOAD_CACHE /data/cache
```

**GRAFT POINT #1**: append `:compat.jar` to BOOTCLASSPATH.

### 6.2 post-fs-data (mkdir/permissions)

Creates the whole `/data/*` structure (app, app-private, app-lib, app-asec,
dalvik-cache, resource-cache, misc, system/qnx/configs, local, ssh, logs...)
plus the sdcard share tree and the proc_symlinks
`/sdcard/{Music,Pictures,Movies,Download,...}`.

### 6.3 on boot (properties)

- Dalvik heap caps: heapgrowthlimit/heapsize low=128m/256m/high=384m,
  heapsizestart 8m, etc.
- `system_init.startsurfaceflinger 1`
- TCP buffer sizes, bootanim, lock cards hack, rotation anim
- `class_start core`, `class_start main`, `class_start late_start`

### 6.4 Services registered

| Service | Cmd | class | notes |
|---|---|---|---|
| `console` | `/system/bin/sh` | core | disabled unless debuggable |
| `adbd` | `/apps/.../native/sbin/adbd` | core | socket adbd; start on `persist.service.adb.enable=1` |
| `servicemanager` | `/system/bin/servicemanager` | core | critical; onrestart restart zygote/media/drm |
| `zygote` | `/system/bin/app_process -Xzygote /system/bin --zygote --start-system-server` | main | socket zygote |
| `drm` | `/system/bin/drmserver` | main | |
| `media` | `/system/bin/mediaserver` | main | group system audio camera inet net_bt ... |
| `bootanim` | `/system/bin/bootanimation` | main | disabled oneshot |
| `installd` | `/system/bin/installd` | main | socket installd |
| `keystore` | `/system/bin/keystore /data/misc/keystore` | main | |
| `dumpstate` | `/system/bin/dumpstate -s` | main | oneshot |
| `flashlog` | `logcat -f /data/log/flash.log ...` | main | on persist.qnx.flash.log.enable=1 |
| `dumplog` | `logcat -X -v brieftid` | main | |

The `service` block for zygote restarts `media` on zygote death — a normal
AOSP 4.3 init.cfg.

---

## 7. Container scripts (`native/scripts/`) — QNX-side lifecycle

| Script | Function |
|---|---|
| `start-android-core.sh` | Start Android core daemons (resmgr, binder, epolld, logd, lowmemorykiller, shrimp) + `waitfor` gates |
| `restart-android-core.sh` | If core died, `kill-android-core` then `start-android-core`; first-run touches `/tmp/android_core_started_by_player` |
| `kill-android-core.sh` | `slay init` + `kill -9` the VM procs |
| `stop-android.sh` | Graceful: write `shrink:-16` to lowmemorykiller (kills system_server) |
| `reboot-android.sh` | `shrink` + nav invoke (cold restart via launcher) |
| `launch-android.sh` | `msg::start_system` into `/pps/services/launcher/control` (start) |
| `launch-app.sh` | `msg::invoke dat::android://<pkg>` into `/pps/services/navigator/control` (launch Android app) |
| `clean-android-core.sh` | `kill-android-core` + `rm -rf` the whole appdata + shares + marker; **factory reset of Android runtime** |
| `kill-android-apps.sh` | Kill only app processes (leave core) |
| `restore-callback.sh` / `restore-cleanup.sh` | QNX app restore hooks |
| `ps-android-apps.sh` / `ps-android-core.sh` / `ls-oom-adj.sh` / `ap-startup-peak-mem-usage.sh` | Diagnostics |
| `capture-logs.py` | Log capture helper |
| `reboot-android.sh` | Reboot of Android runtime |

These are the hooks to stop/start the runtime without an OS reboot (the
"runtime lifecycle" lanes used by COMPAT).

---

## 8. Data layer — real Android `/data`

Real `/data` = `/accounts/1000/appdata/sys.android.<ns>/data/apdata`
(owned by the Android UID namespace `android_system`/`android_root`).
QNX side symlinks at appdata root: `app`, `config`, `db`, `pps`, `shared`.

`apdata/` contents (mirrors AOSP /data):

| Entry | Function |
|---|---|
| `app/` | Installed apps (post-flash: `com.amazon.venezia-1.apk`) |
| `app-lib/`, `app-private/`, `app-asec/` | App native libs / private apps / secure apps |
| `dalvik-cache/` | **odex cache for /data-installed apps** (venezia entry present) |
| `system/` | packages.xml/packages.list, permissions.db, appops.xml, locksettings.db, netstats, sync, dropbox, ifw, inputmethod, qnx_invoke_map.db + qnx/ |
| `system/qnx/` | shrimp.pid, shrimp.sqlite, configs/ — QNX/Android mapping (whitelist) |
| `data/`, `misc/`, `local/`, `property/`, `ssh/`, `user/`, `log/`, `dontpanic/`, `media/`, `mediadrm/`, `drm/`, `cache/`, `metadata/`, `security/`, `resource-cache/`, `install/`, `bugreports/` symlink | AOSP data dirs |

This is the sealed region: writes by outside-domain (QNX) are restricted;
dalvik-cache is only authored by the runtime's own PM (`installd`) on relaunch.

---

## 9. Graft points & access matrix (baseline, post-reflash)

| Object | Read | Write | Notes |
|---|---|---|---|
| `init.cfg` (container native/) | yes | yes | append BOOTCLASSPATH; rollback = backup + relaunch |
| `/system/framework/` dir | yes | yes | add `compat.jar` |
| `/system/app/` (install lane) | yes | yes | PM rescan on relaunch registers dexopts |
| `/system/build.cfg` (build.prop) | yes | yes (root) | SDK_INT lever (ro.build.version.sdk) |
| `/data/dalvik-cache` | yes | in-domain only | outside app_process aborts (session23) |
| `/mnt/sdcard` (QNX share) | yes | yes | pull/push lane |
| `native/sbin/adbd` + console | (adb offline by default on BB10) | — | dev-mode enables |

Rules (from session24-25 + runtime ops log):
- NEVER delete/replace the runtime's `/system` object while alive (breaks
  auto-relaunch).
- Framework jars are pre-opted; adding a NEW jar requires a warm dexopt by the
  runtime's own PM (its lane), then zygote relaunch.

---

## 10. Runtime version facts (for COMPAT version-matrix bookkeeping)

- SDK_INT=18, release 4.3 — read at runtime from build.cfg prop (root-editable).
- DEX version supported: dex 035 (Dalvik). Framework preopted (all odex).
- NO `java.util.stream`, NO `j$/` classes in framework (checked) — these are
  what the DesugarCollections/D8-jar graft must supply at the classpath level.
- Desugar gap: `java.lang.VerifyError: j$/util/DesugarCollections` — verified
  this pair on the fixed Telegram build (60589 build, 5-dex, all dex 035).

---

## 11. Sources / trust

- Live captures: `init.cfg` (full), `build.cfg` (full), `version.txt`,
  recursive `ls -laR` of container + /system, `pidin ar` snapshot, appdata/apdata
  listing, scripts directory listing, provisioning/permissions listings.
- Companion note: `session26-android-runtime-complete-map.md`.
- Prior verified procedures: `session22` install lane, `session23` dalvik-cache
  rule, `session24/25` BaseBundle+Desugar groundwork, desktop
  `COMPAT-STATUS-AND-RUNTIME-OPERATIONS.md` (runtime lifecycle).