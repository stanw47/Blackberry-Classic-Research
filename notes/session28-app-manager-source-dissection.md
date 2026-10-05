# Session 28 — BB10 App Manager Source Dissection

Source: `~/Downloads/bb10-app-manager-1.0.0.zip` (Electron app, "BB10 / PlayBook App Manager" 1.0.0 by zhetengbiji, based on the PlayBook "pb-apps" 2.2 by George J / gridbook.org).
Binaries: `BB10.App.Manager.1.0.0.dmg` (83,980,507 B), `BB10.App.Manager.Setup.1.0.0.exe` (58,500,996 B).

## Architecture
- Electron `background.js` opens a window; on each `did-create-window` it `executeJavaScript`s `pb-apps.js` (the real client).
- `webRequest.onBeforeSendHeaders` forces `User-Agent: QNXWebClient/1.0` on every `https://*/cgi-bin/*` XMLHttpRequest.
- `onHeadersReceived` rewrites any non-`text/xml` content-type of cgi-bin responses to `application/octet-stream`.
- `app.commandLine.appendSwitch('ignore-certificate-errors')` -> TLS 1.0 / self-signed OK.
- URL is the device's own built-in HTTPS admin API on 169.254.0.1 (USB) — no new daemon, no helpers.

## Protocol
Endpoint: `https://<device>/cgi-bin/login.cgi` and `.../cgi-bin/appInstaller.cgi`, plus `.../cgi-bin/dynamicProperties.cgi`.
This is the same API blackberry-connect / autoloaders talk to. Password is the DEVICE password
(no separate "dev mode" password — the HTML note "Switch to Development Mode" is a PlayBook-era relic).

### login.cgi (GET, `?request_version=1`)
- `jaAsync()`: GET without creds -> XML with `<Status>`. Handles `PasswdChallenge` / `Success` / `Error`.
- On `PasswdChallenge` parses `<FailedAttempts>`, `<RetriesRemaining>`, `<Challenge>`, `<Algorithm>`,
  `<Salt>`, `<ICount>`. Rejects `Algorithm != 2` with "Unsupported Algorithm".
- Auth (Algorithm 2): custom SHA-512 (Paul Johnston's bigint-free 32-bit implementation, functions
  `oa/ra/pa/qa/R/S/T/La/U/na/ma`). Salt hex -> two 32-bit words fed as a locked 76-byte hash:
  `ma(d[0], d[1], icount, password)`. The ICound-repeated compression is chunked via progress + setTimeout.
- Second stage: `challenge_data=<hex>(digest of salt+password)` -> if `<Status>Success`, session cookie
  `loginsession` is set; if `Denied`, wipe cookies and re-prompt (max retries enforced by server).
- `la()` auto-login path stores `passwd/salt/icount/hash` in localStorage when "Auto Login" checked.

### appInstaller.cgi (POST form) — commands
- `List` — full unified app table (see below).
- `Install` / `Install and Launch` — upload app via `file` field (multipart). `ya()` polls the
  response for `result::` and `actual_id::` lines; retries 10x with 2s gap on incomplete; on success
  (`result::success`, ok) auto-refreshes the list.
- `Install Debug Token` — files <= 4096 bytes are routed here (debug-token lane, not an app install).
- `Uninstall` — form: `command=Uninstall&package_id=<b.id>&package_name=<b.name-minus-28>`.
- `Launch` / `Terminate` / `Is Running` — form: `command=<X>&package_id=<...>&package_name=<...>`.
  `N()` derives: package_id = row id (`f.slice(-27)` = last 27 hex of the pkg id), package_name =
  `f.slice(0,-28)` (id minus trailing 28-hex guid). result shown by `ya()`.
- install/launch results also create a logs list (`v`) with ok/err/other filters.

### dynamicProperties.cgi (GET)
- Returns XML with `<BatteryLevel>` and `<FreeApplicationSpace>` (bytes). Only used on
  `169.254.*` (USB) hostnames; via Wi-Fi host "Device status is not available".

## List response format (parsed by `ta()`)
```
Info
@applications
<pkgid>::<dir>,<version>,<f3>,<size>,<key>::<value>...
```
- 1st line must start `Info`, 2nd must start `@applications`.
- Per line: `pkgid::dir` = row id + native dir id; second CSV field = version.
- Comma-index 3 non-empty => `g=true` -> button shows **Permanent** (uninstall disabled).
- Comma-index 4 => size byte count (adds Size column).
- Remaining `key::value` pairs (before a `dat::` block) set: name, version, source, contentID,
  iconID, vendor. `__` skipped (i.e. comment rows like `__gid`).
