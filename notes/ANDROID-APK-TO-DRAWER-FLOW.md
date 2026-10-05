# APK -> installed -> visible in the BB10 app drawer: the complete path

Device: PRD-64100 Classic, OS 10.3.3, android 10.3.3.213 runtime.
Status: POST-RE-FLASH baseline (only factory Android apps remain). Historical
evidence from pre-flash runs is labeled as such.

THE ANSWER (one screenful): an Android APK becomes visible on the BB10 Home grid
ONLY through the OFFICIAL install lane, because the BB10 grid is a renderer over
the native QNX app registry, and only the official installer writes an entry there.
The drop-lane (root copy into /system/app + PM rescan) installs the app inside the
Android runtime but NEVER shows it in the drawer.

## [0] The two install lanes - the one-line difference

| Lane | Driver | PM semantics | Grid icon? | Registry entry? | QNX caps? |
|---|---|---|---|---|---|
| OFFICIAL (Files tap) | BB10 installer (installhandlerui/QNXInstallerService) | install to /data/app/<pkg>-1.apk | YES | YES (pkgDN) | YES (authman dyncap) |
| DROP (root copy) | us + PM rescan | system app, codePath /system/app | NO | NO | NO |

## [1] OFFICIAL lane - PID to Home grid, step by step (verified pre-flash, session22)

1. User: Files app -> Downloads -> `x.apk` -> BB10 "Install this Android
   application?" prompt -> approve. REAL BB10 UX; a synthetic invoke fails
   (lacks the create-file token -> "Installation invoke failed").
2. QNX `installhandlerui` runs (euid 810 = android_system), NOT
   PackageInstaller's UI.
3. APK lands at runtime `/data/app/<pkg>-1.apk`. (If a copy was pre-dropped in
   /system/app, PM treats this as an in-place UPDATE: `UPDATED_SYSTEM_APP`,
   base stays /system/app, update on /data/app.)
4. **Registry grows by one line** in
   `/pps/system/installer/registeredapps/applications`:
   ```
   org.<android-pkg>.<36-char-guid>::andr<36-char-guid>,<ver>,,,<size>,source::apk,client::UI
   ```
   - pkgDN = `org.<pkg>.<guid>` - the identity the grid/QNX uses.
   - pk8Id = `andr<36-char-guid>`; tags `source::apk` + `client::UI`.
   - Format matches the factory Android apps the device remembers
     (skytube/chrome happened to be on the pre-flash unit; amazon mShop+venezia are on the current).
5. **QNX capabilities granted** (authman logs):
   ```
   authman: RX euid=810/egid=810,'dyncap org.<pkg>.<guid> access_shared allow_noneditable'
   authman: RX euid=810/egid=810,'dyncap org.<pkg>.<guid> run_when_backgrounded allow'
   ```
6. Home grid re-enumerates the registry -> icon appears in the app drawer.

Result verified: icon in drawer; `pm path` + `dumpsys package` confirm
`codePath=/data/app/<pkg>-1.apk`, `lastUpdateTime` matched the install moment.
(Evidence from 2026-09-11 run with org.fdroid.fdroid; apps were lost on re-flash
but the *mechanics* are device-independent and this doc's steps were re-verified
structurally today - see [3].)

## [2] DROP lane - installs inside Android, never reaches the drawer

1. Push APK to `/mnt/sdcard/...` == `/accounts/1000/shared/misc/android/...`.
2. QNX root: `cp` into `/apps/sys.android.<ns>/native/system/app/<pkg>.apk`, chmod 644.
3. `kill -9 <system_server_pid>` -> OS monitor relaunches runtime ~2-4 min; PM
   rescans /system/app, dexopts, assigns uid, runs receivers (verified: F-Droid
   StartupReceiver ran).
4. `am start` resolves; **but** registry last-touch unchanged, no grid icon, no caps.

Notable quirk (drop-then-official): the official install over a dropped copy still
lists BOTH codePaths (`/system/app` + `/data/app`) with `UPDATED_SYSTEM_APP` - it
upgraded in place rather than re-registering cleanly. Fine, but plan around it.

## [3] What the grid/registry actually is (CURRENT post-re-flash evidence)

Authoritative uint8ce: `/pps/system/installer/registeredapps/applications` -
READ-ONLY through the g_app_installer helper, NOT via plain root cat (PPS ACLs;
`user upd` uid 88 owns the installer namespace, mode bits are misleading).

Graphical metadata: `/pps/system/installer/appdetails/applications` (aggregate
JSON of every app's sections: Application-Name, Entry-Point-*, Entry-Point-Icon,
caps, dnamepath, extras...). **KEY FINDING (2026-09-13): Android APK-registered
apps are NOT listed in this aggregate.** Current dump (25.9 KB): contains native
bars (BBVE, adobeReader, sys.*...) and `sys.data.getroot` (the pre-root autoloader's
own payload, Package-Id `andrBgJqi...`, extras `source::apk`) - but NO
`com.amazon.mShop`, NO `com.amazon.venezia`, NO `sys.android`. The two factory
Android apps exist in `registeredapps` but have no appdetails section.

