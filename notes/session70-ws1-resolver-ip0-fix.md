# session70 — WS1 shim: the `ip=00000000` fault is FIXED (validated on-device)

Date 2026-09-20. Classic (10.3.3.3216/10.3.3.3216), devuser via restarted
`blackberry-connect` tunnel. Continues the A11-on-QNX port (goal locked sessions
31/32: build OUR OWN Android 11 runtime on QNX; not APK transform).

## Root cause (found this session)

The WS1 shim (`ws1/build/libc.so`) had **no `NEEDED` at all**, exported its own
`dlopen`/`dlsym` as GLOBAL trampolines, and had `R_ARM_JUMP_SLOT` relocations for
`dlopen`, `dlsym` **and `ws1_lookup_glue`** — so the resolver's own helper calls
were resolved from the *global scope at load*, not link-bound. `hide_slots.map`
(`global: *; local: ws1_slot_*;`) re-globalized the `.hidden` helpers.

Result: `resolver.c`'s `dlopen("libc.so.3",0)` could bind back to the shim's own
**unfilled** slot trampoline. With only `libc.so.3` ahead of the shim in scope
(`tb_shim`) the real symbol won; once `libc++.so` joined the link the scope
shifted, the shim's own trampoline won, `*ws1_slot == 0` → `bx 0` → `ip=0`. That
is also why `[SHIM] init` (which runs *after* the resolver ctor) never printed in
`tb_cxx`.

## Fix (both applied)

1. **Real binding.** `gen_tramps.py` no longer emits `dlopen`/`dlsym` trampolines
   (they come from `libc.so.3`); the shim now links with `-Wl,--no-as-needed
   -l:libc.so.3` → `NEEDED libc.so.3`. `resolver.h` declares `ws1_lookup_glue`
   and the new `ws1_resolve_slot` `.hidden`; `hide_slots.map` localizes them.
   Verified: no relocs for the internal helpers (direct calls), `dlopen`/`dlsym`
   are `UND` bound to `libc.so.3`, `readelf -d` shows `NEEDED libc.so.3`.
2. **Order independence (lazy fill).** `ws1_resolver.S` now checks the slot: if
   `*ptr == 0` it calls hidden `ws1_resolve_slot(&ws1_slots[idx])` (returns the
   resolved fn) then tail-jumps. So a call arriving before/without the ctor still
   resolves — no init-array ordering dependency at all.

Also added minimal **locale/multibyte glue** in `glue_impl.c` that libc++'s
iostream static init needs (`newlocale`, `uselocale`, `freelocale`, `mbsinit`,
`mbrtowc`, `wcrtomb`, `mbsnrtowcs`, `__register_atfork`).

## Reproducible probes (new, tracked)

`runtime/a11-build/test/{tb_shim.c,tb_cxx.cpp,build-tb.sh}` — rebuild the ad-hoc
probes. Shape copied from `test_prop`: PIE, interp `/usr/lib/ldqnx.so.2`,
`NEEDED [libc.so.3, libc.so]` (`tb_cxx` adds `libc++.so` first), `_start`->`main`.

## On-device result

    tb_shim : [SHIM] init / A11 libs loaded / RC=0
    tb_cxx  : [SHIM] init / A11 libs loaded / RC=0     <-- was ip=00000000

`tb_cxx` loads our `libc++.so` (4.3 MB, `--whole-archive` libc++/libc++abi/
libunwind) and runs `_GLOBAL__sub_I_iostream.cpp` to completion.

## Remaining (separate, downstream — NOT the ip=0 bug)

- libc++ **ostream `operator<<`** still faults in `basic_ostream::sentry`
  (`ref=fffffff4`) — needs libc++'s locale facets wired to a real platform locale
  (`__sF`/stdio and/or the dummy `newlocale` handle). The probe deliberately
  avoids `operator<<`; static init is what was under test.
- Unimplemented GLUE symbols still land on `__ws1_unimplemented` (spin): the
  wide/`*_l` family (`wcsdup`, `wcswidth`, `wcstol_l`, `wcsnrtombs`, ...),
  `tss_*`, `twalk`, `vasprintf`, `vdprintf`, `statfs`, `syscall`, `umount2`,
  `unshare`, `__sF`, `__cxa_thread_atexit_impl`, `dl_unwind_find_exidx`,
  `__emutls_get_address`, pthread_condattr/mutexattr variants, etc. Each needs a
  real impl or a `libc.so.3` mapping (WS1b).

## Side finding: QNX SDP 6.5 target

The installed `/opt/qnx650` is **x86-target only** (`target/qnx6/x86/...`); the
ARM target libs (`armle-v7/lib/{libc.so.3,ldqnx.so.2,libcS.a,crt*,nto.link}`) are
NOT present, and `ntoarmv7-g++` is broken (`as: unrecognized option '-EL'`).
The `ntoarmv7-ld` ARM linker runs and emits the QNX `e_flags 0x5000202`. Extracted
`~/Downloads/_qnxsdp-6.5.0-x86-*.extracted` is only the Momentics IDE + host x86
files. So a QNX-native (ARM) rebuild is still not available; the GNU/NDK route
(`ws1/Makefile` + `qnx-link.sh`) is the working one.

## Files touched

- `ws1/gen_tramps.py` (drop dlopen/dlsym tramps), `ws1/resolver.h`,
  `ws1/resolver.c` (hidden `ws1_resolve_slot`, cached libc handle, lazy ctor),
  `ws1/ws1_resolver.S` (lazy fill), `ws1/glue_impl.c` (locale glue),
  `ws1/hide_slots.map`, `ws1/Makefile` (`--no-as-needed`).
- `runtime/a11-build/test/{tb_shim.c,tb_cxx.cpp,build-tb.sh}` (new probes).
- `runtime/native/system/lib/libc.so` (refreshed, 248392 B).
