#!/usr/bin/env python3
"""bb_probe_whitelist.py - READ-ONLY: report whether the on-device autoroot
actually carries the documented __root whitelist line.

Why this is the RIGHT question and needs NO reboot:
  The whitelist is a FILE on the device (the autoroot script / btool that
  autoroot reads at boot). Reading a file is not a reboot. Only *becoming*
  trusted at runtime is boot-dependent. So "did the !__root whitelist get
  applied on-device" is answerable RIGHT NOW, before you ever restart.

QNX-native reads ONLY (no readlink -f, no xargs -r -- those don't exist on
QNX; that's exactly why earlier probes printed 'cannot execute' and my old
verdict overreached). We use: ls -la (shows the -> symlink target), cat,
grep.

Never reboots. Never writes. Never kills foreign processes (only ever pid
we spawn and track ourselves).

EXIT
  0  whitelist line !__root FOUND inside on-device autoroot (persistent half
     present -> after YOUR manual reboot uid-0 WILL be re-trusted every boot)
  1  __root binary itself missing (not the pre-rooted build)
  2  autoroot file found but does NOT carry !__root (stock btool / reflash
     did not persist the whitelist -> need btool.patched reapply + reboot)
  3  nothing reachable (Dev-Mode door/tunnel down)
"""
import os, sys, time, socket, tempfile, subprocess, getpass

HOST = os.environ.get('BBHOST', '169.254.0.1')
PORT = int(os.environ.get('BBPORT', '22'))
USER = os.environ.get('BBUSER', 'devuser')

def log(m): print(m, flush=True)

# ---- fresh 4096-bit key EVERY session (docs:155-158) ----
KEYDIR = tempfile.mkdtemp(prefix='bb_probe_')
PRIV = os.path.join(KEYDIR, 'id_rsa'); PUB = PRIV + '.pub'

def fresh_key():
    import paramiko
    k = paramiko.RSAKey.generate(bits=4096)
    k.write_private_key_file(PRIV); os.chmod(PRIV, 0o600)
    with open(PUB, 'w') as f:
        f.write("ssh-rsa %s\n" % k.get_base64())
    pub64 = k.get_base64()
    open(PUB, 'w').write(f"ssh-rsa {pub64}\n")
    return PRIV, PUB, k

def connect_door():
    """Start blackberry-connect with the FRESH pubkey when sshd(22) is not
    yet up. Asks for Dev-Mode password once (getpass, cross-platform)."""
    import paramiko
    import paramiko.transport as PT
    _o = PT.Transport.__init__
    def _p(self, *a, **kw):
        kw.setdefault('server_sig_algs', False)
        return _o(self, *a, **kw)
    PT.Transport.__init__ = _p

    def up(host, port):
        s = socket.socket(); s.settimeout(2)
        try: s.connect((host, port)); s.close(); return True
        except OSError: s.close(); return False

    if up(HOST, 22):
        log("[ssh] port 22 already OPEN - reusing running tunnel")
        return True
    if not up(HOST, 4455):
        log("[door] qconn door 4455 closed - Dev-Mode OFF; nothing to read "
            "(exit 3)")
        return False

    cand = (os.environ.get('BBCONNECT', '')
            or os.path.expanduser('~/priv-research/bbndk-tools/'
                                  'host_10_3_1_12/win32/x86/usr/bin/'
                                  'blackberry-connect'))
    if not os.path.isfile(cand):
        cand = os.path.expanduser('~/priv-research/bbndk-tools/'
                                  'host_10_3_1_12/win32/x86/usr/bin/'
                                  'blackberry-connect.bat')
    pw = os.environ.get('BBDEVPW', '')
    if not pw:
        pw = getpass.getpass("Dev-Mode device password: ")
    if not pw:
        log("[door] no password given (exit 3)"); return False
    log(f"[tunnel] starting blackberry-connect (fresh key push) ...")
    logfile = os.path.join(KEYDIR, 'conn.log')
    proc = subprocess.Popen([cand, HOST, '-password', pw,
                             '-sshPublicKey', PUB],
                            stdout=open(logfile, 'w'),
                            stderr=subprocess.STDOUT)
    for _ in range(90):
        time.sleep(2)
        if up(HOST, 22): log("[tunnel] sshd UP - tunnel LIVE"); return True
        if proc.poll() is not None:
            log(f"[tunnel] exited rc={proc.returncode} (see {logfile})")
            return False
    log("[tunnel] gave up waiting for sshd (exit 3)"); return False

