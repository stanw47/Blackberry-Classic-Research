# BlackBerry Classic (SQC100 / Q20) — Research

> Root, boot-chain, eMMC, and **Android-runtime-port** research on the BlackBerry
> **Classic** (BB10 / QNX, MSM8960) — the reference BB10 device for this collection.
>
> Part of the **[Blackberry-Research](https://github.com/stanw47/Blackberry-Research)**
> collection · [Williamson Security Solutions](https://williamsonsecuritysolutions.com)

---

## Disclaimer

> **Research aid, not a flashing guide.** Editing eMMC boot partitions
> (`boot0`/`boot1`) or toggling write-protect can **permanently brick** the
> device with no recovery short of JTAG/ISP chip-out. For educational /
> defensive research on a device the author owns. **At your own risk.**

---

## Device Details

| Field | Value |
|---|---|
| Model | BlackBerry Classic **SQC100** ("Q20") |
| Codename | `classic` |
| SoC | Qualcomm **MSM8960** (Snapdragon S4 Plus, secboot3), HWID `0x9700270a` |
| OS / software | **BB10 / QNX 8.0.0**, `BLACKBERRY-528E`, ClassicNA |
| Current build | **10.3.3.3216** (rooted autoloader) |
| Previous builds | stock 10.3.3; getroot pre-rooted autoloader |
| Carrier / unlock | carrier-unlocked (no SIM lock); bootloader locked |
| SIM | single |

---

## Current Status

The Classic is **fully rooted (real uid-0), boots reliably, and is recoverable**
via the Windows `cap.exe` autoloader. The one device-level goal that remains — a
**bootloader unlock** — is blocked by a **permanent hardware write-protect** on
the boot partitions, so the software lane is closed. Separately, this device hosts
an ongoing **A11-on-QNX runtime port** (run Android 11 on QNX while keeping the
microkernel).

---

## Completed

- **Root:** getroot autoloader + pathtrust whitelist → real uid-0.
- **eMMC access without desoldering:** group wrapper `g_Disk_Drivers`; dumped
  `boot0`, `boot1`, `nvram0`, `dmi0`.
- **Write-protect analysis:** `BOOT_WP[173]` decoded; permanent bit confirmed.
- **QNX MMC driver RE:** devctl constants and WP handler decoded.
- **A11 port foundation:** WS1 bionic shim built and running on-device; A11
  native chain compiles and QNX-links.

## Achieved

- ✅ **Real interactive uid-0** via `/proc/boot/pathtrust !/base/bin/__root`
  (btool line 31) — persistent every boot.
- ✅ **eMMC read as non-root** via the `g_Disk_Drivers` group wrapper.
- ✅ **Permanent boot-partition WP proven** (`B_PERM_WP_EN`), closing the
  software unlock lane.
- ✅ **A11 bionic shim runs on-device** (1759 exports, 0 TEXTREL, passes the QNX
  trust gate).

## In Progress

- **A11-on-QNX port.** The A11 native chain loads; the **`binder` resmgr** is
  blocked at `resmgr_attach` → EPERM (path-manager identity). The A11 userland
  (`zygote`/ART/framework) is the long pole, gated on the AOSP header tree.
  → [`runtime/README.md`](runtime/README.md), [`ws1/STATUS.md`](ws1/STATUS.md)

## Failed

- **Software unlock / boot-partition write** — `boot0`/`boot1` return
  `EROFS`/`EIO` even as uid-0; the NVRAM power-cycle ritual leaves
  `BOOT_WP=0x04`; raw `CMD6` passthrough (`VUC_CMD`) is `ENOTTY`; `/proc/<pid>/as`
  `.text` writes are blocked (errno 312).
- **`imggen` prototype-bootloader route** — MSM8974-only; the Classic is
  MSM8960, so the public toolchain does not apply.

## Future Plans

1. Break the **binder resmgr EPERM** wall (path-manager ability/identity).
2. Build the A11 userland (needs the AOSP header tree / NDK sysroot).
3. Unlock remains **hardware-only** (live `CMD6` thunk, ISP, or EDL).

---

## Community Activity

- **Root/pathtrust** — **Oleksandr (bb10.root.sx)** documented the BB10 root
  ritual and RAM-loader mechanics; getroot autoloaders and **BerryCore** are
  widely shared.
- **No custom OS** exists for BB10; the **A11-on-QNX port here is original
  work**. BB10 is EOL (services shut down 2022), so interest is preservation +
  research.
- Community hubs: XDA, CrackBerry, the bb10.root.sx blog, and Telegram groups.

---

## Repository layout

| Path | Contents |
|---|---|
| `notes/` | BB10/Classic session notes (67) — the research trail |
| `docs/` | [BB10 hardware/security reference](docs/BB10-HARDWARE-SECURITY-REFERENCE.md), [autoloader guide](docs/AUTOLOADER_GUIDE.md), [compat-runtime spec](docs/compat-runtime-spec.md), `structure/` appendices |
| `recon/` | network audit, eMMC dumps, sepolicy analysis, QNX headers |
| `tools/` | BB10 tooling (`bblink.py`, `bb_reroot.py`, `imggen/`, bar packagers, probes) |
| `ws1/ binder/ graft/ runtime/ graphics/ sysroot/ specimens/` | A11-on-QNX port workstreams |
| `devmaps/` | Classic device map (schema v1.0) |
| `firmware/`, `work/`, `ref/` | fetch notes / large local working trees (**not committed**) |

---

## Related repos

- **Hub:** [Blackberry-Research](https://github.com/stanw47/Blackberry-Research)
- **Passport** (same BB10 platform): [Blackberry-Passport-Research](https://github.com/stanw47/Blackberry-Passport-Research)
- **Q10** (prototype, same SoC family): [Blackberry-Q10-Research](https://github.com/stanw47/Blackberry-Q10-Research)

---

## Citations & Acknowledgements

| Source | URL | Relevance |
|---|---|---|
| Oleksandr / bb10.root.sx | https://bb10.root.sx | BB10 root, pathtrust, RAM-loader |
| BBAndroids / imggen | https://github.com/BBAndroids/imggen | prototype bootloader (MSM8974) |
| balika011 — Passport conversion | https://balika011.hu/blackberry/guides/passport/conversion.php | canonical eMMC unlock |
| MWR — QNX Security Whitepaper | https://github.com/alexplaskett/Publications | QNX security model |

Thanks to the BB10 preservation community (XDA, CrackBerry, bb10.root.sx).

---

## License

Research notes and original scripts are provided for educational purposes;
third-party code retains its own license.
