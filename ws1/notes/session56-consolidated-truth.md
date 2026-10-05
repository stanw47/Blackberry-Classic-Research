# session56 — consolidated truth (absorbs session39–55 live findings; repo = only source)

Date 2026-09-16, device Classic/PBC QNX8 (Classic 10.3.3, sys.android.gYABgKAOw1czN6neiAT72SGO.ns
— re-derive live, never hardcode). Host: ParrotOS/arm-none-eabi 14.2.1. Everything below
is HOST-VERIFIED (readelf-verified) unless marked [LIVE].

## Connection (repo `deploy/bb.py` con() + paramiko RSA-SHA1 recipe — THIS works)
- Tunnel: `java -Xmx512M -jar bbndk-tools/.../Connect.jar 169.254.0.1 -password <PW>
  -sshPublicKey /tmp/bb_key.pub` (must stay running). Fresh 4096-bit key each session.
- SSH: `devuser@169.254.0.1` via paramiko with `server_sig_algs=False` monkeypatch +
  RSA-SHA1 (QNX sshd refuses rsa-sha2). Root pipe: `echo '<cmd>' | /base/bin/__root` —
  **never inner single quotes** (ksh breaks; that cost sessions of wall-clock).

## The five ELF shapes probed vs QNX loader (all readelf-verified, several [LIVE])
| shape | Type | INTERP | NEEDED | TEXTREL | text-relocs | devuser exec result |
|-------|------|--------|--------|---------|-------------|--------------------|
| stock dexopt | EXEC | /proc/boot/libc.so.3 | 0 | 0 | 0 | stock (RC=0) |
| our PIE | DYN | /proc/boot/libc.so.3 | 0 | 0 | 0 | **EINTR RC=1** (loader, NOT trust) |
| PIE w/ signal_block | DYN | same | 0 | 0 | 0 | **EINTR RC=1** (ctor too late) |
| PIE, 0-NEEDED static | DYN | none | 0 | 0 | 0 | "shared lib" RC=1 (rejected as lib) |
| **test_final static-EXEC** | **EXEC** | **none** | **0** | **0** | **0** | **[LIVE] deploy OK, EXEC as devuser → RC=1 … (loader EINTR persists — THE WALL]** |

## THE single remaining un-blitzed variable (already built+verified host-side)
`build/test_final`: Type EXEC, 0 INTERP, 0 NEEDED, 0 TEXTREL, 0 text relocs,
apps:apps 555. **Queued: SFTP → /tmp/ws1ok/test_final, chown apps:apps chmod 555, exec
as devuser with t>=300.** If EINTR again → the EINTR is the QNX loader refusing ANY
exec-boot shape for devuser (trust gate passes — proven — loader is the wall).
Next fork then: run as STOCK-app payload by restoring stock dexopt EXACTLY and using
LD_LIBRARY_PATH injection (LD_PRELOAD) — dexopt's own loading path, not OURS, which
is what dexopt already does only for ITSELF.

## Safety golden rules (repo safety section; verify FIRST each session)
- dexopt must be STOCK: 9684 B, apps:apps, 555, inode 9824. If missing/133232 →
  restore `cp -f /tmp/bb_dexopt.stock.modified.bak BIN/dexopt` via root.
- Root pipe NEVER embeds inner single quotes; numeric uid/gid recipe in docs.
- NS re-derived live: `ls -d /apps/sys.android.*.ns` → derive, don't hardcode.
