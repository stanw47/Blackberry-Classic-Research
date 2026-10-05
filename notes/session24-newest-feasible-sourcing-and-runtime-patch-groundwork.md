# Session 24 — "Newest feasible" sourcing + runtime patch groundwork

Date: 2026-09-11/12. Device: Classic SQC100, OS 10.3.3.3216, rooted userland.

## TL;DR

- The version-lie is **real and verified**: `android.os.Build$VERSION.SDK_INT` is NOT a
  compile-time constant on this runtime. Its static init reads the QNX-hosted system
  property `ro.build.version.sdk` (smali proof below). The property's source file —
  `build.cfg` (the `build.prop` symlink target) — is **root-editable without touching
  anything else** (append + restore verified live). Same file holds `release=4.3`.
- The runtime's **boot classpath is defined in edcitable `init.cfg`** line ~50:
  `export BOOTCLASSPATH /system/framework/core.jar:...:services.jar:apache-xml.jar`
  plus `service zygote /system/bin/app_process -Xzygote /system/bin --zygote
  --start-system-server`. This is the graft point for a runtime-layer PAL jar.
- We can **read and edit the previously-thought-sealed runtime config** as QNX root
  (`/base/bin/__root`): `build.cfg`, `init.cfg`, and the framework odex files all copied
  to `/mnt/sdcard` and pulled. (Contradicts the older "can't even read framework.jar"
  belief — that was about *adb/devuser*; root walks over it.)
- A15 (LineageOS 22.2 / Pixel "sailfish") framework extracted from its OTA
  payload.bin. **Most (284/300) of Telegram's real framework gaps have A15
  implementations on disk**; the remainder are 16 classes + every impl drags in pure-Java
  deps (`java.util.Objects`, `java.util.function.*`, service AIDL stubs) that are graftable
  too, plus a few native-backed graphics classes that are not.
- BaseBundle decision still open: runtime-layer (appended bootclasspath PAL where
  BaseBundle is Bundle's real superclass) vs per-app dex rewrite (BaseBundle→Bundle,
  2,361/2,387 methods already exist on API-18 Bundle) vs both. See open questions.

## Top finding: the version lie is file-editable

### How SDK_INT is computed (disassembled from the device's own framework.odex)

`android/os/Build$VERSION.smali`, `<clinit>`:

```
const-string v1, "ro.build.version.incremental"
invoke-static {v1}, Build->access$000  ; getString
sput-object v1, ...INCREMENTAL
const-string v1, "ro.build.version.release"
...RELEASE
const-string v1, "ro.build.version.sdk"
invoke-static {v1}, SystemProperties->getInt(String;I)I     ; <-- SDK_INT = prop
sput v1, ...SDK_INT
const-string v1, "ro.build.version.codename"
...CODENAME
; RESOURCES_SDK_INT derived from SDK_INT + (CODENAME!="REL" ? CUR_DEVELOPMENT+1 : 0)
```

So `Build.VERSION.SDK_INT` = `SystemProperties.getInt("ro.build.version.sdk")`.

### The property source: build.cfg (editable as root) — verified

Device (via root):
- `ls -la .../native/system/build.prop` → symlink → `build.cfg`.
- root `cat build.cfg` pulled; it holds:
  - `ro.build.id=10.3.3.213`
  - `ro.build.version.incremental=player-2.0.0_dev.eng.SER`
  - `ro.build.version.sdk=18`   ← the value to raise
  - `ro.build.version.release=4.3`
  - `ro.build.version.codename=REL`
  - abi `armeabi-v7a,armeabi`, `dalvik.vm.dexopt-flags=m=y`.
- **Writes verified**: `echo '# probe' >> build.cfg` → OK; `sed -i` remove → OK; backup
  copied to `/mnt/sdcard/build.cfg.bak`. Both append and in-place edit work.
- Live readback via adb: `getprop ro.build.version.sdk` → `18`,
  `ro.build.version.release` → `4.3`, fingerprint ends `:4.3/10.3.3.213/player-2.0.0...`.

