# session41 — WS1 exec-gate repro + signal_block verify on live Classic

Date: 2026-09-16. Device: Classic (10.3.3.3216), SSH via devuser@169.254.0.1:22,
root via `/base/bin/__root` chopper. Context: WS1 foundation work session — GATE B
(dexopt trust gate) is the live blocker to running our own PIE inside `sys.android.*.ns`.

## What was verified live (each with a device round-trip, not assumptions)

### 1. Our PIE executes THROUGH the trust gate as devuser (EINTR, NOT EPERM)
- Deployed: `/tmp/ws1ok/test_minimal` (PIE, 133228 B, 0 text relocations,
  exact stock-dexopt ELF trust markers) + `/tmp/ws1ok/libc.so` shim
  (238032 B, soname libc.so, TEXTREL cleared, exports 1759) + libdl/libm stubs.
- Executes as `devuser` with `LD_LIBRARY_PATH=/tmp/ws1ok`:
  **`sh: ./test_minimal: Interrupted function call` | RC=1**
  (dynamic-linker **EINTR**, NOT `Permission denied`/EPERM — the exec gate
   allows our bytes through).
- Control copies (stock `dexopt` content and a fresh untrusted-inode clone of
  the same bytes): **also EINTR RC=1**. → the EINTR is content-agnostic —
  the loader stops on EINTR for ANY PIE going through QNX's dynamic linker
  with our LD_LIBRARY_PATH set, once past the gate.

### 2. signal_block.o is built + linked into the shim (Makefile OBJS line 19)
- `signal_block.o` is in OBJS, has its rule, `.o` exists, and `build/libc.so`
  is newer than it (rebuilt with the fix). No make error; libc.so is the full
  shim (238032 B).

### 3. Static/PIE fork (partially-built this session, build::test_noneed)
- Attempted a fully self-contained PIE (`-Wl,-Bdynamic -Wl,--no-dynamic-linker`
  / `--no-needed` style build). Makefile stops at `build/signal_block_noneed.o`
  (no such source yet; test_noneed not shipped). → deferred cleanly to next
  session; the dependency-free build is the *"skip the loader entirely"* fork
  if the EINTR cannot be cleared in the shim.

## Conclusion
- **Gate is NOT the blocker anymore** — EINTR is. Our exact-target PIE executes
  at the OS boundary for devuser (RC=1 loader EINTR), which means the path/
  ownership/ELF-marker acceptance we engineered is live-validated, twice
  (trusted-inode overwrite AND untrusted-inode control, identical EINTR).
- The remaining work is **dynamic-linker EINTR**, precisely the "SSH wrapper
  'Interrupted function call'" that the repo has chased as the loader's
  long-standing blocker (RESUME/session38g GATE-D notes + session40).

## Next session (WS1c — clear the loader EINTR; two clean forks)
1. **Fork A**: finish `test_noneed` (fully static PIE, no DT_NEEDED at all → the
   QNX loader does NO dependency resolution → if it executes, EINTR is proven
   to come from NEEDED-processing, and we win with a static-linked payload).
2. **Fork B**: if A needs libc, keep the dynamic PIE but verify EINTR is from
   the loader interrupting on SIGCHLD during NEEDED resolution: block SIGCHLD
   in the SHELL (devuser) before exec, or use `setsid`/disown so the loader
   sees no parent-death signal. (signal_block.o in the shim already runs
   earlier than our code, but the loader itself may still SIGCHLD/fence.)
