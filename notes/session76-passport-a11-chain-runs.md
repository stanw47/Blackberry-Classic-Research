# Session 76 — ROOT CAUSE: NEEDED link order; the A11 chain now RUNS on the Passport

## The bug: NEEDED order

The pre-init hang (silent spin, thread state READY) was **not** in the shim
logic: it was the **link order of the executable's NEEDED entries**.
Bisected with a write-only probe:

- `tb_wonly` linked `-l:libc.so -l:libc.so.3` → NEEDED `[libc.so, libc.so.3]`
  → **hangs before any shim ctor output** (spin, no output).
- `tb_wonly2` linked `-l:libc.so.3 -l:libc.so` → NEEDED `[libc.so.3, libc.so]`
  → `[SHIM] init` / `W-ONLY` / RC=0.

So: **libc.so.3 must be listed before libc.so** in the executable's link line.
When the shim is loaded ahead of the real libc, the load-time resolution of the
shim/libqnxbind dependency graph spins (QNX loader internals; the earlier
`libc+0x49f7c`/`ws1_resolver` crash sites were the same problem in the old
dlsym-based shim).

`tb_shim` had always worked because its link line was already
`-l:libc.so.3 -l:libc.so`; the A11 probes linked `libc++.so` first, pulling
`libc.so` into the link map before `libc.so.3` — hence "works on Classic with
the old builds / hangs on the Passport" was really "old probe link order vs
current chain".

## Fix

`runtime/a11-build/test/build-tb.sh` link order changed to

    -l:libc.so.3  -l:libc++.so  -l:libc.so

for `tb_a11`/`tb_cxx` (and `-l:libc.so.3` first for `probe_binder_step`).
New NEEDED order: `[libc.so.3, libc++.so, libc.so]`.

## Milestone on the Passport (retail E538)

    tb_shim3n -> [SHIM] init / A11 libs loaded / RC=0
    tb_cxx    -> [SHIM] init / A11 libs loaded / RC=0
    tb_a11    -> [SHIM] init
                 tb_a11: sigaction rc=0x0
                 UBS N=0x10c86770      # libutils+libbinder dlopen OK,
                                       # ProcessState::self found,
                                       # libc++ operator new returns heap
                 RC=0

Also works with the clean (non-instrumented) shim. `LD_BIND_NOW=1` gives
`ubs` (libutils fails eager binding only — lazy is the default; TODO if ever
needed).

## Debug tooling notes (this session)

- `LD_DEBUG` (libs/all/bindings) works on the device and was essential.
- `pdebug` (QNX gdb agent) is present but **attaching is blocked by BB10's
  /proc security** (devctl 0x40e00805 on `/proc/<pid>/as` fails even as root;
  reply[1]=6). The QNX protocol was decoded from the unstripped x86 pdebug in
  the SDP (`TargetRegrd`: `[11][regset][counter u16][offset u16][size u16]`).
- `slay -f -s 9 <name|pid>` cleans up spinning probes; the device gets slow
  under several 10r spinners.

## Files

- `runtime/a11-build/test/build-tb.sh` — fixed NEEDED order (the fix).
- `runtime/a11-build/test/tb_qnxb.c` — qnxb_ptrs value probe (debug aid).
- `ws1/resolver.c` — `WS1_SPINMARK` debug block in `__ws1_unimplemented`
  (inert unless defined; used to rule the spin stub out).

## Next

- ProcessState::self() actually running against `/dev/binder` on the Passport
  (the probe only dlsym'd it; next: call it, open_driver).
- The A11 binder step (probe_binder_step) with the fixed link order.
