# Classic — Summary

- **Device:** BlackBerry Classic (SQC100 / Q20)
- **SoC:** MSM8960
- **OS/build:** BB10 / QNX 10.3.3.3216 (`QNX BLACKBERRY-528E`, CLASSICNA)
- **Repo:** https://github.com/stanw47/Blackberry-Classic-Research
- **Visibility:** private
- **Status:** rooted (uid-0), bootable, recoverable; bootloader unlock HW write-protect gated
- **Headline:** real uid-0 via pathtrust `!__root`; `boot0` WP permanent (`B_PERM_WP_EN`)

## Headlines
- Real interactive uid-0 via `btool` + `/proc/boot/pathtrust !/base/bin/__root`.
- eMMC read without desolder via `g_Disk_Drivers`.
- Permanent boot-partition write-protect closes the software unlock lane.
- A11-on-QNX runtime port: bionic shim runs on-device.

## Blockers
- `BOOT_WP[173]=0x04` (`B_PERM_WP_EN`) is permanent; only live `CMD6`/ISP/EDL unblocks.

## Last updated
2026-10-05
