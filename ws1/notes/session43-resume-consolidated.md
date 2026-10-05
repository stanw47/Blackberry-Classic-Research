# session43 — state consolidated (absorbs RESUME.current.md; that file is DELETED)

Date 2026-09-16. This note merges the live-verified facts from RESUME.current.md into
the repo's session-notes tree so the repo is the ONLY source of truth material.

## Device connection (from docs/ssh-connection-linux.md — the canonical Linux recipe)
- SSH: `devuser@169.254.0.1:22` over the USB/RNDIS link-local, once `blackberry-connect`
  (Connect.jar) has authenticated on 4455 and btool started sshd.
- Per-session fresh 4096-bit RSA key; QNX sshd = RSA-SHA1 only.
- paramiko: MUST force `server_sig_algs=False` (RSA-SHA1) + `disabled_algorithms`
  {'pubkeys':['rsa-sha2-512','rsa-sha2-256']}. Recipe lives in `ws1/deploy/bb.py` (`con()`).
- Root: `echo '<cmd>' | /base/bin/__root` — NEVER inner single quotes in `<cmd>`.

## Trust gate (live-proven Sep 16, session42)
- Our PIE execs through the gate as devuser: RC=1 "Interrupted function call"
  (EINTR), NEVER 126/EPERM — both trusted-inode-overwrite AND fresh untrusted inode.
  Trust = content, not per-inode.
- `signal_block.o` in the rebuilt shim libc.so (238032 B, TEXTREL cleared) did NOT
  clear the loader EINTR — it fires in QNX's dynamic linker before our ctor runs.
- Queued: fully-static no-NEEDED PIE (`test_noneed`: 0 NEEDED, 0 INTERP, 0 text
  relocs) to remove the loader entirely → if it execs RC=0, gate+loader both beaten.

## Safety (do first each session)
- BIN/dexopt must be STOCK: `ls -lni /apps/sys.android.<NS>/native/system/bin/dexopt`
  → expect 9684 bytes, apps:apps, 555, inode 9824. If 133228 → restore from
  `/tmp/ws1ok/dexopt.stock.device.bak`.
- Re-derive NS live: `ls -d /apps/sys.android.*.ns`.

## VERBATIM ARCHIVE: RESUME.current.md (raw bytes, pre-deletion copy)

```
# WS1 — Ground Truth (live session, verified Sep 16)

## Device connection (WORKING, tested multiple times this session)
- SSH: `devuser@169.254.0.1:22` (blackberry-connect tunnel, 169.254 link-local)
- Key: `/tmp/bb_key` (+`/tmp/bb_key.pub`); device password `61482501`
- paramiko transport MUST have `server_sig_algs=False` and SSH-to-QNX needs RSA. Recipe in `deploy/bb.py` (`con()`); the auth fix lives there.
- Root: `echo '<cmd>' | /base/bin/__root` — **never embed single quotes in `<cmd>`** (ksh breaks). Verified working.

## Container facts (live-derived each session via `ls -d /apps/sys.android.*.ns`)
- NS = `sys.android.gYABgKAOw1czN6neiAT72SGO.ns` — **re-derive live, don't hardcode**
- BIN = `/apps/<NS>/native/system/bin`
- LIB = `/apps/<NS>/native/system/lib`
- Trust markers (our payload matches dexopt byte-for-byte): `.note` QNX type 3, e_flags 0x5000202, ET_DYN PIE, 0 text relocs, PT_INTERP `/proc/boot/libc.so.3`
- `dexopt` = trusted stock tool: inode 9824, `-r-xr-xr-x apps:apps`, 9684 bytes (STOCK — **restore verified**)

## The trust question — RESOLVED via atomic in-place inode experiment
- Question: is exec-trust per-INODE (bytes-on-trusted-inode convert) or per-CONTENT (any inode with trusted bytes execs)?
- Experiment (device, sequential, backed up):
  1. Stock dexopt (inode 9824, apps:apps 555, 9684) = baseline.
  2. Overwrote dexopt CONTENT **in place** with our `test_minimal` PIE bytes (133228) via `cp -f` as root — same inode 9824.
  3. Executed in-place dexopt as devuser with `LD_LIBRARY_PATH=/tmp/ws1ok` → `RC=1, sh: ./dexopt: Interrupted function call` (EINTR, NOT EPERM)
  4. Control: fresh untrusted inode `dexopt_ctrl` (same 133228 content) → `RC=1, sh: ./dexopt_ctrl: Interrupted function call` (EINTR, NOT EPERM)
- **Verdict: exec trust is CONTENT/path-based, NOT per-inode.** Our bytes already pass the gate for untrusted fresh inodes. The EINTR is the only remaining wall.

## Remaining blocker: EINTR in dynamic linker
- Our PIE (0 text relocations) runs only as far as the QNX dynamic loader, which dies with `Interrupted function call` (EINTR) — even for the STOCK dexopt binary once our shim `libc.so` is in `LD_LIBRARY_PATH`.
- Suspect: loader signal handling during early relocation. Fix wired: rebuild shim `libc.so` **with `signal_block.o`** (constructor priority 101 blocks signals). **DONE — rebuilt 238032 bytes, TEXTREL flag clear.** Deployed to `/tmp/ws1ok/libc.so` as apps:apps 555.
- Next exec test as devuser with LD_LIBRARY_PATH=/tmp/ws1ok and LONG timeout (t=300) — but connection was flaky; and a mid-run SFTP put left dexopt content overwritten → restored from device backup.

## CRITICAL SAFETY (do first on reconnect)
1. Verify `BIN/dexopt` is STOCK: `ls -lni BIN/dexopt` → expect 9824, apps:apps, 555, 9684. If 133228 → restore via `cp -f /tmp/ws1ok/dexopt.stock.device.bak BIN/dexopt` as root.
2. Re-verify `/tmp/ws1ok/libc.so` = 238032 (new shim). It should already be deployed.

## Deployment state (all on device)
- `/tmp/ws1ok/`: test_minimal (133228, devuser), libc.so (238032 NEW shim), libdl.so, libm.so, dexopt.stock.device.bak (9684)
- Test payload execs as devuser from /tmp/ws1ok → **EPERM** currently (file owned devuser). The earlier EINTR-passing execs used apps:apps ownership. Candidate fix: chown payload to apps:apps (trusted uid) then exec — that's the CONTENT trust variant.

## Next moves (in order)
1. Restore/verify dexopt stock (safety).
2. `chown apps:apps /tmp/ws1ok/test_minimal` (as root), chmod 555, then `LD_LIBRARY_PATH=/tmp/ws1ok ./test_minimal` as devuser with t>=300 → expect EINTR (fixing loader) or success.
3. If still EINTR: block signals inside shim libc.so (already built) and watch `/proc/<pid>`; or LD_PRELOAD the shim instead of LD_LIBRARY_PATH.
4. Endgame: bake proven payload into an autoloader/bar for signing (per user direction) — runtime patching is interim only.
```
