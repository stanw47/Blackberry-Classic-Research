# Session 38d — BB10MT Analysis + Autoloader + BAR Tools Ready

**Date:** 2026-09-14  
**Status:** BB10MT tools analyzed (firmware flasher, not .bar extractor); Autoloader 3GB PE32 contains gzipped QNX images + .bar files; **BAR toolchain now operational**

---

## BB10MT Multi-Tool Analysis

**Files examined:** 4 zip archives in `~/Downloads/`
| Archive | Size | Key Contents |
|---------|------|--------------|
| `bb10mt_alpha.zip` | 17 MB | `bb10mt` (Linux ELF), `bb10mt.exe`, `loaders.dat` (5.8 MB), macOS binaries |
| `bb10mt_v0.1.0.10.zip` | 9 MB | `bb10mt`, `bb10mt.exe`, `loaders/` (26 loader binaries) |
| `bb10mt_v0.2.1.3.zip` | 10 MB | `bb10mt`, `bb10mt.exe`, `loaders/` (70+ loader binaries) |
| `bb10mt.zip` (latest, Dec 2025) | 17 MB | Same as alpha + macOS |

**Finding:** `bb10mt` is a **firmware flashing tool** (like Odin/Heimdall for Samsung), not a .bar extractor. It loads bootloaders (`loader_*.bin`) onto devices via USB (requires libusb). All versions fail with "Couldn't load dynamic library libusb" — Pascal binary dlopen's `libusb` with hardcoded name.

**Use case:** Flashing autoloader payloads to device, **not** extracting .bar files.

---

## Autoloader (Z30_10.3.03.3216_STA100-1-2-3-4-5-6-root_v2.exe)

**File:** 3.07 GB, PE32 Windows console executable (self-extractor)

**Binwalk findings:**
- 6 large gzip streams at offsets 0x1C5B10–0x1F0930 (hundreds of MB each)
- Multiple .bar file references in strings:
  - `sys.data.ecid*.config.bar` (carrier/modem configs)
  - `sys.data.carrier_data.bar`
  - Many more `sys.data.*.bar` entries

**Extraction challenges:**
- 7z cannot open as archive
- Binwalk `-e` times out on 3 GB file
- Manual `dd` of gzip streams truncated (streams are >>1 MB)
- Wine not available to run Windows extractor

**Android runtime .bar files:** Not yet located by name in strings. Likely named `sys.android.*.bar` or similar, embedded in the gzip payloads.

---

## BAR Toolchain — NOW OPERATIONAL (in `tools/`)

| Tool | Wrapper | JAR | Status |
|------|---------|-----|--------|
| **BarPackager** | `blackberry-bar-packager` | BarPackager.jar 1.6.4 | ✅ Works |
| **BarSigner** | `blackberry-bar-signer` | BarSigner.jar 3.1.1 | ✅ Works |
| **BarDeploy** | `blackberry-bar-deploy` | BarDeploy.jar | ✅ Created |
| BarChecker | — | BarChecker.jar | Available |

**Capabilities:**
- Create/verify BAR manifests (`-generatemanifest`, `-verifymanifest`)
- Package BAR files from folders (`-package`)
- Sign BAR files with developer certificates (`-storepass`, `-bbidtoken`)
- Deploy BAR files to device (`blackberry-bar-deploy`)

---

## Current Asset Inventory

### Persistent in Repo
- `tools/qsh.py` — root command execution via SSH + `__root`
- `tools/qpull.py` — SFTP get/put as devuser
- `tools/blackberry-bar-*` — BAR create/sign/deploy
- `specimens/device_hals/` — 13 QNX-adapted HALs (ARM32 soft-float)
- `sysroot/target/lib/` — `libc.so.3`, `libstdc++.so.6`, `libimg.so.1`
- `sysroot/target/include/` — `resmgr.h`, `iofunc.h`, `iomsg.h`
- `ref/a11_core/` — 18 AOSP 11 natives (ART, binder, base, utils, EGL, GLES)
- `binder/` — 23/23 tests passing

### External (Downloads)
- QNX SDP 6.5.0 SP1 installer (107 MB) — **blocked by 32-bit Java**
- BB10MT tools (4 versions) — firmware flasher, not .bar extractor
- Autoloader (3.07 GB) — contains .bar files, extraction pending
- LineageOS 18.1 (AOSP 11) system.img — golden reference

---

## Critical Gaps Remaining

| Gap | Blocker | Resolution Path |
|-----|---------|-----------------|
| **QNX SDP headers + `qcc`** | 32-bit Java needed for installer | Install `openjdk-8-jre:i386` OR extract on another machine |
| **Android runtime .bar files** | Buried in 3 GB autoloader gzip streams | 1. Extract autoloader gzip streams fully<br>2. Search for `sys.android.*.bar` |
| **Complete 4.3 runtime map** | Only partial natives in `specimens/` | Extract runtime .bar → full filesystem |
| **Binder transaction traces** | Only unit tests, no live captures | Use `qsh.py` to trace live binder on device |

---

## Next Actions (Priority Order)

1. **Unblock QNX SDP extraction** — Install 32-bit JRE (`sudo apt install openjdk-8-jre:i386` if possible) or extract on separate machine → copy `target/*/usr/include/` + `qcc` to `sysroot/target/`

2. **Extract Android runtime .bar from autoloader** — Two paths:
   - **Path A:** Use `binwalk -e` with more time/resources, or `dd` full gzip streams at known offsets
   - **Path B:** Search autoloader strings for `sys.android` .bar names, then carve those specific blobs

3. **Once .bar obtained:** Use `blackberry-bar-packager -verifymanifest` and `-package` to inspect/extract contents → full Android 4.3 runtime filesystem

4. **WS1 (bionic re-export map)** — With QNX headers + `qcc`, compile stubs mapping A11 bionic exports → QNX libc

5. **Live device binder tracing** — Use `qsh.py` + `libbinder` debug hooks to capture real transaction flows

---

## Quick Commands Reference

```bash
# Device connection (run each session)
pkill -f Connect.jar
ssh-keygen -t rsa -b 4096 -f /tmp/bb_key -N "" -q
cp /tmp/bb_key ~/Documents/blackberry-research/id_rsa
nohup ~/priv-research/bbndk-tools/host_10_3_1_12/win32/x86/usr/bin/blackberry-connect \
  169.254.0.1 -password 61482501 -sshPublicKey /tmp/bb_key.pub > bb_connect.log 2>&1 &
sleep 20 && pgrep -af Connect.jar

# Root exec
BBKEY=/tmp/bb_key python3 tools/qsh.py "cmd"

# SFTP
BBKEY=/tmp/bb_key python3 tools/qpull.py GET /remote/path /local/path

# BAR tools
tools/blackberry-bar-packager -verifymanifest META-INF
tools/blackberry-bar-signer -verify app.bar
tools/blackberry-bar-deploy -installApp -device 169.254.0.1 -password 61482501 app.bar
```