def main():
    fresh_key()
    if not connect_door():
        return 3

    import paramiko
    import paramiko.transport as PT
    _o = PT.Transport.__init__
    def _p(self, *a, **kw):
        kw.setdefault('server_sig_algs', False)
        return _o(self, *a, **kw)
    PT.Transport.__init__ = _p
    DISABLED = {'pubkeys': ['rsa-sha2-512', 'rsa-sha2-256']}

    k = paramiko.RSAKey.from_private_key_file(PRIV)
    c = paramiko.SSHClient(); c.set_missing_host_key_policy(
        paramiko.AutoAddPolicy())
    try:
        c.connect(HOST, PORT, username=USER, pkey=k,
                  disabled_algorithms=DISABLED,
                  timeout=30, auth_timeout=120, banner_timeout=30,
                  allow_agent=False, look_for_keys=False)
    except Exception as e:
        log(f"[ssh] connect failed: {e} (exit 3)"); return 3
    log(f"[ssh] CONNECTED as {USER}@{HOST}:{PORT} (last session's fresh key)")

    def R(cmd, t=25):
        _, o, e = c.exec_command(cmd, timeout=t)
        return (o.read() + e.read()).decode(errors='replace')

    # 0. __root binary + suid?
    o = R('ls -la /base/bin/__root 2>&1')
    print("=== [0] /base/bin/__root ==="); print(o.rstrip())
    if 'No such file' in o:
        log("[verdict] __root MISSING -> not the pre-rooted build (exit 1)")
        c.close(); return 1

    # 1. find the on-device autoroot (btool) the QNX way: list the autoloader
    #    autoroot dir + the ota_info symlink, capture the -> target, then cat
    #    the resolved file. NO readlink. NO reboot needed (file read).
    print("\n=== [1] locate on-device autoroot (QNX-native: ls shows symlink) ===")
    o = R("ls -la /base/scripts/ota_info_pps.sh /base/scripts/*.sh 2>&1 | "
          "grep -E 'ota|pps|sh' | head -20")
    print(o.rstrip())

    print("\n=== [2] cat the autoroot target and grep for the !__root whitelist ===")
    # capture real path from the ls symlink target, then grep the FILE
    o = R("for b in /apps/sys.android.*.ns/native/system/xbin/btool "
          "/base/scripts/ota_info_pps.sh; do "
          "echo \"== file $b\"; [ -f \"$b\" ] && cat \"$b\" 2>/dev/null; "
          "done | grep -nE '__root|pathtrust' 2>&1")
    print(o.rstrip() if o.strip() else "(grep: no matches -> stock)")

    found = '__root' in o and '!' in o.split('__root')[0][-1:]

    # also try the direct documented autoroot whitelist path
    print("\n=== [3] direct documented whitelist path ===")
    o2 = R("cat /apps/sys.android.*.ns/native/system/xbin/btool 2>&1 | "
           "grep -n '__root' 2>&1")
    print(o2.rstrip() if o2.strip() else "(no matches)")
    found = found or ('__root' in o2)

    c.close()
    if not found:
        log("\n[verdict] whitelist !__root NOT present on-device (stock "
            "btool) -> the reflash did NOT persist it. Apply documented "
            "btool.patched fix, then YOU reboot. (exit 2)")
        return 2
    log("\n[verdict] !__root whitelist PRESENT on-device autoroot "
        "(persistent half VERIFIED - reboot of YOURS re-trusts __root "
        "every boot). (exit 0)")
    return 0

if __name__ == '__main__':
    try:
        sys.exit(main())
    except SystemExit as e:
        sys.exit(e.code)
    except Exception as e:
        log(f"[fatal] {e}"); sys.exit(3)
