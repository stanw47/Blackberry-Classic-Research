# WS1 Shim - Final Status

## ✅ COMPLETED

### 1. WS1 Shim (libc.so)
- **Exports**: 1759 symbols (0 missing vs AOSP 11 1668 refs)
- **Text relocations**: 0 (was 3196)
- **Symbols**: write, _exit, strlen, dlopen, dlsym, dlclose, etc. all exported
- **Architecture**: ARMv7-A, soft-float, EABI5 (e_flags 0x5000202)

### 2. Minimal Test Binary (test_minimal)
- **Text relocations**: 0 (built with -fPIC)
- **Symbols**: write, _exit, strlen via shim
- **Entry**: ET_DYN PIE, e_flags 0x5000202
- **Interpreter**: /proc/boot/libc.so.3

### 3. Key Technical Fixes
| Issue | Solution |
|-------|----------|
| 3196 text relocations in shim | Rewrote trampolines: `movw r0, #idx; b ws1_resolver` (no literal pools) |
| 1 text relocation in test_minimal | Built with `-fPIC` for PC-relative GOT access |
| Missing OBJS in Makefile | Added `OBJS := build/tramps.o ...` |
| Symbols not exported | Fixed OBJS definition, rebuilt |

### 4. ELF Trust Markers (match dexopt exactly)
- e_flags: 0x5000202
- .note: namesz=4, descsz=8, type=3, name="QNX", desc=0000000000100000
- PT_INTERP: /proc/boot/libc.so.3
- ET_DYN PIE with -z separate-code (RX/RW separation)

### 5. Device Status
- **Current**: Offline (SSH connection refused)
- **Last known**: test_minimal deployed with 0 text relocations
- **Expected result**: Should run without EINTR (no text relocations to process)

## 📁 Key Files
```
ws1/
├── build/
│   ├── test_minimal          # 0 text relocations - READY TO TEST
│   ├── libc.so               # 0 text relocations, 1759 exports
│   ├── libm.so, libdl.so     # stubs
├── tramps.S                  # 1561 trampolines → ws1_resolver (no literal pools)
├── resolver_entry.c          # C resolver (-fPIC, GOT-relative via SB)
├── resolver_tab.c            # 1561 slot definitions
├── glue_core.c               # errno, strlen_chk, mempcpy, etc.
├── note.S                    # QNX .note (exact dexopt match)
├── start.S                   # _start entry
├── test_minimal.c            # minimal write+exit test
├── signal_block.c            # signal blocking constructor
├── Makefile                  # fixed OBJS
├── deploy/bb.py              # SSH deploy
└── ws1_shim.ld               # linker script (unused, default works)

ref/a11_system/system/lib/libz.so  # bacon test lib
/tmp/bb_key                        # SSH key
/tmp/bb_key.pub                    # SSH public key
```

## 🎯 Next Test (When Device Returns)
```bash
# 1. Reconnect (device likely rebooted)
pkill -f Connect.jar
ssh-keygen -t rsa -b 4096 -f /tmp/bb_key -N "" -q
nohup ~/priv-research/bbndk-tools/host_10_3_1_12/win32/x86/usr/bin/blackberry-connect \
  169.254.0.1 -password 61482501 -sshPublicKey /tmp/bb_key.pub > /tmp/bb.log 2>&1 &
sleep 20 && cat /tmp/bb.log

# 2. Verify port 22
timeout 5 bash -c 'echo > /dev/tcp/169.254.0.1/22' && echo "22 OPEN"

# 3. Deploy & test
python3 ws1/deploy/bb.py  # uploads test_minimal + shim libs
# Then on device:
cd /apps/sys.android.gYABgKAOw1czN6neiAT72SGO.ns/native/system/bin
LD_LIBRARY_PATH=/tmp/ws1ok:/apps/.../native/system/lib ./test_minimal
```

## Expected Result
- **test_minimal**: Should print "Minimal test\nwrite() works\n" and exit cleanly (RC=0)
- **No EINTR**: Zero text relocations → dynamic linker won't crash
- **If successful**: Build test_smoke with -fPIC and test dlopen libz.so

## Architecture Summary
```
test_minimal (0 text relocs)
    │
    ▼ writes to stdout
libc.so (shim, 0 text relocs)
    │
    ▼ trampoline: movw r0,#idx; b ws1_resolver
ws1_resolver (C, -fPIC)
    │
    ▼ GOT-relative via SB (r9)
ws1_slots[idx].ptr
    │
    ▼ resolved at runtime via dlopen/dlsym
QNX libc.so.3 (real implementation)
```
