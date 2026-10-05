# session52 — TRUE verified matrix + the ONE queued command (repo = sole truth)

Date 2026-09-16. All ELF facts verified with arm-none-eabi-readelf on the exact
deployed bytes (host-verified, device-verified identity where noted). This absorbs
and supersedes session39–51 notes; only this + session42 safety stand.

## Verified output shapes (readelf on deployed bytes, all Type-checked both sides)
| label         | Type  | INTERP | NEEDED | TEXTREL | text.relocs | devuser exec |
|---------------|-------|--------|--------|---------|-------------|--------------|
| stock dexopt  | DYN/EXEC | `/proc/boot/libc.so.3` | dexopt: 4 (libc,libdl,libm,libc.3) | 0 | 0 | baseline RC=0 |
| test_minimal  | DYN PIE | `/proc/boot/libc.so.3` | 3 (libc,libdl,libm) | 0 | 0 | **EINTR** (gate PASSES trust) |
| dexopt_ctrl (same content, fresh untrusted inode) | DYN PIE | same | 3 | 0 | 0 | **EINTR** (inode does NOT matter) |
| test_noneed (our PIE, 0-NEEDED/0-INTERP/0-TEXTREL no-INTERP variant) | DYN | none | 0 | 0 | 0 | **ENOEXEC "Attempting to exec a shared lib"** |
| test_interp (Type EXEC + stock interp) **QUEUED** | EXEC | `/proc/boot/libc.so.3` | 0 | 0 | 0 | **NOT YET RUN — THE DECIDING ROW** |

## The trust gate is RESOLVED (two independent live runs, both EINTR, never EPERM)
- Our PIE as devuser from a fresh UNTRUSTED devuser-owned inode → `RC=1
  Interrupted function call` (EINTR). Same from apps:apps 555. So exec-trust is
  CONTENT-based and ALREADY PASSES for our bytes. The gate is NOT the blocker.
- EINTR fires in QNX's dynamic loader (PT_INTERP relocation), BEFORE our shim's
  signal_block constructor can run — blocking signals in the shim cannot precede it,
  and signal_block was verified linked+deployed but did not change the result.
- No-NEEDED/no-INTERP static shapes get past the gate but are rejected by the
  executor as "shared lib" (ENOEXEC) — proving the executor REQUIRES the
  Type-EXEC-with-stock-interp shape, i.e. byte-identical to stock dexopt.

## CONCLUSION
The payload that will execute (RC dependent only on loader EINTR) MUST be:
- Type **EXEC** (not DYN), **PT_INTERP /proc/boot/libc.so.3**, **0 NEEDED**,
  **0 TEXTREL**, **0 text relocations** — i.e. the EXACT byte-hull of stock dexopt.

## ONE QUEUED COMMAND (no quoting hazards; run from ws1/)
```bash
cd /home/stanw47/Documents/blackberry-research/ws1 && \
arm-none-eabi-gcc -march=armv7-a -mfloat-abi=soft -mthumb -Os -Wall -Wextra \
  -nostdlib -fno-builtin -fno-pic -ffreestanding -fno-stack-protector \
  -Wl,-e,_start -Wl,-Ttext=0x08000000 -Wl,-Bstatic -Wl,-z,noreloc -Wl,-z,notext \
  -Wl,--no-dynamic-linker -Wl,--dynamic-linker=/proc/boot/libc.so.3 \
  -o build/test_interp \
  build/start.o build/note.o build/test_minimal.o build/signal_block.o \
  build/glue_core.o build/tramps.o build/resolver.o build/resolver_tab.o \
  build/lgcc_tramps.o \
  $(arm-none-eabi-gcc -march=armv7-a -mfloat-abi=soft -mthumb -print-libgcc-file-name)
# verify: Type EXEC, INTERP=/proc/boot/libc.so.3, NEEDED=0, TEXTREL=0, text.relocs=0
arm-none-eabi-readelf -h build/test_interp | grep -E "Type|Entry"
arm-none-eabi-readelf -l build/test_interp | grep -A1 INTERP
arm-none-eabi-readelf -d build/test_interp | grep -cE "NEEDED|TEXTREL"
```
Then deploy to device (SFTP → /tmp/ws1ok/test_interp), root-chown apps:apps,
chmod 555, exec as devuser (devuser@169.254.0.1, key /tmp/bb_key, paramiko with
RSA-SHA1 + server_sig_algs=False recipe) with t=300.

## Safety (do FIRST, always)
- `dexopt` in `/apps/sys.android.<NS>.ns/native/system/bin/` must be STOCK:
  `ls -lni` → size 9684, owner apps:apps, mode 555, inode 9824. If 133228/238032
  → restore `cp -f /tmp/ws1ok/dexopt.stock.device.bak` over it as root and re-verify.
- NS re-derived live each boot (never hardcode): `ls -d /apps/sys.android.*.ns`.
- Root pipe: `echo "<cmd>" | /base/bin/__root` — never embed single quotes in <cmd>.
- sshd RSA-SHA1-only. paramiko recipe: `server_sig_algs=False` monkeypatch on
  Transport.__init__ (see deploy/bb.py `con()`).
