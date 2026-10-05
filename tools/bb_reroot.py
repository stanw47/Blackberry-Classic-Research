#!/usr/bin/env python3
"""
bb_reroot.py - VERIFY uid-0 (real root) on a BlackBerry 10 Classic/Passport
               over USB. One click, cross-platform (Linux + Windows),
               zero extra installs.

(c) blackberry-research 2026

WHAT ONE CLICK DOES
  1. generate a FRESH 4096-bit RSA key for THIS session
     (device enforces 4096-bit minimum and wipes authorized_keys on every
     Dev-Mode cycle -> single-session key is mandatory, docs/ssh-connection
     -linux.md:155-158). A fresh key is ALWAYS made; never reused.
  2. if the SSH tunnel (Connect.jar / blackberry-connect) isn't holding the
     Dev-Mode session, AUTO-START it here: pushes the fresh public key over
     the qconn door (4455), then holds the tunnel. The Dev-Mode PASSWORD is
     asked once via getpass (cross-platform, nothing to install) unless you
     set BBDEVPW.<br>  3. wait for sshd (22), connect as devuser with the fresh key,
     and VERIFY the two halves of the root trust:<br>     a. /base/bin/__root present + setuid-root (pre-rooted build check)<br>     b. live THIS boot:  echo id | /base/bin/__root  ->  uid=0(root)<br>     c. persistent half: on-device btool (autoroot) still carries the
        __root whitelist line (line 31: '/proc/boot/pathtrust !/base/bin/__root')

THE TOOL NEVER:
  * reboots or triggers a reboot (that's YOUR job, manually, per the notes)
  * writes anything to the device beyond the documented single-session
    public-key push that Dev-Mode itself requires to open sshd
  * patches btool, reflashes, or modifies autoroot

WHEN __root IS PRESENT BUT "untrusted this boot" (verified live 2026):
  The autoroot re-trusts __root AT EVERY BOOT (persistently, forever) --
  but only starting from the NEXT boot. So the fix for "exit 4" is simply:
  >>> REBOOT THE DEVICE MANUALLY <<<, wait ~60s, then re-run this tool.

EXIT
  0  uid-0 VERIFIED live (real root is ACTIVE this boot)
  3  Dev-Mode/qconn door (4455) unreachable - nothing to verify
  4  __root + autoroot line31 present, but NOT trusted THIS boot
     -> REBOOT THE DEVICE YOURSELF, wait ~60s, re-run. Persists every boot.
  5  __root binary MISSING entirely (not the pre-rooted build)
  6  __root present but on-device btool is STOCK (line31 missing) -> the
     reflash did NOT carry the patched autoroot; apply the documented
     btool.patched fix, then REBOOT YOURSELF and re-run.
  7  fatal/internal error

ENV (all optional)
  BBHOST      device IP     (default 169.254.0.1)
  BBPORT      SSH port      (default 22)
  BBUSER      SSH user      (default devuser)
  BBDEVPW     Dev-Mode device password (if unset: asked via getpass)
  BBKEY       private key path (if set+exists: use it; else FRESH 4096)
  BBCONNECT   path to blackberry-connect binary
  BBCHECKCHK  1 = check-only: never starts tunnel, only prints state (exit 3
             if 22 isn't already answering; still never reboots)
"""
import os, sys, time, socket, tempfile, subprocess, getpass
import paramiko
import paramiko.transport as PT

# ---- the QNX sshd paramiko recipe (identical to connect_now.py) ----------
_orig = PT.Transport.__init__
def _patched(self, *a, **kw):
    kw.setdefault('server_sig_algs', False)
    return _orig(self, *a, **kw)
PT.Transport.__init__ = _patched

# 4096-bit-min enforced by the device; paramiko must not offer rsa-sha2
DISABLED = {'pubkeys': ['rsa-sha2-512', 'rsa-sha2-256']}

HOST = os.environ.get('BBHOST', '169.254.0.1')
PORT = int(os.environ.get('BBPORT', '22'))
USER = os.environ.get('BBUSER', 'devuser')
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def log(m):
    print(m, flush=True)

