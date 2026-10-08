# session78 — `_init_libc` was missing: why devctl() crashed (and the fix)

Date 2026-10-08. Passport-side tests; fix lands in the Classic repo's WS1
harness (`ws1/start.S`, `ws1/gen_tramps.py`). Passport summary note:
`Blackberry-Passport-Research/notes/session43`.

## Symptom

`devctl()` from our freestanding probes SIGSEGV'd inside the loader/libc at
`ldqnx.so.2@_connect_ctrl+0x3c` (`ldrsb r2, [r1]`, ref = the fd) — even on
`/dev/null`. Everything else (open/write/close/ioctl via shim trampolines)
worked.

## Findings

- **`/usr/lib/ldqnx.so.2` IS `libc.so.3`** — pulled from the Passport, identical
  md5 (`736f43e4…`). The ELF interpreter is the C library itself; the "loader
  crash" was *inside libc's* `_connect_ctrl` (an internal connection helper).
- RIM's own `__android_system` entry point (specimen, `@0x8e8`) shows the crt
  sequence QNX expects:
  `argc=[sp]; argv=sp+4; envp=&argv[argc+1]; scan past envp; bl _init_libc;
   (init arrays); main; exit`.
- Our `ws1/start.S` was literally `b main` — **`_init_libc` never ran**, so
  libc's connection/fd-side state was uninitialized; `devctl` (and anything
  using the connection-control path) crashed. `open/write/close` don't need it.

## Fix (Classic repo)

- `ws1/start.S` now mirrors RIM's crt: sets `argc/argv/envp`, scans to the
  auxv position, calls **`_init_libc(argc, argv, envp)`**, then `main`, then
  `exit`. This changes ALL probes (tb_*, binder probes) — rebuilt via
  `build-tb.sh`.
- `ws1/gen_tramps.py`: `extra_alias` now also exports **`devctl`** and
  **`_init_libc`** through the shim (trampoline + `qnxb_ptrs` direct binding),
  so the calls bind through the shim instead of the loader's lazy path.
- Regenerated `tramps.S` / `resolver_tab.c` / `qnxbind.c`; rebuilt
  `libqnxbind.so` + `libc.so`; redeployed.

## Verified (Passport)

- `devctl("/dev/null", bogus)` → **rc=25 (ENOTTY), no crash**.
- `tb_shim`, `tb_a11` still pass with the new startup (`UBS N=0x10a20770`,
  RC=0).
- `probe_binder_step`: open OK (fd=3, test `chmod 666`), plain
  `ioctl(BINDER_VERSION)` → `errno=13` EACCES (expected: RIM uses
  `ioctl_binder`→devctl).
- `probe_binder_devctl`: all four RIM dcmds
  (`0xC0046209` VERSION, `0xC108620C` CFG, `0xC03C620B` TXN, `0xC0186201` WR)
  return **rc=13 EACCES** under devuser (uid 100) — credential check (device is
  `1000:10011`; the product runs as the Android uid via BB10's launcher).

## Note for all future freestanding probes

Keep using `ws1/start.S` (never plain `b main`), and the deployed shim must
export `_init_libc`/`devctl` for the calls to bind through the shim.
