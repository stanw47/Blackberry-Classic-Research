# Classic network audit — BB10 rooted autoloader (2026-10-02/04)

**Question:** A Reddit user claims the pre-rooted autoloader "sends traffic to
someone" (someone in HK tried to log into their Telegram). Audit the device to
see whether it phones home / exfiltrates.

**Verdict: NO evidence of phone-home or exfiltration.** All network activity is
either the local USB dev-link, loopback, the carrier/ISP, or BlackBerry's own
(legitimate) push/registration. Telegram was never connected to anything
suspicious. The claim is **not supported by the device data.**

Device: BB10 Classic `BLACKBERRY-528E`, rooted via the getroot/btool autoloader.
Connected over Dev-Mode SSH (fresh 4096 key pushed via blackberry-connect).

## Evidence

### 1. Every established connection (whole capture, all snapshots)
Only these, ever:
```
tcp  169.254.0.1.22    <-> 169.254.0.2.34322   ESTABLISHED   # our SSH (USB link)
tcp  169.254.0.1.4455  <-> 169.254.0.2.54450   ESTABLISHED   # Connect.jar tunnel (USB)
tcp  127.0.0.1.53      <-> 127.0.0.1.14419     ESTABLISHED   # local DNS resolver
tcp6 ::ffff:192.168.1.5.466 <-> 142.250.7.80   ESTABLISHED   # Google (Android runtime)
```
- `142.250.7.80` = **Google LLC** (Android container / Google services).
- A **90-second live watch** saw **zero** external connections while idle.

### 2. Listening services
All loopback (`127.0.0.1/127.0.0.3`) or the USB dev-link (`169.254.0.1`:
22/80/139/443/445/5555/8443/4455). Nothing listening for remote control.
`5555` = adb-over-usb; `8888` = local BB10 app renderer/proxy.

### 3. DNS / carrier (explains "foreign" IPs)
- `123.26.26.26` (**196 hits**) = `cachingdns2.vnpt.vn` → **Vietnam VNPT carrier
  DNS server** — the device's resolver, not a destination.
- `182.62.210.14`, `115.164.64.14` = carrier nameservers (PPS `nameservers`).
- `100.105.34.220` = carrier CGNAT address of the SIM.
- `192.168.1.1/40` = the local WiFi LAN + gateway.
- `103.184.124.254` (`play.xtdv.gr`) appears once (apk/browser context), not a
  repeated beacon.

### 4. Every remote hostname in the full slog2 log
```
mnc162mcc502.registration.blackberry.com   (BB ID registration)
inet.registration.blackberry.com           (BB ID registration)
inet.icrs.blackberry.com                    (BB ICRS)
time.blackberry.com                         (NTP)
cp{256,281,293,294,479}.pushapi.na.blackberry.com  (BB push, by APN id)
```
All BlackBerry's own infrastructure (required for BB10 to function). **No
suspicious TLDs** — the `.su/.cc/.ru` grep hits were C++ source filenames
(`enter.su`, `PushService.cc`, `Connection.cc`), not domains.

### 5. The root payload (read in full: `/accounts/devuser/rootdata/install.sh`)
`install.sh` does **only local** actions:
- injects `getroot` payload into the installer dir,
- symlinks btool as the ota_info autoroot script,
- stops/starts the Android container + switchzone.
**No network code whatsoever** — no URLs, no sockets, no exfil.

### 6. Telegram
- No `telegram` strings in the system log; no Telegram data dir under
  `/accounts/1000/appdata` matched (the account in question is Android-side).
- The Telegram app runs in the **Android container**; its traffic would appear as
  Android-runtime sockets. The only Android-side external connection observed is
  **Google** — consistent with normal Telegram-Android (FCM push + Telegram DCs
  only when the app is open; none at idle).

## Why the Reddit claim is almost certainly a false alarm
- A "someone in HK tried to log in to Telegram" is the classic symptom of
  **Telegram's own login-code flow** (the code goes to the account owner; a
  wrong/expired code, a bot, or session reuse), or of the user's **credentials
  being reused elsewhere** — it is **not** evidence of a device backdoor.
- If the autoloader exfiltrated, we'd see it in: (a) the root payload script,
  (b) open sockets to a third party, (c) repeated DNS/HTTP beacons. **None
  exist** — (a) has no network code, (b) shows only USB/loopback/Google, (c)
  shows only BlackBerry + carrier DNS.

## Caveats (honest limitations)
- BB10's Android runtime doesn't log all app traffic to slog2; a full verdict on
  *Telegram itself* would need a packet capture (tcpdump on the device, or a
  gateway capture) while the app is used. From device state + logs, there is
  **no sign of a backdoor in the autoloader**.
- The autoloader's root payload is local-only, but the **userland is a
  third-party getroot-based image** — as with any rooted autoloader, trust rests
  on its provenance, not BlackBerry signing. That's a general caution, not
  evidence of malice here.

## Artifacts
`classic-audit/2026-10-02/`: netstat_*.txt, live_conn_watch.txt,
slog2info_root.clean.txt (12 MB), sud_log.txt, root_scripts.txt (install.sh),
telegram_appdata.txt, pathtrust.txt, system.info.txt, *.txt.