Consequence for the drawer path: the grid shows Android apps from the
`registeredapps` entry; the appdetails aggregate is populated only by native BAR
installs (extras `websl`/`source::developer`). An Android-only install lives at
the `registeredapps` level.

Registry entries for Android apps today (post-re-flash; the only non-native ones):
```
com.amazon.mShop.android.andrBBCxSkTFXlWLsUUBuXB2ukQ::andrBBCxSkTFXlWLsUUBuXB2ukQ,1.0.503.12,,1,32539822,source::apk
com.amazon.venezia.andrBDf8ciHlJnqInA366fIKotA::andrBDf8ciHlJnqInA366fIKotA,1.6.4000.10,,1,6236576,source::apk
sys.android.gYABgKAOw1czN6neiAT72SGO.ns::gYABgKAOw1czN6neiAT72SGO-ns,10.3.3.213,,1,168448981,websl
sys.android.shell.gYABgCWpLq.7ipa6NFYT0JaLpt8::...   (the "android apps" shell/system bar, 10.3.3.213)
sys.data.getroot.andrBgJqi6F824h1CwDnH9pryMe8::...  (pre-root autoloader payload, 10.3.3.1370)
```
Note: `com.amazon.mShop.android` is in the registry but its Android-side install is
gone from the PM (not in `packages.list` today). So the registry can contain stale
grid entries for apps no longer present at the Android level - the registry is the
source of truth for the grid, the PM is not.

## [4] Android-side view (what the runtime thinks is installed)

Real `/data` = `/accounts/1000/appdata/sys.android.<ns>/data/apdata`.
- `system/packages.list` (uid, flags, data dir) - today only `com.amazon.venezia`
  survives from stock; every other entry is the built-in AOSP set.
- `system/packages.xml` + `package-stopped.xml`, `dalvik-cache/` one dex per app.
- New-install dexopt is authored by the runtime's own PM (installd) - outside
  writes to dalvik-cache abort (session23 rule).

## [5] The launch path (once an icon exists) - how the grid starts the app

1. Tapping the grid icon -> navigator -> `/pps/services/android/shrimp` /
   `/pps/system/navigator/control` (QNX-side bridge, session27).
2. `android_resmgr` -> `sbin/android_launcher` boots the VM if cold.
3. Android `init` (init.cfg) -> zygote -> system_server.
4. `QNXAppLauncher.apk` (com.qnx.android.app.launcher, the persistent Android HOME /
   AndroidViewer front) receives the intent from the QNX side and hands it to the
   target Activity. `QNXAppLauncher` subscribes to `/pps/services/android/query?wait`
   and fronts `IQNXInstallerService` (Binder). (Odex pulled previously; has NO
   apk-VIEW intent filter - installs are driven from the native side.)

## [6] COMPAT consequences (updates the spec)

- Default = OFFICIAL lane, via invoking the native installer on a staged APK (the
  user still gets the BB10 consent prompt; grid entry + caps are produced by OEM
  code we can't replicate). DO NOT hand-write registry entries (upd-owned PPS,
  signed/BAR-bound).
- Drop-lane stays ONLY for COMPAT's own payloads (compat files, keys, CA, helpers).
- Registry-vs-PM skew is real: an app can be grid-visible (registry) yet not
  present at the Android level. When reasoning or scripting, treat `registeredapps`
  as the grid truth and `packages.list` as the PM truth; don't assume they agree.
- Modern APK gate unchanged: minSdk/runtime-18 alignment, DEX 035 (or
  framework-extra.jar graft), re-sign. Next experiment: a real modern APK through
  the OFFICIAL flow, then confirm grid icon.

## [7] Reproducibility commands (device-side)

```
# registry (helper-gated):
echo "cat /pps/system/installer/registeredapps/applications" | /base/bin/g_app_installer > /tmp/reg.json
# appdetails aggregate (helper-gated):
echo "cat /pps/system/installer/appdetails/applications" | /base/bin/g_app_installer > /tmp/adj.json
# live status channel:
echo "cat /pps/services/android/status" | /base/bin/g_app_installer
# PM truth:
echo "cat .../data/apdata/system/packages.list" | /base/bin/__root
# install logs:
echo "sloginfo" | /base/bin/__root
```

## Status
- OFFICIAL lane mechanics proven pre-flash (session22, fdroid) + re-verified
  structurally today (registry/appdetails/PPS/packages.list/status all read live).
- Grid-feed nuance (Android apps absent from appdetails) established today.
- App-drawer truth = `registeredapps`; PM truth = `packages.list`; they can diverge.