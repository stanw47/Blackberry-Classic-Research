# session66 — App install failure FIXED: /system/bin/dexopt had lost its execute bit

Date 2026-09-20. Classic (10.3.3.3216), live via SSH (tunnel re-established).
Reported symptom: "an app that previously installed fine now fails to install."

## Root cause (definitive)
Android app installs were failing with **`INSTALL_FAILED_DEXOPT (-11)`** and, on
retry, `-24` (INSTALL_FAILED_UID_CHANGED). Installd's dexopt step could not run
because:

    /system/bin/dexopt  =  -rw-r--r--  1 root nto  9684  Sep 16 17:21

i.e. **execute bits missing** (and owner root:nto), while every stock
`/system/bin` binary is `-rwxrwxrwx apps 10011 Feb 22 2018`. A prior
ws1/dexopt-trust-gate session overwrote/restored `/system/bin/dexopt` and a root
`cp` reset its mode to 644. Without +x, `installd` cannot exec dexopt, so every
new install aborts with INSTALL_FAILED_DEXOPT.

### Evidence
- Log (`slog2info`, `android_logcat`):
    D/QNXInstallerService: Collaborative install: free.rm.skytube.legacy.oss
    D/QNXInstallerService: Missing digest ... treat as not installed
    D/QNXInstallerService: setPermissions succeeded
    D/QNXInstallerService: Install failure [-11]        <- DEXOPT
    ... retry ... Install failure [-24]                 <- UID_CHANGED
    W/PackageManager: Package couldn't be installed in /data/app/free.rm.skytube.legacy.oss-1.apk
- `/data/dalvik-cache/data@app@com.amazon.venezia-1.apk@classes.dex` dated
  **Sep 13 09:10** = a prior SUCCESSFUL dexopt; NO odex for skytube. Matches
  "previously installed fine" (worked Sep 13; broke Sep 16 when dexopt lost +x).
- The file content IS the genuine stock dexopt: Type DYN, interp
  `/usr/lib/ldqnx.so.2` (same shape as stock installd/app_process/linker_helper),
  imports `_Z23dvmContinueOptimizationixlPKcjjb`, `dexZipFindEntry`,
  `dexZipExtractEntryToFile`, `libslog2.so.1`, `libexpat.so.2`. Only perms were wrong.

## Fix applied
    chown apps:10011 /system/bin/dexopt
    chmod 777        /system/bin/dexopt
    -> -rwxrwxrwx 1 apps 10011 9684 /system/bin/dexopt
Verified: `LD_LIBRARY_PATH=/system/lib:/proc/boot:/lib:/usr/lib:/lib/dll \
          /system/bin/dexopt` now prints its normal Usage banner (rc=0) and
loads libdvm.so. App installs should now succeed (user to re-try).

## ALSO FIXED this session (prior-session leftovers, binder work)
- Restored RIM's original container binder (was swapped for our A11 test binary
  in session65): `native/system/bin/binder` = RIM's 30440 B again; removed our
  `my_a11_binder.bak`. (Running binder was always RIM's — the disk swap never
  affected the live runtime.)
- Re-established the blackberry-connect tunnel (needed `setsid` so it survives
  the launching shell).

## FLAGGED, NOT TOUCHED (non-stock, needs user decision)
- `/system/lib/libc.so` (root:nto, 315872 B, Sep 15) and `/system/lib/libm.so`
  are NON-STOCK; stock originals were backed up by a prior session as
  `libc_bak.so` (237816), `libm_bak.so`, `libdl_bak.so`, `libz_bak.so`.
  The runtime runs with them, and dexopt loads libdvm.so fine with them in the
  path, so they are not the install blocker — but they are modifications to the
  runtime's bionic. Restore from `*_bak.so` if a pristine runtime is wanted.
- Non-stock files left in `/system/bin`: `test_minimal`, `ws1smoke`,
  `dexopt_ctrl2`, `r` (all ws1 experiment artifacts, harmless names).
- `/tmp/ws1ok/` holds ws1 test binaries + `libc.so` shim (238032/304344).
- `/var/log/binder.core` (session65 test crash dump).

## Lesson
Any root `cp` of a stock runtime binary strips its mode/owner. After touching
`/system/bin/*` or `/system/lib/*`, re-verify with `ls -l` against the stock norm
(`-rwxrwxrwx apps 10011`).