def fresh_key():
    """Generate a fresh 4096-bit RSA pair for THIS session (never reused)."""
    d = tempfile.mkdtemp(prefix='bb_root_')
    priv = os.path.join(d, 'id_rsa')
    pub  = os.path.join(d, 'id_rsa.pub')
    k = paramiko.RSAKey.generate(bits=4096)
    k.write_private_key_file(priv)
    os.chmod(priv, 0o600)
    with open(pub, 'w') as f:
        f.write("ssh-rsa %s\n" % k.get_base64())
    return priv, pub

def find_connect():
    """Locate blackberry-connect (Connect.jar wrapper). Cross-platform; no
    install -- we only point the official tool at the device as documented."""
    cands = [
        os.environ.get('BBCONNECT', ''),
        os.path.join(os.path.expanduser('~'),
                     'priv-research', 'bbndk-tools',
                     'host_10_3_1_12', 'win32', 'x86',
                     'usr', 'bin', 'blackberry-connect'),
        os.path.join(os.path.expanduser('~'),
                     'priv-research', 'bbndk-tools',
                     'host_10_3_1_12', 'win32', 'x86',
                     'usr', 'bin', 'blackberry-connect.bat'),
    ]
    for c in cands:
        if c and os.path.isfile(c):
            return c
    raise FileNotFoundError("blackberry-connect not found; set BBCONNECT=")

def port_open(tries=6, wait=3, host=HOST, port=PORT):
    for _ in range(tries):
        s = socket.socket(); s.settimeout(2)
        try:
            s.connect((host, port)); s.close(); return True
        except OSError:
            s.close(); time.sleep(wait)
    return False

def start_tunnel(conn, priv, pub):
    """Start blackberry-connect to bring Dev-Mode SSH up: authenticates over
    the qconn door (4455), pushes the FRESH public key, then holds the
    tunnel. Prompts once for the Dev-Mode password (getpass)."""
    pw = os.environ.get('BBDEVPW', '')
    if not pw:
        pw = getpass.getpass("Dev-Mode device password: ")
    if not pw:
        log("[tunnel] no password -> can't authenticate (exit 3)")
        return False
    log("[tunnel] starting blackberry-connect (key push + tunnel) ...")
    cmd = [conn, HOST, '-password', pw, '-sshPublicKey', pub]
    logfile = os.path.join(tempfile.mkdtemp(prefix='bb_conn_'), 'conn.log')
    try:
        proc = subprocess.Popen(
            cmd,
            stdout=open(logfile, 'w'), stderr=subprocess.STDOUT)
    except Exception as e:
        log(f"[tunnel] failed to launch: {e} (exit 3)")
        return False
    # wait for sshd (22) -- documented transition after key push (~15-25s)
    for _ in range(60):
        time.sleep(1)
        if port_open(tries=1, wait=0):
            log("[tunnel] sshd UP on %d - tunnel LIVE" % PORT)
            return True
        if proc.poll() is not None:
            tail = open(logfile).read().strip()[-400:]
            log(f"[tunnel] Connect exited early (rc={proc.returncode})")
            if tail:
                log("[tunnel] tail: %s" % tail.replace('\n', ' | '))
            return False
    log("[tunnel] gave up waiting for sshd (exit 3)")
    return False

