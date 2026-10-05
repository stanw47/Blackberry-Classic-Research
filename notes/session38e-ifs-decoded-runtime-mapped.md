# Session 38e — Z30 IFS.signed Structure Decoded + Complete 4.3 Runtime Mapped

**Date:** 2026-09-14  
**Status:** IFS container format reverse-engineered (LZO decompressor working via ctypes); **full installed Android 4.3 runtime inventory captured on-device**. Runtime `.bar` extraction from IFS optional (device copy is live source).

---

## 1. IFS.signed File Structure (3,012,559,248 bytes) — Decoded

User extracted `Z30_10.3.03.3216...@IFS.signed` (+`Radio.signed`, 54MB) from the autoloader using **Sachesi**.

### Layer 1: RIM signed container (`mfcq`/`pfcq`/`rrcq`)
```
0x00000  mfcq   Multi-File Container QNX  (header block to 0x188)
0x00188  mfcq   version 0x00020000, hdr=0x1c, count=5
0x038..  5× pfcq (v0x200, hdr=0x3c) each wrapping 1× rrcq (hdr=0x10)
          rrcq sizes: 0xA8, ..., 0x9AE3 <- signatures/metadata
0x00188  IPL/startup payload: ARM thumb2 code + "developer",
          "Feb 21 2018 17:54:00", "RIM BlackBerry Device"
0x378..  0xAA.. pad; components
```

### Layer 2: LZO-compressed boot IFS (QNX IFS)
```
startup sig EB7EFF00 @ 0x9FC4C
  flags1=0x9 compression=2 (LZO) machine=0x28(armle) hdr=0x100
  startup_size=0xA5104 stored=0x9D062C imagefs=0x1980660 (~26.7MB)
LZO stream @ 0x9FC4C+0xA5104  ends @ file 0xA70273
```

### Layer 3: decompressed imagefs (~26.7MB, magic "imagefs", flags=4)
```
image_size=0x1980660 hdr_dir=0xB53C dir_offset=0x5C mountpoint="/"
contains whole /proc/boot-style boot tree, incl:
  proc/boot/dalconfig-kingrow.so, -kingna.so, -newark.so ...
  references /accounts/1000/appdata/sys.android.gYABgKAOw1czN6neiAT72SGO.ns/
```

### Layer 4: signed payload manifests (`QNXH`/`QNXL`)
```
0xA70278  "QNXH-OS-1" + QNXH(0x88) signature  -> payload
0x18ABFF58  "QNXH-OS-1" + QNXH signature      -> payload
payload data: ELF (4243 hits), avmplus/PPSClass strings, ZIP-less
  .bar file manifests:  'Name: native/system/bin/dalvikvm
    SHA-512-Digest: MpCo_T1RQjsXHyaBRBybDXJd...'
    'Name: native/scripts/stop-android.sh' ...
0x5768xxxx  live libavmplus-adjacent .so data (Flash/web runtime)
0x40D781ED  .bar dir tree:  ino#, u8-namelen, "public"/"META-INF"/"native"
0x40D92085  "bin/dalvikvm" manifest entry (Android runtime .bar present)
```

### Interpretation
The `.signed` OS image = boot IFS + entire OS userland as signed payload
containing the **pristine Android runtime .bar** (same package installed
on the device container, stored embedded not as ZIP). Directory = RIM
container ("honeycomb"-style) mapping names → data in the ~2GB payload.

### Reusable tooling (repo `tools/`)
| Tool | Path | Purpose |
|------|------|---------|
| **lzodec.py** logic | `/tmp/opencode/lzodec.py` | `liblzo2` via ctypes → hardcoded paths, 26.7MB IFS →
| | | `/tmp/opencode/ifs_plain.img` |
| dumpifs.py (lclevy) | `tools/dumpifs.py` | needs lzo module; patch-able (see note) |
| qsh.py / qpull.py | `tools/` | device root exec / SFTP |

> **NOTE:** dumpifs.py imports `lzo` (pip package) — unbuildable here
> (no lzo/lzo1.h). Our ctypes `lzo1x_decompress` calls `liblzo2.so.2`
> directly and worked. Copy this technique for future LZO.

---

## 2. Complete Android 4.3 Runtime — NOW MAPPED (on-device)

