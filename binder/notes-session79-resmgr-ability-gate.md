# session79 — resmgr route hard-blocked on BB10 (ability gate); resmgr startup fixes

Date 2026-10-08. Passport retail. Continues the binder work (session77/78
notes). The user-space binder resmgr in this repo is the artifact under test.

## Changes

- `binder/start.S`: now runs QNX crt startup — `argc/argv/envp`, auxv scan,
  **`_init_libc(argc,argv,envp)`**, `main`, `exit` (same fix as `ws1/start.S`
  in session78; resmgr connection paths can need the same libc state).
- `binder/build_qnx.sh`: the resmgr now also links the WS1 shim
  (`-L ../ws1/build -l:libc.so` after `-l:libc.so.3`). Necessary because
  `qnxinc/errno.h` was switched to the bionic form (`(*__errno())`) and
  libc.so.3 does not export `__errno` — without the shim the loader reports
  `unknown symbol: __errno` / `ldd:FATAL` at the first `errno` use.
- Rebuilt `build/binder` (NEEDED: `[libc.so.3, libc.so]`).

## Result on the Passport

With the fixed startup + shim link, the resmgr runs up to:

```
[binder] init: before resmgr_attach(<path>)
resmgr_attach('<path>') failed: Operation not permitted
```

Tested paths:
- `/accounts/1000/shared/misc/android/qnx/binder` (devuser-writable dir) → EPERM
- `/tmp/binder` (tmpfs root) → EPERM

**Conclusion: `resmgr_attach` is gated by a BB10 process ability, not by the
path/directory.** A devuser (non-system) process cannot become a resource
manager anywhere on this OS. The previously-observed `/dev/binder` EPERM in
session65 was not about `/dev` — it applies system-wide.

## Consequences for binder

1. **Real driver (product path)** — the retail runtime talks to `/dev/binder`
   as uid 1000 with the Android abilities; our runtime will run in that same
   context, so the driver route (ioctl_binder/devctl) remains the primary plan.
   Devuser-shell testing of the driver is blocked by credentials (EACCES on
   every dcmd).
2. **Own resmgr (this repo's engine)** — not usable on BB10 as a non-system
   process. Parked permanently for this OS unless we can supply an ability
   (needs system signing).
3. **Fallback — non-resmgr transport** — patch the A11 libbinder transport to
   use something that does not need resmgr_attach (e.g. in-process broker /
   QNX channels with a side-band connection fd), or run all early-stage
   services in one process.
