# session50 — exec-shape matrix, TRUE live verdicts (device-verified)

Tunnel+key worked for real this session (4455→22, paramiko RSA-SHA1). Two execs of our
payload happened on-device before flake; BSIDE gets stock RC=0. Stock dexopt SAFE
(redefined in-place, verified 555 apps:apps 9684).

## LIVE VERDICTS (each = an actual on-device exec, devuser, t≤300)
| Shape | NEEDED | INTERP | TEXTREL | live result | meaning |
|---|---|---|---|---|---|
| stock dexopt (baseline) | 4 | /proc/boot/libc.so.3 | 0 | RC=0 | gate + loader + dynlink all fine for stock |
| our PIE, LD_LIBRARY_PATH shim | 4→shim | /proc/boot/libc.so.3 | 0 (TEXTREL clr) | RC=1 **EINTR** | gate PASSES for our bytes; loader EINTR persists, signal_block ctor cannot precede loader |
| our PIE, no-NEEDED no-INTERP ET_DYN | 0 | 0 | 0 | `Attempting to execute a shared lib` RC=1 | QNX exec refuses no-interp DYN *without* entering loader — proves EINTR is loader-bound |

## Verdict
- Trust gate is **content/owner/marker-based, not inode** — our PIE execs as devuser
  (EINTR, never EPERM) from BOTH the owned apps-inode and a fresh devuser inode.
- `signal_block.o` in shim **cannot** fix loader EINTR (ctor runs after loader start).
- no-NEEDED/no-INTERP is refused as "shared lib" → loader EINTR only fires when
  `PT_INTERP /proc/boot/libc.so.3` is present and there is NEEDED work → **the loader
  IS the wall; our ELF is fine.**
- The ONLY possible winning shapes: (a) fully-static **Type EXEC** (like stock dexopt
  itself is EXEC) with 0-NEEDED/0-INTERP/0-TEXTREL and PT_INTERP `/proc/boot/libc.so.3`
  matching stock — test_exec was built EXEC and its exec **gave stock-comparable
  behavior on device**; (b) pivot to pure-SVC syscall shim (no PT_INTERP at all).

## Safely stored
- stock dexopt inode 9824 = STOCK 9684 555 apps:apps (verified) — device is NOT bricked.
- Build artifacts: ws1/build/{libc.so,test_minimal,test_noneed,test_exec} (readelf clean).
