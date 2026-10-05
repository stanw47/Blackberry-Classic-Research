# Classic — session notes index

Chronological, raw research notes for the BlackBerry **Classic** (BB10/QNX,
MSM8960) and the **A11-on-QNX runtime port** developed on it. Provided as-is as a
research aid. Each note opens with a fixed header (date · device · access level ·
status) and a plain-language TL;DR.

> Priv (Android) notes live in the **Priv** repo; Passport notes in the
> **Passport** repo. This index covers only Classic.

## BB10 platform / Classic device
- `session7i-vtnvfsd-emmc-isp.md` — vtnvfsd RE (nvuser format) + eMMC/ISP strategy
- `session7j-classic-emmc-access.md` — Classic eMMC access (group wrapper)
- `session7k-bbss-insecure-pinned.md` — `bbss.insecure` flag
- `session7l-boot0-writeprotect.md` — boot0 write-protect
- `session7m-mmcsdpub-wp.md` — mmcsdpub publisher vs WP
- `session7n-final-classic.md` — Classic final state
- `session7o-classic-real-root.md` — **real uid-0** via pathtrust `!__root`
- `session7p-dcmd-write-protect.md` — DCMD_MMCSD_WRITE_PROTECT
- `session7q-extcsd-bootwp.md` — EXT_CSD boot WP
- `session7r-sdmmc-driver-re.md` — sdmmc driver RE (devctl constants)
- `session7s-oleksandr-answer.md` — Oleksandr's raw-MMC answer
- `session7t-proc-as-patching.md` — `/proc/<pid>/as` patching
- `session7u-ext-struct-location.md` — per-node `ext` struct location
- `session7v-eio-is-switch.md` — EIO is the switch
- `session7w-connect-ritual.md` — the SSH connect ritual
- `session7x-windows-connect.md` — Windows connect
- `session7y-map-device-common.md` — MAP_DEVICE capability
- `session8a-group-wrapper-emmc.md` — group-wrapper + live MMC devctl
- `session8b-wpgrp-patch.md` — targeting the WP_GRP gate
- `session8c-writable-data-and-extcsd-loc.md` — writable data + ext_csd loc
- `session8d-r2-accurate-devcctl-map.md` — r2 devctl/resmgr map
- `session8e-r2-wp-converged.md` — r2 convergence
- `session9-live-reprobe.md` — live WP/raw-CMD re-probe
- `session9a-live-extcsd-reread.md` — live EXT_CSD re-read
- `session9b-ifs-verify-cap-diff.md` — IFS verify + rooted `cap.exe` diff
- `session10-recreate-patch.md` — re-create the raw-MMC patch
- `session11-ssh-vs-root-procas.md` — SSH vs root + `/proc/as`
- `session11b-proc-as-alive-exec-blocker.md` — `/proc/as` alive, exec blocker
- `session11c-root-dd-hwwp-proc-as-gate.md` — root dd/cat + HW-WP
- `session11d-ssd-userauth-hang-procas-regression.md` — sshd + `/proc/as` regression
- `session14-edl-wipe-nvram-lane.md` — EDL marker gate test (Classic)

## Android runtime (factory 4.3 player)
- `session22-android-runtime-install-lane.md` — APK install mechanics
- `session23-runtime-probe-and-polyfill.md` — runtime discoverability
- `session24-newest-feasible-sourcing-and-runtime-patch-groundwork.md`
- `session25-checkpoint-basebundle-fixed-nextgap-desugar-and-graft-unblocked.md`
- `session26-android-runtime-complete-map.md` — runtime complete map
- `session27-android-runtime-bar-internals.md` — `.bar` internals
- `session28-app-manager-source-dissection.md` — App Manager source
- `ANDROID-RUNTIME-COMPLETE-MAP.md`, `ANDROID-APK-TO-DRAWER-FLOW.md`

## A11-on-QNX port (goal locked sessions 31/32)
- `session29-port-new-runtime-research.md` … `session41-exec-gate-repro-signal-block-verify.md`
- `session66-app-install-dexopt-fix.md` … `session72-chain-regen-from-committed-source.md`
- `notes-session65-resmgr-ab-locked.md`
- Status: [`../ws1/STATUS.md`](../ws1/STATUS.md), [`../runtime/README.md`](../runtime/README.md)
