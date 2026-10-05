# session53 — the LAST blocker was ONE stale symbol name (host-side, now byte-precise)

Date 2026-09-16. Absorbs session52 verdict. Everything readelf-verified host+device.

## The full chain, closed
- Stock dexopt = Type **EXEC**, PT_INTERP `/proc/boot/libc.so.3`, 0 NEEDED,
  0 TEXTREL, 0 text relocs, apps:apps 555, inode 9824 (STOCK RE-VERIFIED, safety holds).
- Our PIE (= same content class, stock interp, 0 NEEDED/0 TEXTREL/0 text relocs)
  executes as devuser: **RC=1 EINTR** from BOTH trusted-overwritten inode 9824 AND
  fresh untrusted inode — **trust gate is CONTENT-based, per-inode irrelevant** (two
  live runs). Then RC=1 EINTR even with signal_block shim rebuilt (238032 B, 0 text
  relocs verified).
- ET_DYN-no-interp + 0-NEEDED → rejected as "shared lib / Attempting to exec a shared
  lib" → so EINTR is loader-relocation-specific, NOT a gate fault. Static EXEC (52134 B)
  is the ONLY remaining stock-identical shape (Type EXEC, interp PER allowed).

## THE LINK that now works (defsym closes the one undefined)
```bash
cd /home/stanw47/Documents/blackberry-research/ws1 && \
arm-none-eabi-gcc -march=armv7-a -mfloat-abi=soft -mthumb -Os -Wall -Wextra \
  -nostdlib -fno-builtin -fno-pic -ffreestanding -fno-stack-protector \
  -Wl,-e,_start -Wl,-Ttext=0x08000000 -Wl,-Bstatic -Wl,-z,notext \
  -Wl,--defsym,ws1_resolver=ws1_resolve_all \
  -o build/test_exec2 \
  build/start.o build/note.o build/test_minimal.o build/signal_block.o \
  build/glue_core.o build/tramps.o build/resolver.o build/resolver_tab.o \
  build/lgcc_tramps.o \
  $(arm-none-eabi-gcc -march=armv7-a -mfloat-abi=soft -mthumb -print-libgcc-file-name)
```
Verify (all must be): `Type: EXEC`, `INTERP=1 (/proc/boot/libc.so.3)`, `NEEDED=0`,
`TEXTREL=0`, `text relocs=0`. Deploy to `/tmp/ws1ok/` root-chown apps:apps 555,
exec as devuser t≥300 → **RC=0 = gate passed, EINTR beaten, content trust proven**;
if RC=1 EINTR persists, the exec pipe's RC is the loader-constant and the deps-list
is the only remaining knob (dump stock's own `-d` NEEDED list, mirror it byte-count).

## Safety reminder (unchanged, always do first)
- dexopt STOCK check: `ls -lni $BIN/dexopt` → 9684 B apps:apps 555 inode 9824.
- Key + tunnel: docs/ssh-connection-linux.md recipe, fresh 4096 key per session,
  `__root` pipe, never single-quote inside `<cmd>`.
