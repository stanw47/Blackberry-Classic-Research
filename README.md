# BlackBerry Classic (SQC100 / Q20) — Research

> Root, boot-chain, eMMC, and **Android-runtime-port** research on the BlackBerry
> **Classic** (BB10 / QNX, MSM8960). The Classic is the reference BB10 device for
> this collection.
>
> Part of the **[Blackberry-Research](https://github.com/stanw47/Blackberry-Research)**
> collection. Cross-device mechanisms live in the hub; this repo is Classic-specific.

---

## Disclaimer

> **Research aid, not a flashing guide.** Editing eMMC boot partitions
> (`boot0`/`boot1`) or toggling write-protect can **permanently brick** the
> device with no recovery short of JTAG/ISP chip-out. For educational /
> defensive research on devices the author owns. **At your own risk.**

---

## Status

| Field | Value |
|---|---|
| Device / model | BlackBerry Classic (SQC100, "Q20") |
| SoC | Qualcomm MSM8960 (Snapdragon S4 Plus, secboot3), HWID `0x9700270a` |
| OS / build | BB10 / QNX 8.0.0 (`BLACKBERRY-528E`, CLASSICNA), 10.3.3.3216 |
| Bootloader | locked; boot-partition WP **permanent** (`BOOT_WP[173]=0x04`, `B_PERM_WP_EN`) |
| Root | **real uid-0** (interactive root ksh via `/base/bin/__root`) |
| Access levels reached | **L0 usb, L1 fastboot, L2 adb, L4 qnx** (dev-mode SSH + root) |
| Recovery | Windows `cap.exe` autoloader (works) |
| Status | **rooted, bootable, recoverable**; bootloader unlock is hardware-gated |

**Current state:** The Classic is fully rooted (real uid-0), boots reliably, and
is recoverable via the Windows `cap.exe` autoloader. The remaining device goal —
a bootloader unlock — is blocked by a **permanent hardware write-protect** on the
boot partitions. The **A11-on-QNX runtime port** (a separate, ongoing effort) is
developed on this device.

---

## TL;DR

- **Real uid-0 works.** The getroot autoloader's `btool` runs as root at boot;
  adding `/proc/boot/pathtrust !/base/bin/__root` (btool line 31) makes the
  setuid `__root` helper trusted **every boot** → interactive root ksh.
- **eMMC is readable without desoldering** via the setgid group wrapper
  `g_Disk_Drivers`; `boot0`/`boot1`/`nvram0`/`dmi0` were dumped.
- **The unlock wall is hardware.** `BOOT_WP[173] = 0x04` (`B_PERM_WP_EN`,
  permanent) is re-applied by SBL1 every boot; the software lane is closed
  (NVRAM power-cycle ritual fails; raw `CMD6`/`VUC_CMD` unavailable).
- **Classic is MSM8960**, so the public `imggen` prototype-bootloader unlock
  (MSM8974-only, used on the Passport) **does not apply**.
- **A11-on-QNX port:** a from-scratch effort to run Android 11 on QNX while
  keeping the microkernel — the bionic shim runs on-device; binder and the A11
  native chain are the current frontier.

---

## Key findings

*Numbered, stable — append only. Each links to detail.*

1. **Real uid-0** via the pathtrust whitelist trick
   (`/proc/boot/pathtrust !/base/bin/__root`). → [`notes/session7o-classic-real-root.md`](notes/session7o-classic-real-root.md)
2. **Root payload** = the `btool` autorun (getroot autoloader), reachable via the
   `/base/scripts/ota_info_pps.sh` symlink; runs as root at boot.
   → [`cross-device/bb10-root-pathtrust.md`](https://github.com/stanw47/Blackberry-Research/blob/main/cross-device/bb10-root-pathtrust.md)
3. **eMMC read without desolder** via `g_Disk_Drivers` (group wrapper).
   → [`notes/session7j-classic-emmc-access.md`](notes/session7j-classic-emmc-access.md)
4. **boot0/boot1 are permanently write-protected**; `uda0`/`os0`/`dmi0` writable.
   → [`notes/session7l-boot0-writeprotect.md`](notes/session7l-boot0-writeprotect.md)
5. **QNX MMC devctl interface decoded** (`WRITE_PROTECT=0xC0201A11`,
   `VUC_CMD=0xC0441A16`, `CARD_REGISTER=0xC0181A14`).
   → [`notes/session7r-sdmmc-driver-re.md`](notes/session7r-sdmmc-driver-re.md)
6. **`/proc/<pid>/as` patching:** `.data`/`.bss` writable, `.text` read-only;
   cross-process writes return errno 312 (trust boundary).
   → [`notes/session7t-proc-as-patching.md`](notes/session7t-proc-as-patching.md)
7. **`/dev/mem` on the Passport is a decoy** (relevant comparison). See Passport repo.
8. **A11-on-QNX runtime port** — see the dedicated section below.

---

## A11-on-QNX runtime port

**Goal:** build **our own Android 11 runtime on QNX** — graft/rewrite the runtime
while keeping the QNX microkernel and the BB10 layer, reproducing RIM's porting
layer from AOSP 11. (The factory BB10 Android "Player" is 4.3; it is the
specimen, not the target.)

**Workstreams:** `ws1/` (bionic-on-QNX shim), `binder/` (A11 binder resmgr),
`graphics/` (gralloc), `graft/`, `runtime/` (assembly), `sysroot/`, `specimens/`,
`ref/` (AOSP 11 reference, not committed).

**State (from `ws1/STATUS.md`, `runtime/README.md`, notes 66–72):**

| Piece | State |
|---|---|
| WS1 bionic shim `libc.so` (1759 exports, 0 TEXTREL, PIC) | ✅ **runs on-device** |
| ELF trust markers (e_flags `0x5000202`, `.note` QNX, interp `/proc/boot/libc.so.3`) | ✅ pass the QNX trust gate |
| `libm.so`/`libdl.so` stubs | ✅ |
| A11 native chain (`libbinder`/`libutils`/…) compiles + QNX-links | ✅ loads |
| `binder` resmgr | ⛔ `resmgr_attach` → EPERM (path-manager identity) |
| A11 userland (`zygote`, ART, framework) | ⏳ blocked on AOSP header tree |

Full trail: [`notes/session22–41`](notes/), [`notes/session66–72`](notes/),
[`runtime/README.md`](runtime/README.md), [`ws1/STATUS.md`](ws1/STATUS.md).

---

## How to connect

BB10 uses **Dev-Mode SSH over USB** (not ADB):

1. Enable Dev Mode on the device; note the device password.
2. Generate a **fresh 4096-bit RSA key every session** (the device wipes keys).
3. Start the tunnel:
   `blackberry-connect 169.254.0.1 -password <pw> -sshPublicKey <key.pub>`.
4. SSH as `devuser` via paramiko with QNX fixes (`server_sig_algs=False`;
   disable `rsa-sha2-*`).

Root: pipe commands to `/base/bin/__root` (trusted via btool line 31).
Full guide: [`docs/ssh-connection-linux.md`](docs/ssh-connection-linux.md).

---

## Repository layout

| Path | Contents |
|---|---|
| `notes/` | BB10/Classic session notes (67) — the chronological research trail |
| `docs/` | [`BB10-HARDWARE-SECURITY-REFERENCE.md`](docs/BB10-HARDWARE-SECURITY-REFERENCE.md), [`AUTOLOADER_GUIDE.md`](docs/AUTOLOADER_GUIDE.md), [`compat-runtime-spec.md`](docs/compat-runtime-spec.md), `bb10-analysis/`, `structure/` appendices |
| `recon/` | `classic-audit/` (2026 network audit), `dumps-classic/` (boot0/boot1/nvram0/dmi0), `analysis/`, `resources/` (QNX headers) |
| `tools/` | BB10 tooling: `bblink.py`, `bb_reroot.py`, `bb_uid0.py`, `imggen/`, `passport_stage3`, `listen_flash.py`, `qsh.py`, bar packagers, probes |
| `ws1/ binder/ graft/ runtime/ graphics/ sysroot/ specimens/` | A11-on-QNX port workstreams |
| `ref/` | AOSP 11 reference binaries (**not committed** — see `firmware/FETCH.md`) |
| `work/` | extracted Classic autoloader images (**not committed**) |
| `devmaps/` | Classic device map (schema v1.0) |

---

## Related repos

- **Hub:** [Blackberry-Research](https://github.com/stanw47/Blackberry-Research)
- **Passport** (same BB10 platform): [Blackberry-Passport-Research](https://github.com/stanw47/Blackberry-Passport-Research)
- **Q10** (prototype, same SoC family): [Blackberry-Q10-Research](https://github.com/stanw47/Blackberry-Q10-Research)

---

## References

| Source | URL | Relevance |
|---|---|---|
| bb10.root.sx (Oleksandr) | https://bb10.root.sx | BB10 root, pathtrust, RAM-loader |
| BBAndroids/imggen | https://github.com/BBAndroids/imggen | prototype bootloader (MSM8974) |
| balika011 Passport conversion | https://balika011.hu/blackberry/guides/passport/conversion.php | canonical eMMC unlock |
| MWR QNX Security Whitepaper | https://github.com/alexplaskett/Publications | QNX security model |

---

## License

Research notes and original scripts are provided for educational purposes;
third-party code retains its own license.
