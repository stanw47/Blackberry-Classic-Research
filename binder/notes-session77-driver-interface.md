# Session 77 — BB10 binder driver interface DISCOVERED (in RIM's libbionic)

Continuing the binder milestone after the A11 chain started running (session76).
The retail `/dev/binder` exists (uid 1000 / gid 10011) and RIM's 4.3 runtime
uses it — so the A11 port must speak **the driver's exact interface**.

## Where it lives

Retail 4.3 runtime specimen (in the passport-player43 dump; also in
`recon/passport-runtime-4.3/`):

    sys.android.../native/system/lib/libbionic.so   (85,244 B)
      T ioctl_binder @0xf228   <- the driver glue (UND: devctl, MsgSend*)
      U devctl, MsgSendnc, MsgSendv_r, MsgSendvsnc
    .../lib/libbinder.so (196,008 B)
      U ioctl_binder           <- libbinder calls THIS, never plain ioctl()
      T binder_qnx_fd @0x28780 <- opens /dev/binder + gets txn memory

`ioctl_binder` translates Linux-style binder ioctls into QNX devctl/MsgSend
messages (first constants compared: **0xC0186201** handled, **0xC108620C**
handled; message building uses a 16-bit type field 0x106 in a local struct).

## Request numbers actually used by RIM (read from libbinder call sites)

| site | request | args |
|---|---|---|
| `ProcessState::ProcessState()` @0x27f70/0x2808a | **0xC108620C** | struct, size field at +0x104 = **0xfe000** (1040384 = 1 MiB − 8 KiB) |
| `IPCThreadState::talkWithDriver()` @0x22c10 | **0xC0186201** | `struct binder_write_read` (24 B) |
| version path @0x2799e | **0xC0046209** | 4 B (`_IOWR('b',9,int)`) |
| `binder_qnx_fd()` @0x287bc | **0xC03C620B** | 60 B ("unable to get transaction memory") |

So the driver speaks (at least):
`0xC0186201` BINDER_WRITE_READ, `0xC0046209` BINDER_VERSION (4-byte!),
`0xC108620C` a custom 8-byte "setup" (RIM passes a big struct, driver copies 8),
`0xC03C620B` a 60-byte "transaction memory" query.

## Probe results on the Passport (retail)

- `open("/dev/binder", O_RDWR)` as devuser: **EACCES** normally (dev is
  1000:10011); after a test-only `chmod 666` (restored to 660 afterwards):
  **fd=3 OK**.
- `ioctl(fd, BINDER_VERSION(0xC0046209))` → rc=-1 **EACCES** (driver rejects a
  plain QNX libc ioctl — RIM goes through `ioctl_binder`, which builds custom
  devctl/MsgSend messages).
- `devctl(fd, 0xC0046209, …)` → **SIGSEGV inside ldqnx.so.2**
  (`_connect_ctrl+0x3c`, ref=fd) — the devctl call path itself trips the loader
  on this device (same class as the old `bx pc`/loader issues; not yet
  root-caused). Also the device currently belongs to uid 1000, so the real fix
  is to run as the Android uid anyway (as the retail runtime does).

- Root / `__android_system` setuid-wrapper routes are dead ends: BB10 blocks
  root from exec'ing setuid binaries ("Operation not permitted"), and the
  wrapper uses `system()` + `procmgr_ability` (it expects to be run by the
  OS framework as android_system, not by us).

## Conclusion / next

The driver is RIM's **custom QNX resmgr**, driven by `ioctl_binder`'s
translation. Next step is to port `ioctl_binder` (disassemble the full
function: 0xf228–0xf424 in RIM's libbionic.so) into the A11 port — either into
the WS1 shim (export `ioctl_binder`) and patch the qnx-linked A11 libbinder's
`ProcessState::open_driver()`/`IPCThreadState::talkWithDriver()` to call it,
or reimplement its message construction from the disassembly.
`binder_qnx_fd()`'s "transaction memory" flow (0xC03C620B → mmap) also needs
decoding. The separately-developed binder resmgr (EPERM on resmgr_attach) can
stay parked.

## Device state

`/dev/binder` restored to 660. All probes stopped; shim clean; no spinners.
