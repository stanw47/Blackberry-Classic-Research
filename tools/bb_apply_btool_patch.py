#!/usr/bin/env python3
"""bb_apply_btool_patch.py - APPLY the documented btool.patched to the
on-device autoroot script so __root gets whitelisted at boot.

This DOES write to the device (the one allowed write: the world-writable
btool in the Android container). Per session26, btool is world-writable
and its ACL grants self-traversal, so we can overwrite it directly via
SSH without needing root or __root.

After applying, YOU must reboot manually (~60s). Then one-click re-run
will show uid-0 live (exit 0). THIS TOOL NEVER REBOOTS.
"""
import os, sys, time, socket, tempfile, getpass, subprocess

HOST = os.environ.get('BBHOST', '169.254.0.1')
PORT = int(os.environ.get('BBPORT', '22'))
USER = os.environ.get('BBUSER', 'devuser')
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PATCHED = os.path.join(REPO, 'notes', 'session12-passport-root', 'classic', 'btool.patched')

# ---- QNX sshd paramiko recipe ----
import paramiko, paramiko.transport as PT
_orig = PT.Transport.__init__
def _patched(self, *a, **kw):
    kw.setdefault('server_sig_algs', False)
    return _orig(self, *a, **kw)
PT.Transport.__init__ = _patched
DISABLED = {'pubkeys': ['rsa-sha2-512', 'rsa-sha2-256']}

def log(m): print(m, flush=True)

def fresh_key():
    import paramiko
    d = tempfile.mkdtemp(prefix='bb_apply_')
    priv = os.path.join(d, 'id_rsa'); pub = priv + '.pub'
    k = paramiko.RSAKey.generate(bits=4096)
    k.write_private_key_file(priv); os.chmod(priv, 0o600)
    with open(pub, 'w') as f: f.write("ssh-rsa %s\n" % k.get_base64())
    return priv, pub, k

def port_open(tries=8, wait=2, p=PORT):
    for _ in range(tries):
        s = socket.socket(); s.settimeout(2)
        try: s.connect((HOST, p)); s.close(); return True
        except OSError: s.close(); time.sleep(wait)
    return False

def find_connect():
    cands = [os.environ.get('BBCONNECT', ''),
             os.path.join(os.path.expanduser('~'), 'priv-research', 'bbndk-tools',
                          'host_10_3_1_12', 'win32', 'x86', 'usr', 'bin', 'blackberry-connect'),
             os.path.join(os.path.expanduser('~'), 'priv-research', 'bbndk-tools',
                          'host_10_3_1_12', 'win32', 'x86', 'usr', 'bin', 'blackberry-connect.bat')]
    for c in cands:
        if c and os.path.isfile(c): return c
    raise FileNotFoundError('blackberry-connect not found; set BBCONNECT=')

def start_tunnel(pub):
    b = find_connect()
    pw = os.environ.get('BBDEVPW', '')
    if not pw: pw = getpass.getpass("Dev-Mode device password: ")
    if not pw: log("[tunnel] no password (exit 3)"); return False
    log(f"[tunnel] starting blackberry-connect (fresh key push) ...")
    logfile = os.path.join(tempfile.mkdtemp(prefix='bb_apply_'), 'conn.log')
    cmd = [b, HOST, '-password', pw, '-sshPublicKey', pub]
    proc = subprocess.Popen(cmd, stdout=open(logfile, 'w'), stderr=subprocess.STDOUT)
    for _ in range(90):
        time.sleep(2)
        if port_open(tries=1, wait=0): log("[tunnel] sshd UP"); return True
        if proc.poll() is not None:
            log(f"[tunnel] exited rc={proc.returncode}"); return False
    log("[tunnel] gave up (exit 3)"); return False

def main():
    if not os.path.isfile(PATCHED):
        log(f"[fatal] patched btool not found: {PATCHED}"); return 7
    with open(PATCHED, 'r') as f: patched_content = f.read()
    if '/proc/boot/pathtrust !/base/bin/__root' not in patched_content:
        log("[fatal] patched file missing the whitelist line"); return 7

    # fresh key + tunnel
    _, pub, k = fresh_key()
    if not port_open(p=4455): log("[door] 4455 closed (exit 3)"); return 3
    if not port_open():
        if not start_tunnel(pub): return 3
    else: log("[ssh] reusing tunnel")

    c = paramiko.SSHClient(); c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        c.connect(HOST, PORT, username=USER, pkey=k,
                  disabled_algorithms=DISABLED, timeout=30, auth_timeout=120,
                  banner_timeout=30, allow_agent=False, look_for_keys=False)
    except Exception as e:
        log(f"[ssh] connect failed: {e} (exit 3)"); return 3
    log(f"[ssh] CONNECTED as {USER}@{HOST}:{PORT}")

    def R(cmd, t=25):
        _, o, e = c.exec_command(cmd, timeout=t)
        return (o.read() + e.read()).decode(errors='replace')

    BTOOL = "/apps/sys.android.gYABgKAOw1czN6neiAT72SGO.ns/native/system/xbin/btool"

    # 1. verify btool exists and is writable
    log(f"[1] checking {BTOOL} ...")
    o = R(f"ls -la {BTOOL} 2>&1")
    print(o.rstrip())
    if 'No such file' in o:
        log("[fatal] btool not found at expected path"); c.close(); return 5

    # 2. backup stock
    log("[2] backing up stock btool ...")
    o = R(f"cp {BTOOL} {BTOOL}.stock.bak 2>&1 && ls -la {BTOOL}.stock.bak")
    print(o.rstrip())

    # 3. write patched
    log("[3] writing patched btool (line 31: !__root) ...")
    o = R(f"cat > {BTOOL} <<'BTOOLEOF'\n{patched_content}\nBTOOLEOF\n"
          f"chmod 755 {BTOOL} 2>&1")
    print(o.rstrip() if o.strip() else "(written)")

    # 4. verify
    log("[4] verifying line 31 on-device ...")
    o = R(f"sed -n '31p' {BTOOL} 2>&1")
    print(f"  line 31: {o.strip()}")
    if '/proc/boot/pathtrust !/base/bin/__root' not in o:
        log("[fatal] line 31 missing after write"); c.close(); return 6

    # 5. full grep sanity
    o = R(f"grep -n '__root' {BTOOL} 2>&1")
    print("  all __root lines:\n  " + o.strip().replace('\n', '\n  '))

    c.close()
    log("\n[SUCCESS] btool patched on-device. Line 31 carries !__root whitelist.")
    log(">>> REBOOT THE DEVICE MANUALLY NOW, wait ~60s, then re-run bb_reroot.py")
    return 0

if __name__ == '__main__':
    try: sys.exit(main())
    except SystemExit as e: sys.exit(e.code)
    except Exception as e: log(f"[fatal] {e}"); sys.exit(7)