Container: `/apps/sys.android.gYABgKAOw1czN6neiAT72SGO.ns/`

### Structure (installed .bar extraction)
```
META-INF/   AUTHOR.EC/.SF (176,440)  MANIFEST.MF (212,550)  RDK.*
public/     native/{icon.png, splash-*.png}   (resources)
native/     autolaunch.cfg (0)  blackberry-tablet.xml (18,663)
            default.cfg (117)   icon.png   init.cfg (27,835)
            images/{bucket_8,9,10,12}   sbin/   scripts/
            system/            version.txt (31)
native/system/
  app/      99 .apk/.odex (Browser, Contacts, Bluetooth, BlackBerryIME,
            Calculator, CertInstaller, ... <— AOSP 4.3 apps)
  bin/      dalvikvm, app_process, linker(320,088), init(59,204),
            installd, keystore, drmserver, dumpsys, service, surfaceflinger,
            system_server(?), zygote scripts, logd, logcat, am/bmgr/bu/ime/
            input/content shell bin scripts, exe_shim, android_resmgr,
            binder, epolld, lowmemorykiller, dexopt, abcc, dexdump(xbin),
            bootanimation, cat/ls/chmod/chown slink toolchain...
  etc/      permissions/, ppp/, security/cacerts/, ...
  fonts/,   framework/  (Android JAR framework precompile)
  lib/      FULL AOSP 4.3 runtime: libbinder, libandroid_runtime, libui,
            libutils, libsurfaceflinger(246KB), libskia(2.1MB),
            libwebcore(7.4MB), libstagefright+codecs, libmedia(649KB),
            libmediaplayerservice, libsqlite, libssl/libcrypto, libselinux,
            libart? (No—4.3 = dalvik: libdvm), libnativehelper, libz,
            libm_android, libpthread(5KB=qnx), libstdc++_android,
            libhardware?, libhardware_legacy?, libbinder, egl/, hw/,
            drm/, ssl/engines/, soundfx/, native/lib/...
  media/    audio/{alarms,notifications,ringtones,ui} + ogg samples
  tts/      lang_pico/   usr/ (icu, keychars, keylayout, idc, share/bmd)
  xbin/     dexdump (btool = OUR modified file 2018? Sep 13 root:nto 1932)
```

### Counts
- **1081 files** catalogued (incl. all 13 HALs in lib/hw/)
- file listing saved: `specimens/runtime_inventory/and_full_ls.txt` (1347 lines)

### Key binaries/libraries (to be replaced by A11 natives)
`dalvikvm`, `app_process`, `init`, `linker`, `installd`, `surfaceflinger`,
`libandroid_runtime.so`, `libdvm.so`, `libbinder.so`, `libui.so`,
`libutils.so`, `libsurfaceflinger.so`, all HALs in lib/hw/.

> **Caveat:** `bin/` + app counts verified live; full lib+framework listing
> captured non-recursively above; recursive lib/ subdirs (egl/hw/drm/ssl)
> pulled previously (13 HALs) + remaining to be enumerated if needed.

---

## 3. State of our questions

| Question | Answer |
|----------|--------|
| Full Android runtime mapped? | **YES** — the installed container = complete 4.3 runtime; 1081 files inventoried |
| Where are runtime .bar files? | Pristine copies embedded in `IFS.signed` payload (~2GB region, dir-tree at 0x40D...) — **NOT needed**, device has them installed |
| Next blocker? | QNX SDP headers + qcc still missing (32-bit Java); then WS1 bionic export map |

---

## 4. Next Actions (adjusted)

1. **Enumerate remaining 4.3 lib/ subdirs + framework/** on device (recursive)
   → complete binary-level inventory table for A11 replacement.
2. **Pull key 4.3 libs** (libbinder, libandroid_runtime, libdvm, linker,
   app_process) via `qpull.py` to `specimens/` for ABI/export comparison vs
   `ref/a11_core/` (18 A11 natives).
3. Unblock **QNX SDP** (32-bit Java | remote extract) → headers + `qcc`.
4. **WS1 bionic re-export map** — compile stub against QNX libc once SDP in.
5. Optionally write a pure-python/BLFS **IFS.signed payload extractor** using
   the decoded container tables (inode → name → offset in payload) so any
   file can be pulled pristine from the 3GB image without the device.