- `m.i` (contentID) wraps name in an AppWorld webstore link;
  `m.f` (iconID) pulls icon from `http://appworld.blackberry.com/webstore/servedimages/<id>.png/?t=18`.
- `source==apk` wraps name in `https://play.google.com/store/apps/details?id=<name>` (i.e. the
  display name IS the android package name).
- Sorting: by source then case-insensitive name. Grouped into a source filter dropdown (`xa`).

## UI / semantics
- Table row command cell: `?` (Is Running), Launch, Terminate, Uninstall(+checkbox da -> enable),
  or "Permanent" disabled.
- Uninstall disabled/enabled rule (`f` in `ta`): uninstall is ENABLED only when
  `source` present AND in {appworld, developer, apk, betazone} AND `!g`. Otherwise button = disabled
  ("Permanent" if g set). This is the client-side guard; server still authorizes each command.
- `sys.data.`-prefixed names: whole row disabled (that's our pre-root autoloader payload
  `sys.data.getroot` from appdetails!).
- Install queue (`u`): drag-drop files; `>4096B => Install(and Launch)`, `<=4096B => Install Debug Token`;
  uploads sequentially; aborts a running upload on removal.
- Logout (`ea`->`fa`): clear localStorage and delete `loginsession` (+`dtmauth`) cookies.

## Relationship to our map
- This is a pure client of the same OEM cgi-bin API, so it sees the SAME full app table a BB10
  screen shows — including android APKs (source=apk), native BARs (appworld/developer/betazone),
  websl apps (source=websl), and the `sys.data.*` specials. Its "permanent" flag matches the
  appdetails/registry "permanent" concept.
- `Uninstall` + `Install and Launch` are exactly the OEM lanes we probed under session22; this
  proves they are scriptable via cgi-bin (the user can install any `.bar` with the App Manager).
- Shows package id convention: `<pkgid>::<dir>` where pkgid ends in a 28-char hex guid — same
  `andr<36>` / `org.<pkg>.<36guid>` style seen in `/pps/system/installer/*`.

## Reconciliation with user correction
- password 61482501 is the DEVICE password; every app connecting to the BlackBerry asks for its
  device password. The HTML hint "switch to Development Mode" is legacy and does not apply here.

## Observations on app installation (from source)
- Everything funnels through `appInstallerAsync` (pb-apps.js:289): a single
  `POST /cgi-bin/appInstaller.cgi` with `FormData` fields, cookie-authenticated.
- Commands seen in source: `Install`, `Install and Launch`, `Install Debug Token`,
  `Uninstall`, `Launch`, `Terminate`, `Is Running`, `List`.
- File-size split (`ha`, pb-apps.js:11): `>4096 B` => Install (or "Install and
  Launch" if the `ial` checkbox is on); `<=4096 B` => **"Install Debug Token"**.
  So the debug-token lane is selected purely by file size client-side.
- Install upload (`Ba`, pb-apps.js:374): `command` + `file` field; progress via
  `upload.onprogress`; UI shows bytes/s + ETA. Queue (`u`) uploads sequentially
  and can abort a running upload.
- Result parsing (`ya`, pb-apps.js:294): scans response lines for `result::` and
  `actual_id::`; `result::success` triggers list refresh; anything else retried
  (10 attempts, 2s gap); `Error: User` means re-login. On success the row becomes
  clickable to reveal the runnable app (Launch via `A(a)`).
- Uninstall (`N`, pb-apps.js:356): sends `command=Uninstall`, `package_id` =
  row id (last 27 hex of pkg id) or the `b.id` if the button said "Permanent",
  and `package_name` = pkg id minus the trailing 28-hex guid.
- Launch/Terminate/Is Running: same endpoint, command swapped, same
  package_id/package_name fields; `result::true/term/success` = ok.
- Client-side guards only, server enforces: rows not in
  {appworld, developer, apk, betazone} or flagged permanent get a disabled
  "Permanent" button; `sys.data.*` rows are entirely disabled.
- Install LANE CONFIRMED to exist as an OEM-scriptable API (matches session22):
  no BB10 App Manager daemon is needed; the app is a pure client of the device's
  built-in cgi-bin server. The Device dev-mode "Install Debug Token" phrase is a
  PlayBook artifact; token install is just small-file upload to the same endpoint.

## Pending / abandoned lines
- Live auth against login.cgi NOT pursued further: crypto hand-port vs running
  the original functions diverged (different challenge_data), and OAuth/SHA-512
  byte-wrangling is out of scope for the COMPAT objective. The endpoint +
  challenge flow is already proven reachable (Algo 2, Salt A98DF307CD8FFCC4,
  ICount 5834). If we ever want the unified app table via cgi-bin, run the
  original app (Electron/chromium) rather than reimplementing the hash.