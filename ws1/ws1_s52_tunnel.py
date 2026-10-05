#!/usr/bin/env python3
# ws1_s52_tunnel_restart.py — rebuild the Connect.jar tunnel per docs/linux recipe
# (fresh 4096 RSA key, detached Connect.jar, wait-for-4455->22), then exec the
# static Type-EXEC payload. Written via write tool => no heredoc mangling.
import subprocess, os, sys, time, signal

DEV_IP  = "169.254.0.1"
PASS    = "61482501"  # per deploy/bb.py
KEYDIR  = "/tmp/bb_key"
CONJAR  = "/home/stanw47/priv-research/bbndk-tools/host_10_3_1_12/win32/x86/usr/bin/blackberry-connect"
LOG     = "/tmp/bb_connect_s52.log"

def sh(c, t=120):
    r = subprocess.run(c, shell=True, capture_output=True, text=True, timeout=t)
    return r

print("== 1. fresh key (4096 min per docs) ==", flush=True)
for f in ("/tmp/bb_key", "/tmp/bb_key.pub"):
    if os.path.exists(f): os.remove(f)
r = sh("ssh-keygen -t rsa -b 4096 -f /tmp/bb_key -N '' -q")
print("   keygen_rc=" + str(r.returncode), flush=True)

print("== 2. restart tunnel (kill stale, detach fresh) ==", flush=True)
sh("pkill -f Connect.jar; sleep 3")
bd = open(LOG, "w")
proc = subprocess.Popen(
    ["java", "-Xmx512M", "-jar", CONJAR, DEV_IP, "-password", PASS,
     "-sshPublicKey", "/tmp/bb_key.pub"],
    stdout=bd, stderr=bd, start_new_session=True)
print("   Connect.jar pid=" + str(proc.pid), flush=True)

print("== 3. wait for port 22 (btool seq) up to 40s ==", flush=True)
up = False
for i in range(20):
    time.sleep(2)
    try:
        subprocess.run(["timeout","2","bash","-c","echo > /dev/tcp/169.254.0.1/22"], check=True, capture_output=True)
        up = True; break
    except Exception:
        pass
print("   port22_up=" + str(up), flush=True)
print("== connect log tail ==", flush=True)
print("   " + (open(LOG).read().strip().splitlines()[-1:] or ["(empty)"])[0][:120], flush=True)
print("S52_TUNNEL_OK" if up else "S52_TUNNEL_FAIL", flush=True)
