# Telegram.apk analysis — the Reddit "backdoor" claim

Follow-up to `../AUDIT-REPORT.md`. The accuser says the problem was a
**self-compiled Telegram APK**, not the autoloader. Pulled the actual APK off
the device and analysed it.

## The APK (pulled from the device)
`/accounts/1000/removable/sdcard/downloads/Telegram.apk` — 65,710,147 bytes
SHA-256 `1da09fb16dc8ee134a9189ca6d135b37eb616bee5182b3c719be08a0635d0095`

| Field | Value |
|---|---|
| package/version | Telegram **12.10.3** (versionCode 70899) |
| compiled with | Android Gradle Plugin **8.13.2** (2025) |
| **minSdkVersion** | **21** |
| **targetSdkVersion** | **36** |
| native libs | `libtmessages.49.so` for arm64-v8a, **armeabi-v7a**, x86, x86_64 |
| deps | AndroidX, **Kotlin coroutines**, GMS/credentials — all modern |
| **signer** | `L=Saint-Petersburg, O=VK, OU=VK, CN=Nikolay Kudashov` |

## Key findings

### 1. It is a real, modern Telegram build — just re-signed
- Contains `libtmessages.49.so` (the **official Telegram Android** native
  engine) and its embedded server list is **Telegram's real production
  datacenters**: `149.154.167.40/.51/.91`, `149.154.175.*`, `149.154.171.5`,
  `95.161.76.100`, `8.8.8.8` — i.e. `*.telegram.org` DC ranges. **No third-party
  / C2 / unknown endpoints.**
- Signed with a **VK / Mail.ru developer key** (`O=VK`, St. Petersburg) — typical
  for a **self-compiled/re-signed Telegram** (Telegram's official app is signed
  by "Telegram FZ-LLC"; this is not). Re-signing by whoever compiled it is
  expected for a custom build.

### 2. **It cannot even run on the Classic**
- The Classic's Android runtime is **Android 4.3 / API 18, armeabi-v7a**.
- This APK requires **minSdkVersion 21 (Android 5.0+)** and targets **API 36**.
- ⇒ It **cannot be installed or executed** on this device. The package manager
  would reject it (`INSTALL_FAILED_OLDER_SDK`). It just sits in `/downloads`.
- There is **no Telegram entry in the Android `packages.xml`** — it was never
  installed here.

### 3. The "someone in HK logged into my Telegram" is not device-caused
- The APK contains only Telegram's own servers.
- The accusation is the **classic Telegram login-code/session symptom**:
  - Telegram sends a **login code** to an existing logged-in session when a new
    login is attempted; if the account owner (or a bot/attacker with the phone
    number) triggers it, it looks like "someone tried to log in."
  - Re-signed/self-compiled Telegram builds **cannot use Google Play
    integrity / SafetyNet** and may fail Telegram's own client checks, but that
    does **not** redirect traffic to a third party.
  - A re-signed APK *could* be malicious if the compiler added code — but this
    one's native server list is clean Telegram DCs, and the app never even ran
    here (minSdk 21).

## Verdict
- **The rooted autoloader is not sending traffic anywhere** (see AUDIT-REPORT:
  only BlackBerry push/registration + carrier DNS + Google).
- **The Telegram.apk is a legit (re-signed) Telegram 12.10.3 build**, containing
  only Telegram's real servers. It **cannot run on this API-18 device** and was
  never installed here.
- The Reddit claim conflates a **Telegram account-login event** with a device
  backdoor. Nothing in the device logs or the APK supports "it phones home to
  someone."

## Caveat (fair to state)
A **self-compiled APK is inherently unverifiable** — you can't compare it to
Telegram's official signature, and you're trusting whoever built it (here, a
VK-key signer). If the accuser distrusts it, the right move is to use the
**official Telegram APK** from telegram.org, not a re-signed one. That's a
provenance concern, **not** evidence that the autoloader (or this device) leaks
data.

## Artifacts
`telegram/Telegram.apk` (+ signer extract, native-lib server list).