## Second finding: BOOTCLASSPATH is in an editable init.cfg

From root `cat init.cfg` (editable file, root-append + sed verified):

```
export BOOTCLASSPATH /system/framework/core.jar:/system/framework/core-junit.jar:\
  /system/framework/bouncycastle.jar:/system/framework/ext.jar:/system/framework/framework.jar:\
  /system/framework/telephony-common.jar:/system/framework/voip-common.jar:\
  /system/framework/mms-common.jar:/system/framework/android.policy.jar:\
  /system/framework/services.jar:/system/framework/apache-xml.jar

service zygote /system/bin/app_process -Xzygote /system/bin --zygote --start-system-server
    socket zygote stream 660 root system
```

- Also in init.cfg: `mkdir /data/dalvik-cache 0771 system system` and `setprop dalvik.vm.*`
  block, plus `ro.qnx.vm.heapgrowthlimit.low/high 128m/384m` etc.
- Graft point: append a `compat.jar` (compiled for armeabi-v7a dex 035/036, linked
  against 4.3 classes only) to `BOOTCLASSPATH`, or add a `-Xbootclasspath/a`-style entry to
  the zygote service line. The framework may need dexopt into `/data/dalvik-cache`
  (root-writable, verified) before first load.

## Third: what's actually patchable (superset over the old doc %round)

