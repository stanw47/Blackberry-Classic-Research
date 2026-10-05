#!/usr/bin/env python3
"""collect_classic_logs.py - READ-ONLY collection of all logs from the BB10
Classic over the Dev-Mode SSH tunnel, to audit for any phone-home / exfil
behaviour. Writes NOTHING to the device.

Focus: everything that could show network traffic going somewhere unexpected:
  - logcat (all buffers), slog2 dumps
  - network/PPS services: connections, routes, ARP, netstat, ss
  - DNS resolver cache/config, established sockets
  - process list + listening sockets
  - sshd/sud/bb_tokenservice/btool activity
  - any scripts referencing URLs / IPs in the rooted userland
"""
import os, sys, socket, tempfile, time
import paramiko
import paramiko.transport as PT

_orig = PT.Transport.__init__
def _patched(self, *a, **kw):
    kw.setdefault('server_sig_algs', False)
    return _orig(self, *a, **kw)
PT.Transport.__init__ = _patched

HOST = os.environ.get('BBHOST', '169.254.0.1')
PORT = int(os.environ.get('BBPORT', '22'))
USER = os.environ.get('BBUSER', 'devuser')
KEY  = os.environ.get('BBKEY', '/tmp/bb_key')
OUT  = os.environ.get('BBOUT', '/home/stanw47/Documents/blackberry-research/classic-audit/2026-10-02')
DISABLED = {'pubkeys': ['rsa-sha2-512', 'rsa-sha2-256']}

os.makedirs(OUT, exist_ok=True)
k = paramiko.RSAKey.from_private_key_file(KEY)
c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect(HOST, PORT, username=USER, pkey=k,
          disabled_algorithms=DISABLED, timeout=30, auth_timeout=120,
          banner_timeout=30, allow_agent=False, look_for_keys=False)
print("[ssh] connected to", HOST)

def run(cmd, t=60):
    _, o, e = c.exec_command(cmd, timeout=t)
    return (o.read() + e.read()).decode(errors='replace')

def save(name, cmd, t=60):
    out = run(cmd, t)
    with open(os.path.join(OUT, name), 'w') as f:
        f.write("### CMD: %s\n### RC-EOF\n%s\n" % (cmd, out))
    print("[saved] %-32s (%d bytes)" % (name, len(out)))
    return out

# --- identity ---
save("uname.txt", "uname -a; cat /proc/version")
save("identity.txt", "getconf _NPROCESSORS_ONLN; pidin info; echo ---; hostname; echo ---; ifconfig -a 2>&1")
save("ifconfig.txt", "ifconfig -a 2>&1")
save("routes.txt", "netstat -rn 2>&1; echo ---ipv6---; netstat -rn -f inet6 2>&1")
save("arp.txt", "netstat -an 2>&1 | head -200; echo ---arp---; arp -a 2>&1")

# --- sockets: established/listening (who is talking to whom) ---
save("netstat_all.txt", "netstat -anv 2>&1")
save("netstat_listen.txt", "netstat -anv 2>&1 | grep -i listen")
save("netstat_estab.txt", "netstat -anv 2>&1 | grep -i estab")
save("pidmap.txt", "pidin -F '%a %p %J %N %U' 2>&1 | head -300")
save("proc_fds_net.txt", "for p in /proc/[0-9]*; do ls -l $p/fd 2>/dev/null | grep -iE 'socket|tcp'; done 2>&1 | head -200")

# --- DNS ---
save("dns_config.txt", "cat /etc/resolv.conf 2>&1; echo ---; cat /pps/services/networking/all/status 2>&1 | head -100; echo ---dns---; ls -la /var/etc/dnsmasq* /etc/hosts 2>&1; cat /etc/hosts 2>&1")
save("dns_cache.txt", "ls -la /var/run/dnsmasq* 2>&1; cat /var/etc/dnsmasq.leases 2>&1; find /var -name '*.dnsmasq*' 2>/dev/null | head")

# --- logcat / slog ---
save("logcat_all.txt", "logcat -d -v threadtime 2>&1 | head -4000")
save("logcat_radio.txt", "logcat -d -b radio -v threadtime 2>&1 | head -2000")
save("logcat_events.txt", "logcat -d -b events -v threadtime 2>&1 | head -1000")
save("slog2_info.txt", "slog2info -a 2>&1 | head -4000")
save("slog2_boot.txt", "slog2info -b boot -a 2>&1 | head -2000")

# --- sshd / auth / root payload activity ---
save("sshd_log.txt", "find /var -name '*sshd*' 2>/dev/null; cat /var/log/sshd* 2>&1 | head; slog2info -a 2>&1 | grep -iE 'sshd|ssh|auth' | head -200")
save("btool_log.txt", "cat /tmp/launcher_patcher.log 2>&1 | tail -200; echo ---; cat /var/log/*sud* 2>&1 | head")
save("tokenservice.txt", "slog2info -a 2>&1 | grep -iE 'token|bbauth|rtas|pcauthtool' | head -200")

# --- the rooted autoloader userland: look for any URL/IP refs ---
save("userland_urls.txt",
     "grep -rIiE 'https?://[a-z0-9./?=_-]+' /accounts/1000/shared/misc /base/scripts /base/bin /accounts/devuser 2>/dev/null | grep -vE 'schemas|w3.org|xml' | head -300")
save("tmp_scripts.txt", "ls -la /tmp 2>&1; echo ---; find /tmp /accounts/devuser /base/scripts -name '*.sh' -o -name '*.py' 2>/dev/null | head -50")
save("sud_py.txt", "cat /base/scripts/sudtools.sh 2>&1 | head -100; echo ---; find / -name 'sud.py' 2>/dev/null | head")

# --- full PPS tree (bb10 exposes services/state here) ---
save("pps_list.txt", "find /pps -type f 2>/dev/null | head -300")
save("pps_networking.txt", "for f in $(find /pps/services/networking -type f 2>/dev/null); do echo \"== $f\"; cat $f 2>&1; done | head -400")

# --- installed apps / telegram specifics ---
save("apps.txt", "ls -la /accounts/1000/appdata 2>&1; echo ---; ls -la /apps 2>&1 | head -40")

c.close()
print("\n[done] all logs in", OUT)
