import paramiko, paramiko.transport as T
_orig = paramiko.transport.Transport.__init__
def _new(self,*a,**kw):
    kw['server_sig_algs'] = False
    return _orig(self,*a,**kw)
paramiko.transport.Transport.__init__ = _new
K = paramiko.RSAKey.from_private_key_file('/tmp/bb_key')
def con():
    c = paramiko.SSHClient()
    c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    c.connect('169.254.0.1', 22, username='devuser', pkey=K,
              disabled_algorithms={'pubkeys':['rsa-sha2-512','rsa-sha2-256']},
              timeout=30, auth_timeout=180, banner_timeout=30,
              allow_agent=False, look_for_keys=False)
    return c
def run(c, cmd, timeout=40):
    _,o,e = c.exec_command(cmd, timeout=timeout)
    return (o.read()+e.read()).decode(errors='replace')