| Asset | Read as root | Edit as root | Verified |
|---|---|---|---|
| `/mnt/sdcard` | yes | yes (pull/push lane) | pulls/pushes ok |
| framework/*.odex (all 29) | yes (copy out) | new-file **create** in dir ok; overwrite of in-place odex NOT attempted yet | copy-out ok |
| `build.cfg` | yes | append + in-place sed, restored | append/restore ok |
| `init.cfg` | yes | append + sed, restored | append/restore ok |
| `/data/dalvik-cache` | — | parent-dir create verified WRITE_OK | rootprobe |
| app_process (wrapper) | yes (pulled, 13,908 B ELF) | not yet | pulled |

The old "cannot read existing runtime files" claim is obsolete: that was devuser/adb's
SDL view. As **QNX root** the whole tree is readable and new files land anywhere.

## Source images (newest-first strategy)

- **PRIMARY (newest feasible data plane)**: LineageOS 22.2 = Android 15 for Google Pixel
  ("sailfish"), `~/Downloads/lineage-22.2-20260906-nightly-sailfish-signed.zip`.
  - payload.bin extracted with `payload-dumper-go` → 3.8 GB `system.img` (ext4).
  - `debugfs` (no mount needed) pulled `framework.jar` (41.9 MB, 5 dex),
    `services.jar` (28.8 MB), `framework-res.apk` (31.6 MB) → baksmali roots at
    `~/android-mine/ex/bsm15/smali_classes*`.
- **Fallback (per-class, older impl)**: LineageOS 18.1 = Android 11 for BB Priv
  ("venice"), `~/priv-research/balika/lineage-18.1-20250124-UNOFFICIAL-venice.zip`
  (system.new.dat.br, 674 MB — decompressing via python brotli in background).
  Also `~/Downloads/lineage-18.1-20250101-UNOFFICIAL-wseries.zip` (Android 11) — that is
  Balika's **BlackBerry Passport** port (targets `wolverine,wichita,oslo,keian`), same A11
  tier, so venice baksmali covers both.
- **Passport workstream is SEPARATE (2026-09-12 correction)**: Balika's LOS 18.1 is for
  the PASSPORT, not the Classic. Wait — correction #2 (same day, strategic): the point of
  COMPAT is to KEEP QNX AND get modern Android apps. Once the Passport boots again
  (BootROM 11011 issue, prior sessions), it gets the SAME COMPAT treatment — NOT Balika's
  BB10→Android conversion. Balika's build is only a feasibility proof + bring-up reference.
  COMPAT = keep QNX stability + gain modern Android usability; the conversion throws away
  QNX to gain Android (a downgrade when we can have both).
- Note: framework.jar classes are identical across devices for a given OS version, so the
  "with" device doesn't matter — Android version does. Pixel image chosen for A15

## Gap classification (mechanical, reproducible)

- True framework gaps: **300** of the 492 (the other 192 are app-bundled libs/billing/
  support.v4 — they ship inside the APK, not the framework, and resolve fine).
- 284/300 present in A15 framework; 16 not (e.g. `android.icu.text.*`,
  `android.net.Network*`, `android.os.ext.SdkExtensions`).
- Dependency style of A15 impls:
  1. pure-Java "modern base" (graftable with the class): `java.util.Objects` (API 19),
     `java.util.function.*` (API 24), `android.util.proto`, flag classes
     (`Landroid/app/Flags`, `Lcom/android/.../Flags`), util packs. These are absent on
     4.3 but are Java-only → come along for free once included in the PAL.
  2. AIDL binder stubs (`IJobCallback$Stub`, `ILauncherApps$Stub`, ...) — marshalling
     classes; can exist server-less; method calls return binder-dead unless patched.
  3. native-backed (`RecordingCanvas`, `RenderNode`, `HardwareRenderer`,
     `libcore.util.NativeAllocationRegistry`, `Vulkan`) — NOT graftable on Dalvik 4.3;
     apps must be re-pathed around these or they fail only if actually used.
- Full inventory saved to `~/android-mine/classify_out.txt` and script
  `~/android-mine/classify.py`; 4.3 ground truth `fw43_univ.txt` (9,947 boot types built
  with the hand-rolled dex-035/036 parser `dexclass.py` — strings() undercounts class
  tables, so a proper dex header walk was needed).

## Android version (SDK_INT) — choices and risk

- **Setting**: `ro.build.version.sdk` in `Build$VERSION.SDK_INT` (verified). Raise via
  build.cfg edit → SDK_INT reports anything we want (up to what the grafted dew supports).
- **Why not free**: framework internals also branch on SDK_INT (`Resources`, `Intent`,
  `ActivityManager`, `View`, ...). Lying globally flips those branches too — they'd take
  "newer" paths that call the classes we newly graft, sometimes correctly (that's the
  point) but sometimes against native/services we won't graft. So the lie must be
  validated incrementally (per-app first, then runtime-wide after PAL coverage) and can be
  made **per-app** in the COMPAT transform if the global way is too fragile.
- Recommendation: raise release/codename strings immediately (cheap, mostly cosmetic),
  defer the SDK_INT bump until the PAL passes a smoke test (Telegram boots + system_server
  stable + a controls app runs).

## Files / state (durable home, since /tmp was wiped once)

- Host workspace now at `~/android-mine/` (NOT /tmp): `run_ssh.py` (RSA-SHA1
  monkeypatch), `dexclass.py`, `classify.py`, `closure.py`, `gaps_framework.txt`, device
  pulls under `~/android-mine/device/` (framework/core/ext/bcs/cj odex, app_process,
  android_launcher, init.cfg), `ex/bsm15/` (A15 baksmali), `v11/` (venice decompress).
- Device: runtime alive (system_server 13811939, org.telegram.messenger process present).
  Telegram 12.10.1 still crashes at Firebase init → BaseBundle gap (see below).

## Still-open BaseBundle / Firebase decision

- Crash is `NoClassDefFoundError: android.os.BaseBundle` from
  `FirebaseInitProvider.onCreate → FirebaseApp.<init> → ComponentDiscovery...keySet()`.
- The installed apk STILL ships the full Firebase/GMS surface — `compat_tool.sh` does NOT
  strip it (the manifest strip was never applied to the installed build). Options:
  (a) runtime-layer PAL (BaseBundle+ArrayMap+Objects grafted into boot CLASSPATH);
  (b) per-app dex rewrite BaseBundle→Bundle (2,361/2,387 call sites already exist on
  API-18 Bundle; shim size/isEmpty/keySet);
  (c) both.
- Recommendation: (b) first for immediate Telegram boot proof; (a) as the general runtime
  layer from A15 sources; revisit the 16 non-A15 + native-backed classes for per-app.

## Next steps

1. Finish venice (A11) framework extraction; build per-class "newest feasible" table.
2. Decide BaseBundle lane (a/b/c) with user.
3. If (a): build `compat.jar` from A15 impls (dex 035, armeabi-v7a), stage into
   `framework/`, append to `BOOTCLASSPATH`, warm dexopt into dalvik-cache, relaunch.
4. Test version-lie minimally (release string first).
5. Re-run a stripped-manifest Telegram build through install + launch to isolate
   framework gaps from Firebase.

## Session 25 addendum (2026-09-12) — corrected selection + A11 tier done

- **A11 (venice) extraction completed**: `system.new.dat.br` brotli → `sdat2img` xpirt
  (re-downloaded, saved `~/android-mine/sdat2img.py`) → `system_a11.img` (3.75 GB) →
  `framework_a11.jar` (27.4 MB, 4 dex) → baksmali to `~/android-mine/ex/bsm11/`. wseries
  (Passport) is the same A11 tier — not needed for the Classic workstream.
- **The "289 full closure / 0 hard" from session24 was a closure bug**: the skipped-it
  start node because it was itself in the graft set. Fixed to always walk the start's own
  body. Corrected per-class selection (`~/android-mine/SELECTION.report`):
  - **226 → A15 impl, pure-Java graftable** (with the 37-shim java base in
    `~/android-mine/shims.txt`: Objects/StringJoiner/Base64/function.*/time.*/stream.*/
    concurrent.*/nio.file.*/libcore HexEncoding/Record)
  - **32 → A11 impl** (A15 impl drags unshimmable deps; A11 closes clean)
  - **31 → HARD**: 21 more-shim (Optional/stream closures — graftable, more work); 10
    native-blocked (ColorSpace, RecordingCanvas, RenderNode, RuntimeShader, RenderEffect,
    FontFamily$Builder, camera2 CameraManager, PrecomputedText, PixelCopy, Magnifier)
  - **11 → NEITHER** (android.icu.text.*, android.system.* Os/OsConstants/StructStat,
    MediaStore$Downloads, SdkExtensions — A15 core-OJ/libart split jars, low priority)
