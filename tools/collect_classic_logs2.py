#!/usr/bin/env python3
"""collect_classic_logs2.py - READ-ONLY. QNX-native (no head/tail/grep -r limits)."""
import os
import paramiko
import paramiko.transport as PT
_o = PT.Transport.__init__
def _p(self, *a, **kw):
    kw.setdefault('server_sig_algs', False); return _o(self, *a, **kw)
PT.Transport.__init__ = _p
HOST='169.254.0.1'; PORT=22; USER='devuser'; KEY='/tmp/bb_key'
OUT='/home/stanw47/Documents/blackberry-research/classic-audit/2026-10-02'
DISABLED={'pubkeys':['rsa-sha2-512','rsa-sha2-256']}
os.makedirs(OUT, exist_ok=True)
k=paramiko.RSAKey.from_private_key_file(KEY)
c=paramiko.SSHClient(); c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect(HOST,PORT,username=USER,pkey=k,disabled_algorithms=DISABLED,
          timeout=30,auth_timeout=120,banner_timeout=30,allow_agent=False,look_for_keys=False)
print("[ssh] connected")
def run(cmd,t=90):
    _,o,e=c.exec_command(cmd,timeout=t); return (o.read()+e.read()).decode(errors='replace')
def save(name,cmd,t=90):
    out=run(cmd,t)
    open(os.path.join(OUT,name),'w').write("### CMD: %s\n%s\n"%(cmd,out))
    print("[saved] %-28s %6d bytes"%(name,len(out))); return out

# full netstat (no head)
save("netstat_full.txt","netstat -anv 2>&1")
save("netstat_n.txt","netstat -an 2>&1")
# PPS tree without head
save("pps_all.txt","find /pps -type f 2>&1")
# networking pps
save("pps_net.txt","find /pps/services/networking -type f -exec sh -c 'echo == $1; cat $1' _ {} \\; 2>&1")
# slog2 (BB10 log service) - correct binary is slog2info
save("slog2_a.txt","slog2info 2>&1")
save("slog2_verbose.txt","/base/bin/slog2info -a 2>&1")
# logcat equivalents on BB10: use slog2info + /var/log
save("varlog.txt","ls -la /var/log 2>&1")
save("dmesg.txt","dmesg 2>&1")
# processes via pidin
save("pidin.txt","pidin -F '%b %N %J %a' 2>&1")
save("pidin_ar.txt","pidin ar 2>&1")
# DNS / resolv
save("resolv.txt","cat /etc/resolv.conf 2>&1; echo ==hosts==; cat /etc/hosts 2>&1")
# sockets per process (who owns which socket)
save("fds.txt","for p in /proc/[0-9]*; do echo \"== $p\"; ls -l $p/fd 2>&1; done 2>&1")
c.close(); print("[done]")
