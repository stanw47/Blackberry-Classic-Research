#!/usr/bin/env python3
# qsh.py - run commands as root on BlackBerry Classic via SSH + __root
import paramiko, os, sys
import paramiko.transport as P

_orig = paramiko.transport.Transport.__init__
def _new(self, *a, **kw):
    kw.setdefault('server_sig_algs', False)
    return _orig(self, *a, **kw)
paramiko.transport.Transport.__init__ = _new

KEY = os.environ.get('BBKEY', '/tmp/bb_key')
key = paramiko.RSAKey.from_private_key_file(KEY)
c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect('169.254.0.1', 22, username='devuser', pkey=key,
          disabled_algorithms={'pubkeys': ['rsa-sha2-512', 'rsa-sha2-256']},
          timeout=30, auth_timeout=120, banner_timeout=30,
          allow_agent=False, look_for_keys=False)

for cmd in sys.argv[1:]:
    full = f'echo "{cmd}" | /base/bin/__root'
    stdin, stdout, stderr = c.exec_command(full, timeout=60)
    out = stdout.read().decode(errors='replace')
    err = stderr.read().decode(errors='replace')
    if out:
        print(out.rstrip())
    if err:
        print('[stderr]', err.rstrip(), file=sys.stderr)

c.close()