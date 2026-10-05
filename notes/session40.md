# session40 — WS1b core glue slice: real impls + 71 fully-resolvable A11 libs

## Milestone
- First slice of REAL bionic glue landed in the WS1 shim: `__errno`, the whole
  fortify `_chk` family, the `__aeabi_mem*` variants, `mempcpy/memrchr/stpcpy/
  stpncpy`, `readlinkat` (FDCWD).
- compiler-rt helpers (`__adddf3`, `_Unwind_*`, `__aeabi_uidiv`, ...) now come
  from `arm-none-eabi` **libgcc** via export-wrappers.
- `make check`: **A11 ref 1668 ↔ exported 1757, missing 0** (full surface,
  real or stubbed).
- **71 of 459 import-bearing bacon libs are fully symbol-resolvable already**
  (`ws1/resolve_against.py`), incl. the whole pure-native tier.
- `libz.so` smoke target: **0 undefined imports** for the shim+QNX-libc pool.

## WS1b core glue (`ws1/glue_core.c`, 38 real functions)
- `__errno()` → QNX `__get_errno_ptr()` (QNX threadsafe per-thread errno).
- 20+ fortify `_chk` bound-checkers (`__read_chk`, `__write_chk`, `__fread_chk`,
  `__memchr_chk`, `__strlen_chk`, `__getcwd_chk`, `__poll_chk`, ...) calling the
  shim's own alias trampolines, which bounce to real QNX libc.so.3 — no headers
  needed, freestanding compile, hand-declared prototypes.
- `__aeabi_memcpy/memmove/memset/memclr[4/8]` (12) via memcpy/memset.
- `mempcpy`, `memrchr`, `stpcpy`, `stpncpy`, `readlinkat`(AT_FDCWD only).
- Glue remaining: 858 → ~720 still stubs (props, futex, TLS/pthread_internal_t,
  fdsan, ...). `make check` counts them as "exported" (stubs); they still abort.

## libgcc hidden-visibility discovery (key technique)
- `arm-none-eabi-gcc -mthumb` uses multilib `thumb/v7-a/nofp/libgcc.a` — calling
  `-print-libgcc-file-name` **without flags returned the wrong multilib**; fix:
  `-print-libgcc-file-name` with `$(CFLAGS)`.
- The FP/aeabi members (e.g. `_arm_addsubdf3.o`) define their symbols
  `STB_GLOBAL ... STV_HIDDEN` → invisible to `.dynsym`, so linking libgcc
  cannot export them directly (`nm -D` shows nothing; `--undefined=` doesn't
  help). Verified: 2× usage of `__adddf3` (plain vs with `-mthumb`).
- Fix: generated `lgcc_tramps.S` import-export wrappers — each A11 name is a
  Thumb `ldr r12,[pc]; bx r12` stub whose literal is `lw_ref_<sym>`, created by
  `-Wl,--defsym=lw_ref_<sym>=<sym>`; the address reference force-extracts the
  hidden libgcc member and the loader patches the ABS32/RELATIVE literal.
- `libgcc_force.txt` = `(A11 ∩ libgcc) − glue_core − alias` = 88 wrappers.
  (Symbols that are alias→QNX, e.g. `__udivsi3`, keep the dlsym trampoline.)

## resolve_against.py — link-resolution simulator
- For any bacon ELF: intersect its UND imports with {shim exports, glue-core,
  libgcc, alias, overlap, QNX libc.so.3} → prints OK/MISS per import; used by
  `make resolvelib` (libz) and the 71-lib scan.

## Fully-resolvable shortlist (71 libs)
libz, libexpat, libxml2, libsqlite, libcrypto, libjpeg, libopus, libvpx,
liblzma, libevent, libncurses, libpcap, libpcre2, libharfbuzz_ng,
libcamera_metadata, libtinyalsa, libion, libsync, libkeyutils, libsepol,
libcap, libnl, libnetlink, libmdnssd, libusbhost, libusb?, libcodec2,
libfilterpack_imageproc, libstdc++, libcompiler_rt, libc++, plus
ld-android.so, libc.so, libm.so, libdl.so/libdl_android.so, ...

## Framework tier status (not resolvable yet, by design)
- Common blocker: `atrace_get_enabled_flag/style` (libcutils/liblog tier),
  `_Znwj`/`_ZNK7android8...` (libc++ class exports — NEEDED-chain not simulated),
  binder symbols (libbinder). libandroid_runtime 1685 UND, libsurfaceflinger
  815, libmediaplayerservice 636.
- Unblocks in WS2 (live binder resmgr + servicemanager + bionic libs on the
  QNX loader).

## On-device (next)
- First on-device smoke test: place `build/libc.so` (soname `libc.so`) +
  `libm.so`/`libdl.so` stubs + bacon `libz.so` + a bacon binary that NEEDs them
  (or use `ldqnx`/a tiny QNX host binary that dlopens libz) into the container
  and confirm load + symbol resolution under QNX's loader.
- Push via the working SSH/SFTP recipe; root via `__root`.

## Known risks / parking-lot
- Shim is **non-PIC** (1545 R_ARM_RELATIVE/ABS32 relocs, some inside `.text`
  literal pools = TEXTREL). Need an on-device loader check; fallback is building
  the tramps `-fPIC` (image-relative refs).
- `__get_tls`/`__get_thread`/pthread_internal_t ABI still stubbed — any lib that
  touches bionic TLS/pthread layout will need the pthread_internal_t shim.
- `ref/a11_system` symlink-vs-file inconsistency unresolved.
- `_stack` exported (harmless; QNX libc has it too).
- Nothing committed (session files untracked: ref/, ws1/, sysroot addns,
  specimens additions).