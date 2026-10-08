# qnx_binder — A11 (64-bit binder ABI) <-> BB10/RIM 4.3 (32-bit) translation

Host-testable translation layer for the Passport driver path: A11 libbinder
speaks the 64-bit binder ABI; RIM's BB10 driver speaks the 4.3-era 32-bit ABI
with **swapped ioctl direction bits** (verified from RIM's own libbinder/
libbionic — see `Blackberry-Passport-Research/tools/passport-a11/
rim_binder_commands.md` and `ioctl_binder.dis`).

## Build + test (host, no QNX needed)

    gcc -no-pie -Wall -I. binder_compat.c test_compat.c -o test_compat
    ./test_compat        # all pass

(`-no-pie` keeps host addresses < 4 GiB so the identity `cb_in`/`cb_out`
test mapping is valid.)

## What is covered

- `binder_cmd64_to_rim()` / `binder_cmd_rim_to64()` — size remap + direction
  swap; asserted against RIM's extracted words (`BC_TRANSACTION` ->
  `0x80286300`, `BR_TRANSACTION` -> `0x40287202`, `BR_RELEASE` -> `0x40087209`,
  `BR_CLEAR_DEATH_NOTIFICATION_DONE` -> `0x40047210`, `_IO` commands unchanged).
- `binder_bwr64_to_32()` / `binder_bwr32_to_64()` — write/read buffer/consumed
  fields and pointers.
- `binder_writebuf64_to_32()` — walks BC_ commands; translates
  `BC_TRANSACTION`/`BC_REPLY` (40-byte txn), `*_DONE` ptr-cookie (16->8),
  `BC_FREE_BUFFER`/`BC_DEAD_BINDER_DONE` (u64 ptr -> u32), death-notification
  handle-cookie (12 -> 8); translates transaction data blobs: flat objects
  (24->16) + offsets arrays (u64 -> u32).
- `binder_readbuf32_to_64()` — reverse for BR_ commands (txn structures,
  ptr-cookies, dead-binder pointers).

## Not done yet (next)

- Buffer expansion on the read path (RIM 32-bit blobs -> A11 64-bit blobs with
  an arena) and `binder_handle_cookie` write-path detail checks.
- `BINDER_TYPE_FDA`/`BINDER_TYPE_PTR` objects (A11-only) — not supported
  (returns -1).
- The QNX-side integration: a small client layer that wraps
  `devctl(fd, dcmd, ...)` with RIM's dcmds and calls these translators
  (`0xC0186201` WR, `0xC0046209` VER, `0xC108620C` CFG, `0xC03C620B` TXN),
  patched into the qnx-linked A11 libbinder.

## Integration (built into the QNX libbinder)

- `qnx_binder_redirect.h` is force-included for the libbinder compile
  (`build.sh`): `ioctl()` on the binder fd becomes `qnx_binder_ioctl()`
  (upstream AOSP sources untouched).
- `qnx_binder.c` maps A11 requests to the RIM driver:
  `0xC0046209` VERSION -> devctl (4B),
  `0x40046205` SET_MAX_THREADS -> devctl `0xC108620C` CFG (0xfe000),
  `0xC0306201` BINDER_WRITE_READ -> translate + devctl `0xC0186201` (24B) +
  read-buffer translate back.
- `logd_stub.cpp` (a11_stubs/) provides `LogdWrite`/`PmsgWrite` no-ops so
  liblog resolves (its logd_writer/pmsg_writer are excluded from the build).

### On-device status (Passport, devuser)

`ProcessState::self()` executes the real path: `open("/dev/binder")` OK (with
test `chmod 666`), then the version devctl reaches the **real driver**, which
answers **EACCES** (credentials: device is `1000:10011`; devuser lacks them);
AOSP then aborts by design.  `tb_a11` still passes.  Next: run in the product
launch context (Android uid) and validate the write/read transaction path.
