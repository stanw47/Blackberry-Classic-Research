# Session 38c — Post-Restart Recovery + Device HAL Pull Complete

**Date:** 2026-09-14  
**Status:** QNX SDP extraction BLOCKED (needs 32-bit Java) — Device HAL pull COMPLETE

---

## What Survived the Restart (Persistent)
- **All session notes**: `notes/session38-a11-on-qnx-port-plan.md`, `session38a-repo-audit-a11-ref-status.md`, `session38b-gateA-qnx-sysrout-status.md`
- **Research repo**: `sysroot/`, `specimens/`, `ref/a11_core/`, `binder/`, `graft/`
- **QNX SDP installer**: `~/Downloads/qnxsdp-6.5.0SP1-x86-201206261830-linux.bin` (107 MB)
- **BB10 native tools**: `bb10mt_*.zip` in Downloads

## What Was Lost (tmpfs)
- `/tmp/opencode/` — `qsh.py`, `qpull.py`, `session38b` partial tail, QNX headers (`resmgr.h`, `iofunc.h`, `iomsg.h`)
- `/tmp/z/` — any partial SDP extraction attempt

## QNX SDP 6.5 Extraction — BLOCKED
- Installer is 32-bit i386 InstallShield ELF
- Requires **32-bit Java** (`-is:javahome <32bit JRE>`)
- Host has only 64-bit OpenJDK 25 → installer aborts
- `7z` extracts only a tiny `Verify.class` stub (the real payload stays embedded)
- **Fix needed:** install 32-bit JRE (e.g., `openjdk-8-jre:i386`) or extract on another machine

## Device Connection — RESTORED
- `blackberry-connect` running (PID 6998, port 4455 → key push → port 22 opened)
- SSH as `devuser` with fresh 4096-bit key works
- Root via `/base/bin/__root` confirmed working

## Device HAL Pull — COMPLETE (13/13)
All QNX-adapted Android 4.3 HALs pulled from `/apps/sys.android.gY*/native/system/lib/hw/` via:
1. `qsh.py` (root): `cp /apps/.../hw/*.so /tmp/`
2. `qpull.py` (SFTP as devuser): GET each `/tmp/*.so` → `specimens/device_hals/`

| HAL | Size | ELF |
|-----|------|-----|
| audio.primary.default.so | 13,944 | ARM 32-bit EABI5 soft-float |
| audio_policy.default.so | 9,716 | ARM 32-bit EABI5 soft-float |
| bluetooth.default.so | 164,616 | ARM 32-bit EABI5 soft-float |
| camera.default.so | 275,448 | ARM 32-bit EABI5 soft-float |
| gps.default.so | 14,096 | ARM 32-bit EABI5 soft-float |
| gralloc.Adreno.so | 14,184 | ARM 32-bit EABI5 soft-float |
| gralloc.SGX.so | 14,176 | ARM 32-bit EABI5 soft-float |
| gralloc.default.so | 9,996 | ARM 32-bit EABI5 soft-float |
| hwcomposer.default.so | 5,536 | ARM 32-bit EABI5 soft-float |
| keystore.default.so | 9,760 | ARM 32-bit EABI5 soft-float |
| local_time.default.so | 5,524 | ARM 32-bit EABI5 soft-float |
| power.default.so | 5,504 | ARM 32-bit EABI5 soft-float |
| sensors.default.so | 10,732 | ARM 32-bit EABI5 soft-float |

All are **ARM 32-bit, EABI5, soft-float** — matches Classic's QNX ABI (flags `0x5000200`).

## New Persistent Tools (in repo)
- `tools/qsh.py` — run commands as root via SSH + `__root`
- `tools/qpull.py` — SFTP get/put as devuser

## Next Actions
1. **Unblock SDP extraction** — install 32-bit JRE or extract elsewhere → get full QNX headers + `qcc`
2. **WS1 (bionic re-export map)** — map A11 bionic exports against 4.3 `libbionic.so` 403-export table
3. **WS7 ground-truth** — analyze pulled HALs for QNX-specific adaptations (gralloc.SGX/Adreno paths)
4. **Resume WS2/WS3/WS4** — binder, libutils/cutils, liblog — now that device tools are restored