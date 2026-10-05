# session48 — the exec classifier, decoded (5 live probes, one wall)

Device: Classic `sys.android.gYABgKAOw1czN6neiAT72SGO.ns` via `deploy/bb.py con()`.
Date 2026-09-16 ~18:5x CST. Tunnel up (4455→22, RSA-SHA1 only). All execs as
devuser (apps:apps 555 in /tmp/ws1ok tmpfs; SFTP put + root-numeric `chown 89:89`,
`chmod 555` per docs — chown string-form refused, numeric works).

## The five live classifier results — SAME payload family, only ELF shape varies
| # | Probe identity            | readelf                               | devuser exec result            | Meaning |
|---|---------------------------|---------------------------------------|--------------------------------|---------|
| 1 | dexopt (STOCK, untouched) | EXEC, interp=/proc/boot/libc.so.3     | runs stock (baseline)          | gate: pass |
| 2 | our PIE overlay on stock inode + fresh inode | DYN NEEDED libc/libdl/libm | **EINTR RC=1** (both inodes) | gate passes content; loader EINTR |
| 3 | no-NEEDED PIE (0 needed/interp/textrel) | DYN, 0/0/0 | `Attempting to exec a shared lib` RC=1 | exec REJECTS ET_DYN-not-interp'd as shared-lib |
| 4 | signal_block shim ctor   | (same DYN as #2)                       | **still EINTR RC=1**          | ctor too late; EINTR is pre-ctor (loader's own) |
| 5 | **test_exec static EXEC** | EXEC, 0 INTERP/0 NEEDED/0 TEXTREL     | `syntax error: (' unexpected` RC=1 (ENOEXEC→ash fallback) | static-EXEC w/o interp = ENOEXEC, NOT EINTR |

## The wall, now byte-precise
QNX `exec` (via btool-trusted pathtrust gate NOT the issue — content clears gate):
- ET_DYN must be a **normal PIE INTERP'd with /proc/boot/libc.so.3** (else "shared lib").
- Type EXEC must ALSO carry PT_INTERP `/proc/boot/libc.so.3` like stock dexopt
  (else ENOEXEC).
- ANY ET_DYN/EXEC with that stock interp → loader does relocation work → **EINTR**,
  and signal_block-in-shim runs AFTER loader → can't help.
→ Real blocker is the **QNX dyld (libc.so.3 as interp) EINTR during relocation** of
  ANY payload we ship. Trust gate: OPEN for our content (proven #2, both inodes).

## Decision fork (for next session / user)
- **(A) interp-const hack**: can we make our interp NOT `/proc/boot/libc.so.3`? No —
  /proc/boot path is fixed; QNX dyld is the only legal interp. Unless we can
  **replace /proc/boot/libc.so.3 at runtime on-device** — but that's in the
  boot-time image (RIM-signed), out of reach without OTA tooling.
- **(B) dlsym-the-loader-hack**: exec stock dexopt itself (interp=qnx dyld), but get
  it to LD_PRELOAD our shim FIRST (dexopt reads LD_PRELOAD? it's an Android tool — no).
- **(C) stop fighting dyld**: dynamic loader EINTR is QNX-internal and our
  signal_block can't precede it. **Concede dynamic-loading path; pivot payload to
  statically-syscall binaries** (pure SVC, no dyld → no EINTR) = the ONLY shape
  that has neither "shared lib" nor ENOEXEC nor EINTR. This is the "clean static"
  path the resume already flagged. Exec#5 (EXEC-no-interp) was ENOEXEC **because**
  it also had COMMON/platform glue? No — it had none; ENOEXEC came from
  no-interp-on-EXEC. So add minimal ET_NOTE + keep interp OFF EXEC but add a
  **static EXEC WITH interp `/proc/boot/libc.so.3` AND 0-NEEDED** → loader does
  zero NEEDED resolution; if it still EINTRs, loader EINTR is unconditional.
  **THIS is probe #6 (decisive, ~30 min).**
