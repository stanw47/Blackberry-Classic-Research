# session21 - Drain test = decisive negative; software lane closed; hardware lane mapped

## Status: Passport parked in 11011 wipe-deadlock until direct eMMC access. Classic remains usable.

## [0] DRAIN TEST (the decisive experiment) - FAILED TO RECOVER

Sequence performed on Windows (user's machine, autoloader ready):
1. Let Passport battery fully drain (3450 mAh, half-charged at start, est 12-48h).
   Device fully dark / dead.
2. Plugged into Windows PC with pre-rooted v2 autoloader open and waiting.
3. RESULT: nothing enumerates on plugin. Only when keys are pressed does the
   device react - and then it re-enters the same `11011` Flash Erase Failure blink.

Conclusion: the 11011 latch SURVIVES a full power-down to zero battery. It is
NOT a voltage/latch issue (session20 ladder item 1 moot as a cure). The state is
persistent at the card/bootrom level: armed wipe + card-level permanent WP
(BOOT_WP[173]=0x04) -> erase can never complete -> BootROM stuck before loader.

## [1] LOCAL USB PROBE (second confirmatory negative)

- Background listener (listen_flash.py --armed, PID 231145) polled 8460+ checks,
  never saw a single 0FCA device.
- 60-second tight `lsusb` poll while user held volume keys: NO 0FCA/05C6/Qualcomm
  entry at any point. Bus shows only the laptop's own devices.
- Matches Windows exactly: no enumeration without keys; with keys -> 11011 only.

=> BootROM is not (re-)enumerating loader-mode USB on this unit at all; there is
   no software lane to reach NV. Session20 ladder steps 2-3 are unavailable while
   it is in this loop.

## [2] WHY SOFTWARE IS CLOSED (verified against community body of work)

- Qualcomm-style forced-EDL (short eMMC CMD->GND or DAT0->GND during boot, then
  use Sahara/firehose) does NOT help: firehose requires an OEM-signed programmer
  matching the BB SoC fuses; none exists for BlackBerry. (bkerler/edl; SaintPepsi
  claude-on-blackberry issue #7 - the same gate that stops the Priv research.)
- Passport PBL is BB-custom: BootROM PID 0x0001, hash_pass_v2 / B01000000 PIN protocol,
  not the stock QC 9008/900E interface. Even if forced to EDL, no signed programmer
  is obtainable.
- balika011 (author of the only working in-band write lane) states unequivocally:
  "there's no exploit that allows updating without desoldering the eMMC and
  reprogramming it." He chose desolder + ISP for the same reason.
- Our specific bind: any loader session re-triggers the wipe; the wipe cannot
  complete. NV (the thing we need to edit) sits behind the wipe.

## [3] RECOVERY PLAN (for when off-holiday / with hardware)

Required: direct eMMC access. Two levels:

A. IN-CIRCUIT ISP (preferred, no desolder):
   - Tooling: UFI Box (~USD 319-459) + UFI ISP Adapter V2 (~USD 5) or
     EasyJTAG Plus / Medusa-class box. Solderless-ISP eMMC guides are public
     (e.g., BilalMoubarek/solderless-isp-emmc-forensic; mobifirms dump guides).
   - Need Passport PCB test-point map: open unit, photograph both sides, identify
     eMMC CMD/CLK/DAT0-7/VCC/GND pads and boot-config test points. Also test the
     "hold DAT0 or CMD to GND at boot" ground trick for forcing a raw attach.
B. DESOLDER into BGA socket (guaranteed): reflow eMMC into socket/adapter,
   work on chip standalone. balika011 Passport repair guide documents the exact
   BGA package and his working ISP procedure.

Once chip is readable (either route):
1. FULL RAW BACKUP of the entire eMMC (user area + boot0 + boot1 + RPMB raw if
   accessible). Keep as donor/restore image.
2. Locate NV on the dump and edit directly (from session15/18 mapping):
   - nvram0 record `0x2019`, byte5 `0x0C` -> `0x00` (offset ~0x100C80 in nvram0).
     Removes the "boot partition write allowed" pose that pulls the updater into
     the fused-WP boot0 write path.
   - Clear NV WP / WP_PROGRESS flags.
3. Do NOT touch boot0 content. Permanent BOOT_WP[173]=0x04 can stay fused - RIM's
   official updater never writes boot0, so an intact stock boot0 + corrected NV
   is a working phone. Only if we ever want a modified boot0 must the permanent
   fuse be cleared at chip level (vendor/ISP commands) or the boot block rebuilt
   via the balika011/imggen route.
4. Reinstall chip / reconnect in-circuit, power on -> should reach "Reload OS" /
   normal update mode -> run STOCK autoloader (passport 10.3.03.3216) -> OS boots.
5. Optionally verify flags via mod_nvram now that device is alive, and re-derive
   0x2019 bit-42/43 endianness on the live unit.

## [4] Open items
- Exact Passport eMMC package + test-point locations (teardown photo survey
  needed; balika performance guide has the chip ID).
- Whether the permanent WP bit is clearable at chip level at all, or only
  "workaround-able" (never write boot0 again). Not needed for recovery as written.
- Whether utter battery-dead + a LONG charge (not just plug-in) changes
  enumeration enough for a single one-shot v2 autoloader run - cheap enough to
  retry once with a fully topped-off battery before spending on hardware.

## References
- notes/session19/20 within repo (dumps, 11011 decode, recovery ladder).
- github.com/SaintPepsi/claude-on-blackberry#4 #7 (Priv test points / EDL gate).
- github.com/bkerler/edl README (force-EDL; firehose programmer requirement).
- github.com/BilalMoubarek/solderless-isp-emmc-forensic (solderless ISP method).
- mobifirms.com/guide-emmc-ufs (UFI/EasyJTAG/Flash F64 dump guide).
- crackberry Passport LineageOS thread (balika: no in-band route).