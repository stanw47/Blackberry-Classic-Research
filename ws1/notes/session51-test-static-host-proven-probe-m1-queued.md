# session51 — test_static HOST-PROVEN; device probe M-1 queued

Date 2026-09-16 (late). Repo only source of truth; RESUME.current.md already deleted
and absorbed into session50; this extends it.

## The decisively-built artifact (HOST-linked this session, readelf-verified BOTH times)
`ws1/build/test_static` — 121534 B, fully static:
- readelf -h: **Type: EXEC**, Machine ARM, Entry 0x08000000 (Type-EXEC static, stock class)
- readelf -l: **INTERP = 0**, 0 PT_PHDR/INTERP loader request
- readelf -d: **NEEDED = 0** (no libc/libdl/libm deps), **TEXTREL = 0**, TEXTREL flag absent
- arm-none-eabi-readelf -r | grep text-relocs = **0**

This is EXACTLY the "stock dexopt shape minus interp" that the matrix in session50
predicted as the one remaining unprobed class: the QNX exec utility asks
`is this an executable shape?` → YES (Type EXEC, static, executable-class); then
runs the gate ("0 text relocs, content-signed, owner apps:apps, mode 555") → this
has been passing (EINTR at loader) for every prior shape; for test_static there is
NO loader work possible (0 interp + 0 NEEDED = zero relocation work for QNX
dynamic-loader) → if gate+exec both approve → **RC=0 (opened)** or RC=1 EINTR
still → proves EINTR is emitted by the kernel exec syscall unconditionally.

## Deploy+exec recipe for next session (M-1, copy-paste into a python file, NOT a heredoc)
Device: Classic PBC USB/RNDIS, devmode ON, SSH devuser@169.254.0.1:22 (paramiko,
RSA-SHA1, server_sig_algs=False per deploy/bb.py con()). Root: echo-pipe "__root".
NS = live-derived `ls -d /apps/sys.android.*.ns`; BIN=/apps/$NS/native/system/bin.

1. SAFETY (must show STOCK before anything else):
    ls -lni $BIN/dexopt   # expect stock: apps:apps 555 (i.e. -r-xr-xr-x 89 89, 9684 B, inode 9824)
2. SFTP put ws1/build/test_static → /tmp/ws1ok/test_static
3. Root-pipe (echo, no embedded single quotes in the command):
    echo "chown apps:apps /tmp/ws1ok/test_static; chmod 555 /tmp/ws1ok/test_static; chmod 444 ..." | __root
4. EXEC as devuser, t>=300:
    cd /tmp/ws1ok && unset LD_LIBRARY_PATH; ./test_static 2>&1; echo RC=$?
   Expect: RC=0 → ENDGAME (stock-class static execs as devuser, no loader EINTR possible);
   or RC=1 (Interrupted function call) → EINTR is the kernel's unconditional wall for
   exec-as-devuser of throwaway inodes → pivot Fork B: in-place content overwrite of
   the TRUSTED (apps:apps 9824) dexopt inode (the ONLY wall the repo has ever seen
   pass — session42/46 EINTR-not-EPERM data), and if that still EINTRs → SVC-path.

## Hard-learned this session (host-side tooling)
- NEVER build the device deploy in a bash heredoc: every heredoc-deployed probe this
  session came back mangled (paramiko.Transport monkeypatch line corrupted by
  `$(`, `$(` and single-quote handling). The write/read tool + separate SFTP deploy
  script is the ONLY reliable route (session42/47 proved the paramiko recipe works).
- The host cross-link keeps failing ONLY on my own missing-arg mistakes (dropped
  resolver.o/resolver_tab group) — test_static now emits 0 undefined symbols, clean.
