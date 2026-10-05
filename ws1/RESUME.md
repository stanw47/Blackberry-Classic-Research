# WS1 Shim - Resume Point

## Device Status
- **Device**: BlackBerry Classic (SQC100), BB10 10.3.3
- **IP**: 169.254.0.1 (USB/RNDIS)
- **SSH**: devuser@169.254.0.1:22 (RSA 4096, RSA-SHA1 only)
- **Root**: `__root` helper via `/base/bin/__root`
- **Device password**: 61482501
- **blackberry-connect**: Required for SSH (port 4455 → triggers btool → starts sshd on 22)
- **Status**: Device currently offline (SSH connection refused), likely rebooted

## Build Status
```
ws1/
├── build/
│   ├── test_minimal          # Minimal test (1 text relocation) - READY TO TEST
│   ├── test_smoke            # Full dlopen test (3202 text relocations)
│   ├── libc.so               # WS1 shim (1759 exports, 0 missing vs A11)
│   ├── libm.so, libdl.so     # Stub libraries
├── tramps.S                  # 1561 trampolines → ws1_resolver
├── resolver_entry.c          # C resolver (PIC) - has literal pool
├── tramps_resolver.S         # Assembly resolver (SB-relative GOT attempt failed)
├── signal_block.c            # Signal blocking constructor (priority 101)
├── note.S                    # QNX .note (exact dexopt match)
├── start.S                   # _start entry point
├── test_smoke.c              # dlopen libz.so test
├── test_minimal.c            # Minimal write+exit test
├── deploy/bb.py              # SSH deploy script
├── STATUS.md                 # This file
└── deploy/bb.py              # SSH deploy script
```

## Current Binary State
| Binary | Text Relocations | Status |
|--------|------------------|--------|
| test_minimal | 1 (in .text) | **Deployed** - gets EINTR |
| test_smoke | 3202 (in .text) | Built, not tested |

## Trust Gate Status: ✅ PASSED
- ELF trust markers match dexopt exactly:
  - e_flags: 0x5000202 (EABI5 + soft-float + bit 0x2)
  - PT_INTERP: /proc/boot/libc.so.3
  - .note: namesz=4, descsz=8, type=3, name="QNX", desc=0000000000100000
  - ET_DYN (PIE) with -z separate-code (RX/RW separation)
  - Deployed to /apps/.../native/system/bin/ (same dir as dexopt)
  - Permissions: 555, owner apps:apps (matches dexopt)

## Blocker: EINTR in Dynamic Linker
**Error**: "Interrupted function call" (EINTR) when executing test_minimal
- Trust gate PASSED (no EPERM/SIGSEGV)
- Crash occurs in dynamic linker (/proc/boot/libc.so.3) at offset 0x4f8f8
- Crash location: R_ARM_RELATIVE relocation processing loop (disassembly shows `str r3, [r9]` at 0x4f8f8)
- Signal likely SIGSEGV/SIGBUS during relocation processing → converted to EINTR
- **Root cause**: QNX 8.0 ldqnx.so.2 (=/proc/boot/libc.so.3) bug in R_ARM_RELATIVE relocation processing for text segment

## Root Cause Analysis
```
libc.so.3 offset 0x4f8f8:
  4f8f8: e5893000  str r3, [r9]   ; Writing relocated address to target
  4f8fc: eaffffcd  b 0x4f838       ; Loop back for next relocation
```
The dynamic linker crashes when writing relocated addresses to the text segment (RX memory). The kernel likely sends SIGSEGV/SIGBUS for write to RX pages, which gets converted to EINTR.

## Solutions to Try (When Device Returns)
1. **Zero text relocations**: Rewrite resolver to use SB-relative GOT access (no literal pools in .text)
   - Use `ldr r12, [r9, #:GOTOFF:ws1_slots]` (SB-relative GOT access)
   - Or place literal pools in RW segment via linker script

2. **Signal masking in dynamic linker**: Not possible from user space

3. **Alternative interpreter**: Try `/usr/lib/ldqnx.so.2` (same file, different path)

4. **QNX ldqnx source**: Check QNX 8.0 source for relocation loop at 0x4f8f8

## Immediate Next Steps (When Device Returns)
1. Deploy test_minimal (already deployed)
2. Try running with signal masking via `__root` wrapper
3. If EINTR persists, try building with zero text relocations:
   - Fix tramps_resolver.S to use SB-relative GOT access: `ldr r12, [r9, #:GOTOFF:ws1_slots]`
   - Or move literal pools to RW segment via linker script

## SSH Reconnection Procedure
```bash
# 1. Verify device state
ping -c1 169.254.0.1
timeout 2 bash -c 'echo > /dev/tcp/169.254.0.1/4455' && echo "4455 OK"

# 2. If 4455 closed, restart blackberry-connect
pkill -f Connect.jar
ssh-keygen -t rsa -b 4096 -f /tmp/bb_key -N "" -q
nohup /home/stanw47/priv-research/bbndk-tools/host_10_3_1_12/win32/x86/usr/bin/blackberry-connect \
  169.254.0.1 -password 61482501 -sshPublicKey /tmp/bb_key.pub > /tmp/bb_connect.log 2>&1 &
sleep 20 && cat /tmp/bb_connect.log

# 3. Verify port 22
timeout 5 bash -c 'echo > /dev/tcp/169.254.0.1/22' && echo "22 OPEN"

# 4. Test SSH
BBKEY=/tmp/bb_key python3 /home/stanw47/Documents/blackberry-research/ws1/deploy/bb.py
```

## Key Files for Continuation
- `/home/stanw47/Documents/blackberry-research/ws1/` - Complete build tree
- `/home/stanw47/priv-research/bbndk-tools/` - blackberry-connect tool
- `/tmp/bb_key` - SSH private key (4096-bit RSA)
- `/tmp/bb_key.pub` - SSH public key
- `ws1/deploy/bb.py` - Deploy/test script
