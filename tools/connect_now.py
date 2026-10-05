import paramiko, paramiko.transport as PT
_orig = PT.Transport.__init__
def _new(s, *a, **kw): kw.setdefault('server_sig_algs', False); return _orig(s, *a, **kw)
PT.Transport.__init__ = _new
import os
key = paramiko.RSAKey.from_private_key_file("id_rsa")
c = paramiko.SSHClient(); c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect("169.254.0.1", port=22, username="devuser", pkey=key,
          disabled_algorithms={'pubkeys':['rsa-sha2-512','rsa-sha2-256']},
          allow_agent=False, look_for_keys=False, timeout=30, auth_timeout=120)
def R(cmd, t=30):
    _,o,e = c.exec_command(cmd, timeout=t); return (o.read()+e.read()).decode(errors='replace').strip()
def ROOT(cmd, t=30): return R("echo '"+cmd+"' | /base/bin/__root 2>&1", t)
print("=== binder nodes present? ===")
print(ROOT("ls -l /dev/binder; ls -l /dev/container/binder 2>&1", 20))
print("=== devices of pid ===")
print(ROOT("ls -l /dev/*binder* /dev/vndbinder 2>&1", 20))
print("=== container processes ===")
print(ROOT("pidin ar | grep -iE 'container|a11|android|guest' | head -8", 20))
c.close()
