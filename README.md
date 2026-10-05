# BlackBerry Classic (SQC100 / Q20) — Research

> Root, boot-chain, and Android-runtime research on the BlackBerry **Classic**
> (BB10 / QNX, MSM8960).
>
> Part of the **[Blackberry-Research](https://github.com/stanw47/Blackberry-Research)**
> collection. Cross-device mechanisms live in the hub; this repo is Classic-specific.

---

## Disclaimer

> **Research aid, not a flashing guide.** Editing eMMC boot partitions
> (`boot0`/`boot1`) or toggling write-protect can **permanently brick** the
> device with no recovery short of JTAG/ISP chip-out. For educational/defensive
> research on devices the author owns. At your own risk.

---

## Status

| Field | Value |
|---|---|
| Device / model | BlackBerry Classic (SQC100, "Q20") |
| SoC | Qualcomm MSM8960 (Snapdragon S4 Plus) |
| OS / build | BB10 / QNX 10.3.3.3216 (`QNX BLACKBERRY-528E`, CLASSICNA) |
| Bootloader | locked; boot0 write-protect is **permanent** (`B_PERM_WP_EN`) |
| Root | **real uid-0** (interactive root ksh via `__root`) |
| Access levels | L0 usb, L1 fastboot, L2 adb, L4 qnx (dev-mode SSH) |
| Status | **rooted + bootable + recoverable**; bootloader unlock is HW-gated |

**Current state:** The Classic is the reference BB10 device. It is fully rooted
(real uid-0), boots reliably, and is recoverable via the Windows `cap.exe`
autoloader. The remaining goal — a bootloader unlock — is blocked by a
permanent hardware write-protect bit on the boot partitions.

---

## TL;DR

- **Real root works:** the `getroot` autoloader makes `btool` run as root at
  boot; adding `/proc/boot/pathtrust !/base/bin/__root` to `btool` line 31 makes
  the setuid `__root` helper trusted **every boot** → interactive uid-0 ksh.
- **eMMC is readable without desoldering** via the setgid group wrapper
  `g_Disk_Drivers`; `boot0`/`boot1`/`nvram0`/`dmi0` dumped.
- **The unlock wall is hardware:** `BOOT_WP[173] = 0x04` (`B_PERM_WP_EN`,
  permanent), re-applied by SBL1 every boot. The software lane is closed.
- **Android-on-BB10 runtime port** (A11-on-QNX) is developed on the Classic —
  see the hub for the shared mechanism and this repo for the build artifacts.

---

## Key findings

*Numbered, stable — append only.*

1. **Real uid-0** via the pathtrust whitelist trick
   (`/proc/boot/pathtrust !/base/bin/__root`). → [`notes/session7o-classic-real-root.md`](notes/session7o-classic-real-root.md)
2. **Root payload** = `btool` autorun (getroot autoloader), reachable via the
   `/base/scripts/ota_info_pps.sh` symlink; runs as root at boot.
3. **eMMC read without desolder** via `g_Disk_Drivers` (group wrapper).
   → [`notes/session7j-classic-emmc-access.md`](notes/session7j-classic-emmc-access.md)
4. **boot0/boot1 are permanently write-protected**; `uda0`/`os0`/`dmi0` writable.
   → [`notes/session7l-boot0-writeprotect.md`](notes/session7l-boot0-writeprotect.md)
5. **QNX MMC devctl interface** decoded (`WRITE_PROTECT`, `VUC_CMD`, …).
   → [`notes/session7r-sdmmc-driver-re.md`](notes/session7r-sdmmc-driver-re.md)
6. **Classic is MSM8960** — `imggen` (the Passport/Priv unlock tool) is
   MSM8974-only and does **not** apply here. → hub `cross-device/`
7. **A11-on-QNX runtime port** — bionic shim runs on-device; binder resmgr
   blocked on a path-manager ability. → [`docs/`](docs/), [`ws1/`](ws1/), [`binder/`](binder/)

---

## How to connect

Classic uses **BB10 Dev-Mode SSH over USB** (not ADB):

1. Enable Dev Mode on the device; note the device password.
2. Generate a **fresh 4096-bit RSA key** every session (device wipes keys).
3. Start the tunnel: `blackberry-connect 169.254.0.1 -password <pw> -sshPublicKey <key.pub>`.
4. SSH as `devuser` via paramiko with QNX fixes
   (`server_sig_algs=False`, disable `rsa-sha2-*`).

Full guide: [`docs/ssh-connection-linux.md`](docs/ssh-connection-linux.md).
Tooling: hub [`toolchain/`](https://github.com/stanw47/Blackberry-Research/tree/main/toolchain).

---

## Repository layout

| Path | Contents |
|---|---|
| `notes/` | chronological BB10 session notes (the research trail) |
| `docs/` | BB10 hardware/security reference, SSH guide, autoloader guide |
| `recon/` | Classic eMMC dumps, the 2026 network audit, sepolicy parsers |
| `tools/` | Classic/BB10 device-access scripts (`probe_*`, `connect_*`, `ssh_*`) |
| `ws1/ binder/ graft/ runtime/ graphics/ sysroot/` | A11-on-QNX runtime-port workstreams |
| `specimens/ ref/` | reference binaries (AOSP `ref/` is **not committed** — see `firmware/FETCH.md`) |
| `devmaps/` | Classic device map (schema v1.0) |
| `firmware/` | **not committed** — fetch instructions |

---

## Related repos

- **Hub:** [Blackberry-Research](https://github.com/stanw47/Blackberry-Research)
- **Passport:** [Blackberry-Passport-Research](https://github.com/stanw47/Blackberry-Passport-Research)
- **Q10 (prototype):** [Blackberry-Q10-Research](https://github.com/stanw47/Blackberry-Q10-Research)

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
