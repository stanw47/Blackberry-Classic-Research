# session23 - Runtime discoverability probe: what we CAN patch (evidence-graded)

Device: PRD-64100 Classic, OS 10.3.3 autoloader v2 root. AOSP 4.3 (API 18) runtime,
sealed BAR. Goal: establish, with on-device evidence, exactly which "modify the
Android system" strategies are real.

## [0] The discovery that re-frames everything: the dalvik-cache is SEALED

- `/data/dalvik-cache` = `drwxrwx--x system system`. Nothing outside the runtime
  domain can author optimized dex there.
- Consequence: `app_process` run by *shell* (uid 2000) with a raw/compressed jar
  aborts in libdvm (`dvmAbort`, ref=deadd00d) — it cannot write the cache. A
  *stock* boot-path class (e.g. `com.android.commands.am.Am` from the pre-odex'ed
  `/system/framework/am.jar`) runs FINE the same way (TEST1, prints usage).
- => Arbitrary Java is NOT injectable from the shell. Code must enter through a
  context that owns cache rights: the runtime's OWN package manager (in-domain).

## [1] Corollary: the PackageManager IS our code-execution lane

- A signed APK dropped into `/system/app` (root) + system_server kill -> monitor
  relaunch -> PM dexopts it in-domain (same proven drop/install lane).
- Verified end-to-end with a self-built APK (d8 -> classes.dex 035, aapt2, apksigner):
  `com.compat.polarisprobe` installed as `package:/system/app/PolarisProbe.apk`,
  launcher activity ran after `am start -n com.compat.polarisprobe/com.compat.PoleActivity`.

## [2] The decisive result: per-app android.* polyfills RESOLVE

Probe output (logcat tag `COMPAT`, PID 441950478 etc.):

    SDK_INT=18 | NC=android.app.NotificationChannel
    loader=PathClassLoader[DexPathList[[zip file "/system/app/PolarisProbe.apk"],...]]
    src=?

Evidence conclusions:
1. `android.app.NotificationChannel` was DEFINED IN THE APK's own dex (absent in
   4.3) and `Class.forName` found it. Dalvik's parent-first delegation missed it
   in the boot classpath and resolved it from the app's classpath instead.
   => **Per-app supply of missing post-18 API classes WORKS.** This is the
   per-app compat adapter (strategy #3), proven.
2. `SDK_INT=18` comes from the FRAMEWORK (`android.os.Build` exists in the boot
   image). Parent-first wins for classes that already exist. The app's own dex
   could NOT shadow it, and reflection/memory patching isn't reachable from a
   plain process.
   => **SDK_INT and other existing-framework values are NOT overridable per-app.**
   They require a runtime-level patch (#1) or zygote takeover (#2).

## [3] Capability map (evidence-graded)

| Capability | Mechanism | Proven? |
|---|---|---|
| Run ANY signed d8 dex as a system app | /system/app drop + rescan | YES (this session) |
| Add NEW android.* API classes per-app | app-dex definition | YES (NotificationChannel) |
| Override EXISTING framework classes/values per-app (Build.SDK_INT…) | app-dex shadow | NO — parent-first, boot wins |
| Override existing framework classes globally | replace framework jars | NO — SDL read/edit sealed |
| Extend the boot classpath globally | relaunch zygote with BOOTCLASSPATH += our odex | untested, planned |
| Patch SDK_INT value globally | zygote-ctx memory/static-field patch | untested, planned |

## [4] Tooling now on host (reusable)

- `/tmp/opencode/bt30/android-11/`: aapt, aapt2, d8, dexdump, apksigner (build-tools r30).
- android.jar (API 16, maven `com.google.android:android:4.1.1.4`) + JDK25 javac `--release 8`.
- Build recipe: javac --release 8 -classpath android.jar -> d8 --min-api 16
  --no-desugaring -> aapt package -M -I -> aapt add classes.dex -> apksigner v1/v2/v3.
- Device shell has NO grep/tail/tr/head/pidof/touch — always filter on host; use
  host-side awk/grep on `pidin` output (pid A column).

## [5] Implied architecture (updated)

- Default app install: OFFICIAL lane (registry+grid+caps, session22).
- COMPAT compat: two-layer.
  - **Per-app adaptor (NOW possible):** transform (d8 035/min-api18, manifest
    rewrite, resign) + append missing-API polyfill dex into the app. Handles
    "I need a newer API class that 4.3 lacks." Cannot fix SDK_INT checks or
    framework-behavior enforcement.
  - **Runtime layer (necessary for SDK_INT/lies-to-apps):** zygote relaunch with
    our appended boot classpath (+ on-boot SDK_INT patch). This is the "patch the
    runtime" (#1) / toggling "secondary runtime" (#2) implementation. Requires
    the runtime-start takeover script (root, additive; races the monitor start),
    plus authoring our injected jars' odex as root before the relaunch.
- Android 10/11 *apps* are reachable in principle because their *Java* surface is
  portable; native needs stay armeabi-v7a and the dex must be 035 (d8 min-api).

## Status / next
- Telegram 11.14.1 (minSdk 19) as first REAL transform: d8 035/min-api18 + manifest
  rewrite 19->18 + (optionally injected polyfill dex), install via official
  file-tap lane, observe. This also exercises the modern-app pipeline for the
  first time.
- Zygote takeover prototype afterwards (SDK_INT + global additions).