def main():
    # fresh key EVERY session (device wipes authorized_keys each Dev-Mode cycle)
    key_env = os.environ.get('BBKEY', '')
    if key_env and os.path.isfile(key_env):
        priv, pub = key_env, (os.environ.get('BBPUBOT') or key_env + '.pub')
        log(f"[key] using {priv}")
        k = paramiko.RSAKey.from_private_key_file(priv)
    else:
        priv, pub = fresh_key()
        log(f"[key] FRESH 4096-bit session key: {priv}  (never reused)")
        k = paramiko.RSAKey.from_private_key_file(priv)

    # qconn door (Dev-Mode authenticator) reachable? if not, nothing to do
    if not port_open(host=HOST, port=4455):
        log("[door] qconn door 4455 CLOSED -> Dev-Mode is OFF on the device; "
            "nothing to verify. (exit 3)")
        return 3

    # tunnel holding the SSH session? if not, one-click bring it up
    if not port_open(host=HOST, port=PORT):
        if os.environ.get('BBCHECKCHK') == '1':
            log("[ssh] port %d closed (tunnel not running) - check-only mode "
                "leaves it down. (exit 3)" % PORT)
            return 3
        try:
            conn = find_connect()
            if not start_tunnel(conn, priv, pub):
                return 3
        except FileNotFoundError as e:
            log(f"[tunnel] {e} (exit 3)")
            return 3
    else:
        log(f"[ssh] port {PORT} already OPEN - reusing running tunnel")
        stale_pid = os.environ.get('BBSTALEPID', '')
        if stale_pid and stale_pid.isdigit() and proc is not None \
                and proc.pid == int(stale_pid):
            pass  # caller told us this pid is our own stale tunnel

    c = paramiko.SSHClient()
    c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        c.connect(HOST, PORT, username=USER, pkey=k,
                  disabled_algorithms=DISABLED,
                  timeout=30, auth_timeout=120, banner_timeout=30,
                  allow_agent=False, look_for_keys=False)
    except Exception as e:
        log(f"[ssh] connect failed: {e} (exit 3)")
        return 3
    log(f"[ssh] CONNECTED as {USER}@{HOST}:{PORT}")

    def R(cmd, t=25):
        _, o, e = c.exec_command(cmd, timeout=t)
        return (o.read() + e.read()).decode(errors='replace')

    # 1. __root binary present + suid
    o = R('ls -la /base/bin/__root 2>&1')
    print("=== [1] /base/bin/__root ===")
    print(o.rstrip())
    if 'No such file' in o:
        log("[verdict] __root binary MISSING -> not the pre-rooted build "
            "(exit 5)")
        c.close(); return 5

    # 2. live trust THIS boot
    print("\n=== [2] live trust probe (echo id | __root) ===")
    o = R('echo id | /base/bin/__root 2>&1; echo "__rc=$?"')
    print(o.rstrip())
    trusted = 'uid=0(root)' in o
    log(f"[probe] __root this boot = {'TRUSTED' if trusted else 'untrusted'}")

    # 3. persistent autoroot half - does on-device btool carry the !__root line?
    print("\n=== [3] on-device autoroot btool line31 (!__root whitelist) ===")
    o = R("for b in /apps/sys.android.*.ns/native/system/xbin/btool "
          "/base/scripts/ota_info_pps.sh; do echo \"== $b\"; "
          "readlink -f \"$b\" 2>&1; grep -n '__root' \"$b\" 2>&1; done")
    print(o.rstrip())
    # fallback direct path check (documented symlink chain)
    o2 = R("readlink -f /base/scripts/ota_info_pps.sh 2>&1 | "
           "xargs -r grep -n '__root' 2>&1")
    line = [ln for ln in o2.splitlines() if 'pathtrust' in ln and '__root' in ln]
    if not line:
        log("[verdict] on-device autoroot does NOT carry !__root (stock "
            "build) - the reflash did NOT persist the whitelist; apply "
            "documented btool.patched fix, REBOOT YOURSELF, re-run. (exit 6)")
        c.close(); return 6

    if not trusted:
        log("[verdict] __root present + autoroot line31 present, but NOT "
            "trusted THIS boot.")
        log("[fix] >>> REBOOT THE DEVICE MANUALLY (autoroot re-trusts __root "
            "at boot; persists after every reboot). Wait ~60s, then re-run. "
            "(exit 4)")
        c.close(); return 4

    log("[verdict] uid-0 VERIFIED live - real root is ACTIVE this boot. "
        "(exit 0)")
    c.close(); return 0

if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception as e:
        log(f"[fatal] {e}")
        sys.exit(7)
