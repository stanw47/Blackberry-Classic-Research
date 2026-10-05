# session22 - Android app install on BB10: the full mechanics, both lanes proven (evidence)

Device: PRD-64100 (BlackBerry Classic), OS 10.3.3 (autoloader v2-pre-rooted bar).
Context: COMPAT project (Android-any-era install via the built-in AOSP 4.3 runtime).
Question this note answers: EXACTLY how does an Android APK get onto BB10 and
into the Home grid, and what do we control / need to control? (Both answers were
proven empirically today.)

## [0] THE ANSWER IN ONE SCREENFUL

There are **two install lanes**, and they differ in exactly one critical way:

| Lane | Who drives it | PM semantics | BB10 grid icon? | Registry entry? | QNX caps? |
|---|---|---|---|---|---|
| **OFFICIAL** (Files-app tap) | BB10 native installer (installhandlerui / QNXInstallerService) | install to `/data/app/<pkg>-1.apk` (+ upgrade of pre-existing system app) | **YES** | **YES** (pkgDN) | **YES** (authman dyncap) |
| **DROP** (copy into /system/app + kill system_server) | us, with root (PM rescan) | treat as SYSTEM app, `codePath /system/app` | **NO** (registry never updated) | NO | NO |

The BB10 Home grid is a renderer over the **native QNX app registry**
(`/pps/system/installer/registeredapps/applications`). Android apps appear there
**only if the official installer wrote a pkgDN record** when the APK was
installed. The drop-lane bypasses the installer, so PackageManager knows the app
but BlackBerry 10 does not.

Verdict for COMPAT: **user-visible installs go through the OFFICIAL lane** (it
also gives us the grid icon and QNX capabilities for free), and the drop-lane is
reserved for placing COMPAT's own system/compat-layer payloads.

## [1] OFFICIAL LANE — mechanics as observed (2026-09-11, ~12:52)

Trigger (user-driven, real BB10 UX): Files app -> Downloads -> `test_install.apk`
-> BB10 native "Install this Android application?" prompt -> approve.

Result: installed cleanly, icon appeared in the app drawer.

Observed chain:

1. Native installer invokes `installhandlerui`/`QNXInstallerService`
   (QNX-side euid 810 = android_system context) — NOT PackageInstaller's UI.
   The earlier synthetic "us -> com.android.packageinstaller -> invoke" attempt
   failed ("Installation invoke failed") because a synthetic invoke does not
   carry the create-file token that the native file flow supplies; the real
   Files-app tap works fine.
2. APK is installed into the runtime PM at `/data/app/org.fdroid.fdroid-1.apk`.
   Because we had pre-dropped the same package into `/system/app`, PM treats this
   as an **update of a system app**: `dumpsys package` shows BOTH codePaths with
   `UPDATED_SYSTEM_APP`, lastUpdateTime `2026-09-11 12:52:18`. (A clean device
   would just get a normal `/data/app` install.)
3. **Registry grows by one entry** — new line 18:
   ```
   org.fdroid.fdroid.andrBZqOxwsGB_5K4v5RedItvtw::andrBZqOxwsGB_5K4v5RedItvtw,1.0.0.15,,,134437,source::apk,client::UI
   ```
   Format: `pkgDN::pkgId,version,,,size,kv...`
   - pkgDN = `org.<android-package>.<36-char-guid>` (registration identity the
     grid/QNX space uses)
   - pkgId (pk8Id) = `andr<36-char-guid>`
   - tags: `source::apk` (as opposed to `source::developer` for native bars),
     `client::UI` (installed through the UI flow).
   - This EXACTLY matches the two factory-era Android apps this device remembers:
     `free.rm.skytube.legacy.oss.andrBN8wD4gFjwrC1j5K.X8JUmw` and
     `org.chromium.chrome.andrB7hc.uCj9LMeEQJAdTp466Q`.
4. **QNX capabilities granted** (sloginfo, native log):
   ```
   12:52:17 authman: RX euid=810/egid=810,'dyncap org.fdroid.fdroid.andrBZqOxwsGB_5K4v5RedItvtw access_shared allow_noneditable'
   12:52:19 authman: RX euid=810/egid=810,'dyncap org.fdroid.fdroid.andrBZqOxwsGB_5K4v5RedItvtw run_when_backgrounded allow'
   ```
   i.e. installing an APK registers the app's pkgDN with authman and grants the
   standard Android-app capability template (access_shared, run_when_backgrounded,
   ...) — the same way native bars get capabilities, but on the pkgDN identity.
5. Home grid re-enumerates the registry and shows the icon.

