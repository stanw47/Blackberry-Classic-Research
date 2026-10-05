# Session 25 - Checkpoint: BaseBundle fix boots PAST gate; next gap = D8 desugar lib; runtime-graft unblocked

Device: PRD-64100 Classic, OS 10.3.3, rooted userland, adb `169.254.0.1:5555`, QNX root via
`/base/bin/__root`. Date: 2026-09-12.

## What happened this session

1. Lane-(b) BaseBundle-fixed Telegram built and INSTALLED (fresh, rekeyed):
   - Old installed build was signed with a COMPAT key that lived in wiped /tmp (`compat.ks`,
     pass `compat123`, CN=Compat, SHA384withRSA 2048). Unrecoverable -> USER CHOICE: **rekey +
     fresh install**.
   - New durable keystore: `/home/stanw47/android-mine/certs/compat.ks` (same DN, fresh key,
     SHA256 `ab12ab449cab0d6bb73de1be28b69350199db2a2a15666664f6e2070894939ad`).
   - Base = **installed** tg121pyx build (NOT stock): kept MdxApp multidex bootstrap +
     manifest `com.compat.MdxApp` + minSdk 18. Retargeted BaseBundle->Bundle in classes/3/4/5
     (classes2 clean). All 5 dex re-assembled **dex 035**. Verified:
     - 5 dex all dex 035, 0 BaseBundle bytes anywhere
     - 0 residual refs in smali; all 23 BaseBundle method names exist on API-18 Bundle
       (javap GATE PASS)
     - sign = new COMPAT key, v1+v2; aapt badging: pkg org.telegram.messenger vc=70381
       vn=12.10.1, sdkVersion 18
   - Pushed to `/accounts/1000/shared/downloads/tg121pyx-fixed.apk` (72,031,424 B), user
     installed via Files-app tap. Fresh install confirmed at
     `/apps/org.telegram.messenger.andrBlIzZiZiQy9XCeYdgsrlTdw/android/tg121pyx-fixed.apk`
     (14:10).

2. THE RESULT - BaseBundle gate PASSED, next gap found:

   ```
   09-12 14:12:11.564 I COMPAT: multidex installed in attachBaseContext: 31776ms
   09-12 14:12:11.755 W dalvikvm: threadid=1: thread exiting with uncaught exception
   09-12 14:12:11.762 E AndroidRuntime: FATAL EXCEPTION: main
   09-12 14:12:11.762 E AndroidRuntime: java.lang.VerifyError: j$/util/DesugarCollections
   ```

   - All 5 dex DexOpt'd + loaded via MultiDex (proof BaseBundle retarget worked).
   - **Gap #2 = D8 desugared library namespace `j$/`.** Telegram references
     `j$/util/DesugarCollections` / `DesugarArrays` / `DesugarTimeZone`; the class is
     defined ONLY in classes2.dex (536 j$/ defs incl. all three Desugar*), but primary-dex
     verification runs against classes.dex alone -> VerifyError.
   - `classes2.dex` DEFINES `Lj$/util/DesugarCollections;` (verified via dexdump), so the
     fix is merging/hoisting j$/ into the verifier-initial classpath.

3. USER STRATEGY CONFIRMATION: patch the RUNTIME, not per-app. The j$/ gap is global (every
   modern D8-built app), same as BaseBundle was. Runtime-graft (PAL + desugar lib in
   BOOTCLASSPATH) fixes it once for all apps.

## Device access matrix (re-verified THIS session)

| Target | Read | Write | How verified |
|---|---|---|---|
| `/apps/sys.android.<ns>/native/init.cfg` | yes | yes | append marker + `sed -i` restore (clean) |
| `.../system/framework/` | yes | yes | create `.wtest`, read, delete |
| `/data/dalvik-cache` | yes | in-domain only | `drwxrwx--x android_system`; outside-domain app_process aborts (session23). Authoring is the runtime's job on relaunch. |
| `/mnt/sdcard` (== `/accounts/1000/shared/misc/android`) | yes | yes | pull/push lane, worked |
| Downloads for Files-app tap | yes | yes | `/accounts/1000/shared/downloads` (Download symlink) |

