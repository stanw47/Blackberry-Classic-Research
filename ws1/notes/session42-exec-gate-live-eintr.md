# session42 — exec gate GATE-A LIVE verdict + loader-EINTR axis

Date 2026-09-16. Device Classic 10.3.3, devuser via __root, paramiko RSA-SHA1 (server_sig_algs=False).
Repo: /home/stanw47/Documents/blackberry-research (git main, public community WS1).

## Protocols locked this session (reuse, don't rediscover)
- SSH: paramiko + `server_sig_algs=False` monkeypatch (QNX sshd = RSA-SHA1 only, old key).
- Re-root per exec: `echo "<cmd>" | /base/bin/__root` — NEVER inner single quotes (breaks QNX shell).
- chown/chmod via root-pipe (sftp chmod refused on /apps; chown must be apps:apps uid=gid 89).
- Owner apps:apps + mode 555 is sufficient for exec trust — even from a NON-trusted dir (/tmp/ws1ok).
- NS derived live first each session (sys.android.*.ns churns per boot/reprovision).

## LIVE: GATE-A trust now passes for OUR bytes (big)
- Overwriting the trusted dexopt INODE (9824) content atomically with our PIE, owner
  apps:apps 555, exec as devuser → **RC=1 "Interrupted function call" (EINTR), NOT
  RC=126 EPERM**. Same for a freshly-created untrusted inode, same content. Two paths,
  both EINTR → gate trusts *our content via owner+mode+markers*, inode identity no longer
  required for EINTR-vs-EPERM distinction. Exec itself no longer gated by inode.
- signal_block.o (ctor in shim libc.so, 101-priority, masks signals from our _start)
  did NOT clear the EINTR on-device: rebuild 238032 B (TEXTREL=0, DT_TEXTREL gone,
  0 text relocs) is SHIPPED + chowned apps:apps; exec STILL RC=1 EINTR.
  → EINTR is NOT fixed by blocking signals inside our own ctor; it happens in QNX
    dynamic-linker relocation step BEFORE our ctor runs. Loader EINTR is the wall, not
    the trust gate (gate is open).

## HOST: no-NEEDED self-contained PIE (Fork A) — partially built, will FINISH building
- Goal: fully static PIE, ZERO NEEDED, no PT_INTERP, no resolver deps → loader does
  ~nothing → no relocation EINTR axis at all. Direct readelf proof on host.
- build/test_noneed currently: 280856 B, NEEDED=0, INTERP=0, TEXTREL=1 flag remains
  (relocs in .data only; want DT_TEXTREL absent) + ONE undefined ws1_resolver
  (resolver_tab.o/tramps.o not in link set yet) → LHS failed. Fix: link resolver.o
  resolver_tab.o glue_core.o together (they live in OBJS) or stub ws1_resolver in
  tramps.S. This is the decisive experiment queued (Fork A / Fork B in RESUME).

## Next (priority, ordered)
1. Finish host static PIE readelf-clean: NEEDED=0, INTERP=0, TEXTREL flag absent,
   relocs only R_ARM_RELATIVE in .data.rel.ro. (host-side, no device needed)
2. Deploy to /tmp/ws1ok/test_noneed, chown apps:apps + chmod 555, exec as devuser
   with t>=300.
   - RC=0 → gate open AND loader bypassed → WS1 In-Place/PIE path proven end-to-end.
   - RC=1 EINTR still → EINTR is not loader-relocation; pivot to Fork B (exec via
     stock dexopt argv-with-injected-args or one-shot __root devuser spawn).
3. Update RESUME.current.md with whichever branch lands.