```
~$ pm path org.fdroid.fdroid            -> package:/data/app/org.fdroid.fdroid-1.apk
~$ dumpsys package org.fdroid.fdroid     -> codePath=/data/app/org.fdroid.fdroid-1.apk
                                            lastUpdateTime=2026-09-11 12:52:18
                                            flags=[SYSTEM HAS_CODE ALLOW_CLEAR_USER_DATA
                                                   UPDATED_SYSTEM_APP ALLOW_BACKUP]
                                            + codePath=/system/app/org.fdroid.fdroid.apk
```

## [2] DROP LANE — mechanics (earlier this session, ~12:16)

1. Push APK to the Android-visible sdcard (`/mnt/sdcard/...` ==
   `/accounts/1000/shared/misc/android/...`).
2. As QNX root, copy into the runtime's system apps dir:
   `cp /accounts/1000/shared/misc/android/x.apk
      /apps/sys.android.gYABgKAOw1czN6neiAT72SGO.ns/native/system/app/<pkg>.apk`
   + `chmod 644`.
3. `kill -9 <system_server_pid>` -> OS monitor auto-relaunches the whole runtime
   core in ~2-4 min; PM rescans `/system/app`, dexopts, assigns uid, runs
   receivers (verified: F-Droid StartupReceiver ran: `Start proc
   org.fdroid.fdroid for broadcast org.fdroid.fdroid/.StartupReceiver
   pid=411275537 uid=10159`).
4. App is fully installed at the **Android** level — `am start -a MAIN -c LAUNCHER
   -n org.fdroid.fdroid/.FDroid` resolves — but **no native registry entry
   (registry last touch unchanged), no grid icon, no QNX caps**.

## [3] THE REGISTRY / GRID FEED (what "shows up in the drawer" means)

Authoritative source: `/pps/system/installer/registeredapps/applications`
(244 registered apps on this unit; the two android-era ones + fdroid are the
android subset). Readable through the setuid helpers, not via plain root cat
(PPS ACLs grant read to the android_* helpers; root cat alone is blocked — the
DAC mode bits are misleading; user `upd` (uid 88) owns the whole installer
namespace).

Per-app visual metadata lives beside it:
`/pps/system/installer/appdetails/applications` (aggregate, ~30 KB JSON of every
app's sections: Application-Name, Entry-Point-* incl. `Entry-Point-Icon`,
capabilities/Entry-Point-User-Actions, etc.) plus per-update snapshot deltas
`applications.NNN`. The grid = registry + the appdetails sections.

Android-side names involved:
- `QNXAppLauncher.apk` (`com.qnx.android.app.launcher`) — persistent system app,
  acts as Android HOME (LaunchActivity, MAIN/HOME/DEFAULT), subscribes to
  `/pps/services/android/query?wait`, and fronts `IQNXInstallerService` (Binder).
  Its odex (pulled) has NO apk-VIEW intent filter — installs are invoked from the
  native side (`sys.installhandlerui`), which is why our PackageInstaller-driven
  invoke failed.
- `android_resmgr` / `zipij` are the native-side publishers bridging the PPS
  `android` service namespace.

## [4] COMPAT CONSEQUENCES (updates the spec)

- **Default install lane = OFFICIAL**, via the native flow. Best COMPAT UX that
  keeps native correctness + consent: the COMPAT Hub stages a downloaded APK into
  the shared area and **invokes the native installer on it** — user still gets the
  BB10 consent prompt, and the grid entry + QNX caps are produced by the OEM code
  we can't replicate. Do NOT try to hand-write registry entries (upd-owned PPS,
  signed/BAR-bound, no sane write path).
- **Drop-lane stays** for COMPAT's own payloads (compat layer files, keys, CA,
  helper binaries) that must be placed at root spots — not for user apps.
- Modern-APK gate unchanged: PB still needs minSdk/runtime-18 alignment, DEX 035,
  `Build.SUPPORTED_ABIS` handling (d8/R8 `--min-api 19` transform + re-sign).
  Next experiment: a real modern APK through the OFFICIAL flow.
- `UPDATED_SYSTEM_APP` nuance: an official install over a dropped system copy
  upgrades in place (base stays on /system/app, update lands on /data/app). Fine
  for COMPAT, but note it when reasoning about upgrade/uninstall paths.

## [5] Reproducibility notes (device-side commands that worked)

```
# registry read (helper-gated):
echo "cat /pps/system/installer/registeredapps/applications" | /base/bin/g_app_installer > /tmp/reg.json 2>&1
# appdetails aggregate:
echo "cat /pps/system/installer/appdetails/applications" | /base/bin/g_app_installer > /tmp/adj.json 2>&1
# native install logs:
echo "sloginfo" | /base/bin/__root > /tmp/sl.txt 2>&1
# adb view of the update:
adb shell "pm path org.fdroid.fdroid; dumpsys package org.fdroid.fdroid"
```

## Status / next
- BOTH lanes proven with evidence. Grid gap root cause AND fix (official only).
- Next: modern APK (api-19 transform) through the official lane; then COMPAT Hub +
  native controller design formalization (whitelist-first UX).