- Docs updated: desktop COMPAT-STATUS-AND-RUNTIME-OPERATIONS.md (§9.5 corrected + §9.7 shim
  base + §5 stale "sealed files" claim flagged superseded), repo PLAYBOOK.md, GAPS.md.
- Next concrete step remains the BaseBundle decision (a/b/c) — recommendation unchanged:
  (b) per-app first for boot proof, (a) runtime PAL for the general layer.- **Session 25+ — "TRUE upgrade" policy (user directive, 2026-09-12)**: the goal is a
  REAL runtime upgrade — phone reads SDK_INT/RELEASE/FINGERPRINT as the upgraded version
  BECAUSE the surface is actually grafted, not strings-only cosmetics. Two hard rules now
  canonical:
  1. **BASEBUNDLE + LIBS COMPLETENESS GATE (Phase 2)**: before any version lie, prove
     BaseBundle/ArrayMap/Objects/function.*/time.*/Bundle-hierarchy/Context-family resolve
     GLOBALLY from the runtime jar (A15 primary, A11 fallback). No "phone=15" without 15's
     basebundle present.
  2. **VERSION-MATRIX (Phase 3)**: one row per advertised version (15/11...), columns =
     every basebundle class + lib + .so the surface implies, each marked present-grafted /
     present-native / per-app-reroute; installer refuses to advertise a version whose
     matrix column isn't green. Climb SDK_INT 21→…→35 one step per Telegram+system_server
     smoke; never past what's grafted.
- Implemented in `compat/UPGRADE-ROADMAP.md` (Phase 2+=basebundle gate, Phase 3 rewritten as
  TRUE UPGRADE), desktop §9.1 caveat updated. The "newer phone" is genuine (reads its real
  upgraded version, surface actually there), not cosmetic.
