#!/usr/bin/env python3
# qpull.py - SFTP get/put files from BlackBerry Classic (devuser)
# Usage: python3 qpull.py GET <remote> <local>
#        python3 qpull.py PUT <local> <remote>
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

sftp = c.open_sftp()

mode = sys.argv[1].upper()
if mode == 'GET':
    remote, local = sys.argv[2], sys.argv[3]
    sftp.get(remote, local)
    print(f'GET {remote} -> {local}')
elif mode == 'PUT':
    local, remote = sys.argv[2], sys.argv[3]
    sftp.put(local, remote)
    print(f'PUT {local} -> {remote}')
else:
    print('Usage: qpull.py GET <remote> <local> | PUT <local> <remote>')
    sys.exit(1)

sftp.close()
c.close()