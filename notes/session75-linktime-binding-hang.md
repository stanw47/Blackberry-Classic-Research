# Session 75 — link-time binding landed; new pre-init hang under investigation

## Landed: link-time alias binding (libqnxbind.so)

- `ws1/gen_tramps.py` now also generates `qnxbind.c`: one table entry per slot,
  `void *qnxb_ptrs[N] = { &symbol, ... }` for names QNX libc.so.3 exports,
  `0` otherwise. Built as `libqnxbind.so` (needs libc.so.3, exports only
  `qnxb_ptrs`). The shim NEEDs it.
- `struct ws1_slot` gained `void **direct` (&qnxb_ptrs[idx]); `resolve_symbol`
  is now: glue impl -> `*direct` -> spin stub. **No dlopen/dlsym at resolution
  time at all.**
- `ws1_resolver.S` slot stride fixed 12 -> 16 bytes (`lsl #4`); a stale 12-byte
  stride was reading garbage slots (the earlier silent spin).
- Verified: `tb_shim` -> `[SHIM] init` / `A11 libs loaded` / RC=0, both clean
  and with `LD_BIND_NOW=1` (all previously-unresolved symbols now bind:
  `__brk`, `__emutls_get_address`, `dl_unwind_find_exidx`).

## New failure: libc++.so-present probes hang (spin), pre-init

- `tb_shim3`/`tb_cxx`/`tb_a11`: **no output at all**, process state READY
  (tight user-space spin), regardless of `LD_BIND_NOW`, `LD_NOINIT`.
- `LD_DEBUG=all` (trace shim): last lazy bindings = `pthread_key_create`
  (-> shim), `ws1_dbg_arm_now`, `ws1_dbg_note`, `ws1_dbg_note2` — i.e. a
  pre-ctor call reaches the resolver and arms/notes, then spins.
- Trace notes were made loader-free (direct `qnxb_ptrs[667]` write, sigaction
  via `qnxb_ptrs[489]`, dladdr via `qnxb_ptrs[97]`) — still zero output, so the
  spin is at/after the first resolved-call, not in the note path.
- Candidates: (a) QNX libc function called before the loader's init phase
  completes spins (e.g. pthread_key_create/write from libc++.so ctors, which
  run before the shim's ctors on this loader); (b) residual interposition in
  the qnxb table (ruled partly out: `tb_shim` writes fine, so its
  `qnxb_ptrs[667]` is a real QNX write).

## Debug tooling unlocked

- **`/usr/bin/pdebug`** on device (QNX remote debug agent) + **host
  `gdb-multiarch`**: pdebug listens on a TCP port (`pdebug -1 44000`), reachable
  from the host at `169.254.0.1:44000`. Modern gdb's RSP handshake is
  incompatible with the QNX protocol ("unrecognized item timeout in
  qSupported"), but `pdebug` works.
- **`rpdebug_qnx` (mandiant/rpdbg.py)** implements the QNX pdebug protocol
  (handshake, TargetAttach, TargetMemrd). `TargetRegrd` (cmd 11) exists in its
  command table but has no method yet — next step: implement it (packet format
  to be trialled) to read the spinning thread's registers.
- Device tools confirmed: `/bin/pidin`, `/bin/slay` (`slay -f -s 9 <pid>`),
  `/usr/sbin/dumper` (root-only, needs `/proc/dumper`), no gdb on device.
- Root cannot exec from the shared folder (`Operation not permitted`), so
  root+dumper-on-probe is blocked; pdebug-from-host is the way.

## Next steps

1. Implement `TargetRegrd` in rpdbg.py and read PC/SP/LR of a spinning
   `tb_shim3`; identify the spin site (expected: either the QNX function called
   pre-init or the trampoline loop).
2. If it is a pre-init QNX call: fix init ordering (e.g. have the shim's
   pre-fill run before libc++.so's ctors) or pre-bind; if it is a trampoline
   loop: purge alias interposition (drop alias trampolines; let consumers bind
   aliases directly to libc.so.3).
3. Keep the link-time binding architecture — it removes the loader-lock/
   dlopen-during-init class of failures.

## Device state

- Deployed in `/accounts/1000/shared/misc/android/qnx/`: direct-binding shim
  (`libc.so`, clean + trace variants), `libqnxbind.so`, `tb_shim`,
  `tb_shim2/3`, `tb_cxx`, `tb_a11`, `tb_dlopen`, `tb_cxxe`, `libdbg.so`.
- A `pdebug -1 44000` agent may still be running (kill with
  `slay -f -s 9 <pid>` if needed).
- All spinning test processes were killed.