BOOTCLASSPATH + zygote line confirmed present in init.cfg (grep of `BOOTCLASSPATH` / `app_process`
lines - exact text captured; NOTE: the ksh grep pattern with `|` splat failed, re-grep needed).

## pathtrust (QNX-side) - the root model, corrected

- `pathtrust` = QNX setuid/path trust for ROOT, NOT the Priv's Linux pathtrust LSM (that was
  session-7f; unrelated to Classic root). User corrected me on this.
- Achieved root via btool (boot autoroot + switchzone) whitelisting with
  `/proc/boot/pathtrust !<path>`. The entry that enables root:
  `'/proc/boot/pathtrust !/base/bin/__root'` at btool LINE 31 -> `__root` becomes trusted ->
  its suid works -> interactive uid-0 (session7o).
- `/proc/boot/pathtrust` (root:nto 750, /proc/boot = boot IFS): `'<file>'`=trust FS,
  `'!<file>'`=trust file, `'-t <file>'`=query, `'lockdown'`. Needs ROOT to change.
- Trust list re-applied every btool run (boot autoroot + switchzone); not persistent on its
  own. We already hold `!`-trust on `__root`, so we permanently have QNX root.
- Leverage for graft: if we need an additional trusted NATIVE binary to run as real root
  (e.g. a dexopt helper / service), we grant it the same way from inside `__root`. Not needed
  for the current plan (runtime dexopts in-domain).

## Runtime-graft plan (durable direction)

- **Lane (a) PAL runtime component**: compat.jar in BOOTCLASSPATH (init.cfg graft point),
  warm dexopt, zygote relaunch. Rollback = init.cfg backup restore + relaunch.
- **Gate order** (Phase-2 BASEBUNDLE gate first, then j$/ desugar):
  1. BaseBundle PAL (android/os/BaseBundle) -- already built + compiled + proto-verified
     (pal/out/pal/classes.dex, 60,260 B, dex 035).
  2. desugar_jdk_libs `j$/` namespace classes (DesugarCollections/Arrays/TimeZone + stream etc.)
     so the D8 desugared-library refs resolve from the verifier-initial classpath.
- **Class-definition check done**: 536 j$/ classes defined in classes2.dex (incl.
  `j$/util/Desugar{Collections,Arrays,TimeZone}` AND `j$/util/desugar/*`); classes3/4/5 have
  none; classes.dex has none (def count 0). Source of truth: tg121pyx-fixed.apk (already dex 035).

## Artifacts

- `/home/stanw47/android-mine/tg2/tg121pyx-fixed.apk` (72,031,424 B) - installed working build (BaseBundle fixed, still crashes on DesugarCollections)
- `/home/stanw47/android-mine/tg2/verify_fixed.py` - APK verify (dex versions, BaseBundle purge, sig, MdxApp, 5-dex parity)
- `/home/stanw47/android-mine/tg2/gate_check.py` - API-18 Bundle method-surface gate check
- `/home/stanw47/android-mine/device/pulled/tg_installed.apk` - the pre-rekey session-24 build
- `/home/stanw47/android-mine/certs/compat.ks` - durable COMPAT signing key (pass compat123)
- Original stock APK: `~/Downloads/org.telegram.messenger_12.10.1-70381_minAPI21(...)_apkmirror.com.apk`

## Next actions (ordered)

1. Record this checkpoint (DONE - this file).
2. Build compat.jar host-side: BaseBundle PAL + j$/ desugar classes pulled from
   classes2.dex of tg121pyx-fixed.apk (or a fresh d8 desugar_jdk_libs build), dex 035.
3. Verify no class collisions vs framework (j$/ never exists in 4.3 framework - safe).
4. Device graft: drop jar, init.cfg append (backup first), relaunch, observe dexopt + gate.
5. Launch Telegram, capture gap past DesugarCollections; repeat runtime-jar cycle.