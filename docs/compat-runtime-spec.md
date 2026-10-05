# COMPAT — On-Device Android/Linux Compat Runtime for BBOS10

Project spec (private planning doc). Target audience: stanw47 + this repo. Not for publication.

---

## 1. Vision (one paragraph)

A system-level compatibility runtime for rooted BBOS10 devices that lets the user
install Android APKs of *any* era (above API 18) **directly on the device** — download
an APK, tap it, it installs to the home screen — with no command line, no local
server, no Term49/browser dances. Each app runs in its own contained runtime that
presents the API surface the app expects, translating calls down to what QNX/BB10
actually provide. The layer adds a modern TLS/SSL stack, keeps battery and RAM
impact low, and (phase 2 of the same architecture) adds Linux userspace apps.

Anti-model (what we are explicitly NOT): BerryCore/pyberry-style developer tools
that spin up a local server and make you interact through a browser or a terminal.
Those are *development utilities*; COMPAT is a *consumer runtime*. The difference is
the deliverable: a phone where apps install and launch from the Home screen like
nothing special is happening.

---

## 2. Named constraints (user requirements, verbatim spirit)

1. Works with "almost ANY Android app of ANY version later than 4.3 — within reason".
2. Apps are *genuinely installable*: the normal sideload feel (download APK -> install),
   with compatibility handled as a hidden extra step, done *on the device*.
3. Compatibility for Android **and** Linux apps, adapting cleanly to this hardware
   (square screen / trackpad / physical keyboard / sensors / 32-bit ARM).
4. A secure-connection (SSL/TLS) layer so apps get modern certs and TLS 1.3.
5. Memory-light enough for 2 GB devices (Classic); battery-light enough to be a
   daily driver.
6. No command line at any point for the user.

---

## 3. Target hardware

| Device   | SoC          | RAM | Storage | Status in July-aug 2026 work |
|----------|--------------|-----|---------|------------------------------|
| Classic  | MSM8960      | 2 GB| 16 GB   | Works, rooted, RUN this here  |
| Passport | MSM8974AA    | 3 GB| 32 GB   | Rooted; later (parked in 11011, needs HW lane; ignore for P0) |

Host OS: 10.3.3.3216, rooted (system-wide, via autostart/`context` substitution —
session work credited upstream). Everything below runs in the *running* userland;
no kernel changes, no boot0 writes.

---

## 4. Why this is buildable (and where the wall really is)

The BB10 "Android Runtime" is a ported **AOSP 4.3 (API 18), Dalvik-based** fork.
Three hard facts constrain us:

1. **DEX format:** Dalvik 4.3 loads DEX version 035. Modern APKs ship 037/039+.
   → Solved at install time: re-process bytecode with `d8/R8 --min-api 19`
   (legally and practically doable; outputs 035-grade DEX + does desugaring).
   This is a 2026-era, sample-dense toolchain — see Design Principle §7.
2. **API surface:** a modern app expects classes/APIs that don't exist in the 4.3
   framework. → Solved by the Compat Framework (§9): an injectable framework layer
   that owns class resolution for wrapped apps and *is* the missing API.
3. **Native code:** apps may carry 64-bit-only `.so` or require newer kernel syscalls.
   → The honest filter. 32-bit ARM is all we have; keep `arm/` libs, drop `arm64/`,
   classify `Tier 3` when there is no 32-bit path.

The kernel itself (QNX) is NOT Linux, so we do not port AOSP upstream kernels or
run Waydroid-style Linux-kernel containers. Instead we reuse the BB10 Android
runtime's existing Linux-ABI bridge (how 4.3 already runs on QNX) and only layer
compatibility above it. This is the single most important architectural decision:
**we upgrade the layer, never the kernel.**

---

## 5. Development principle — "build down, don't build up" (your AI insight, codified)

Observation: AI (and the broader OSS world) are dramatically more productive with
*modern* codebases because there are order-of-magnitude more public samples, tests,
and discussions. Ancient code (4.3 AOSP) is sparse and references patterns nobody
uses anymore.

Therefore COMPAT is built **against modern, sample-rich code**, and we *back-port the
semantics down* to the 4.3 host — rather than porting the 4.3 sources forward.

| Need | Modern (sample-dense) reference | We back-port onto |
|------|---------------------------------|-------------------|
| DEX/resource re-compile | `google/r8` (d8/R8, Gradle ecosystem) | Dalvik-DEX-035 + AAPT-compatible resources |
| Method/class injection | LSPosed / EdXposed hooking engine (works by hooking DexPathList & method entry) | API-18 Dalvik runtime |
| Google-Services-compat API | `microg` (GmsCore/UnifiedNlp) | Our service-stub layer |
| App virtualization model | VirtualApp / QTan-style per-app container semantics | One container base, per-app instances |
| Runtime-container concepts | Waydroid (Linux-kernel), used only as a *design* reference | N/A (QNX: we use BB runtime's bridge) |
| Modern WebView (bonus) | BerryCore's working Chromium content_shell `.bar` (proven on these devices) | Compat WebView |

Host-side spec docs (android-4.3_r1 AOSP: `googlesource.com/platform/dalvik`,
`frameworks/base` branch `android-4.3_r1`) are consulted ONLY as the ABI contract
of the host, never as the implementation style guide.

---

## 6. High-level architecture

```
                    +---------------------------------------------------+
                    |  BB10 Home Screen  (user sees normal apps)         |
                    +---------------------------------------------------+
                                 ^  installed as BAR w/ launcher intent
   +-----------------------+     |
   | COMPAT Installer (GUI) |-----+         "no command line"   <- Layer 1 (§8)
   | .apk/.bar picker,      |
   | profile engine,        |
   | on-device transform    |
   +-----------------------+     +-------------------------------+
             |  produces normalized package                       |
             v                                                    |
   +--------------------------+      +----------------------------v-+
   | Compat Framework         |      | Per-app runtime instance      |
   | (preloaded, owns class   |----->| classloader + hooked Dalvik    |
   |  resolution)             |      | + simulated API surface        |
   +--------------------------+      +----------------------------+-+
       | API stubs >18, GMS stubs, modern SSL         hardware shims |
       |                                                (display, input, sensors) |
       v                                                        v     |
   +--------------------------+     +-----------------------------+  |
   | TLS/CA provider + proxy  |     | HB adaptation ports           |--+
   +--------------------------+     +-----------------------------+
       | direct modern TLS  |  per-app TLS-terminating proxy
       v                    v
   +-------+   +----------+-----------------------------+
   | QNX    |   | BB10 Android Runtime (API 18)          |
   | kernel |-->| (existing Linux-ABI bridge)            |
   +-------+   +----------------------------------------+
```

---

## 7. Layer 1 — Installer (the "just install it" experience)

A native BB10 BAR app (Qt/Cascades or WebWorks-to-QNX; native preferred for the
file picker and status bars). Responsibilities:

1. Register as handler for `.apk` (and `.bar`) so "download → tap" just works.
   Fallback: in-app file picker (no console ever involved).
2. **Profile engine** evaluates the manifest → assigns Tier (§10) and a compat
   profile (+ remembers it locally, upgradeable over time).
3. **Transform pipeline** (all on-device, in a QNX-side worker under root):
   - DEX: run stacked `d8/R8 --min-api 19` → 035-grade, desugared, optionally shrunk.
   - Resources: re-pass with AAPT2-style correction with attribute fallback list for
     the API-18 base; drop unknown resource dirs gracefully.
   - Native: keep `arm/` (and `armeabi-v7a/`), drop `arm64-v8a/`, x86 dirs; warn if
     none remain (→ Tier 3).
   - Manifest: rewrite `minSdkVersion`/`targetSdkVersion` as needed for the runtime's
     checks AFTER our framework is in the classpath (target kept only for feature gate).
   - Sign with COMPAT key (reuse repo's existing signing/bundle tooling).
4. **Install** through the **official native lane** (proven, session22): stage the
   transformed APK in the shared/user area and invoke the BB10 installer on it
   (the same flow as tapping an APK in Files). The OEM installer handles everything
   we cannot: registry pkgDN entry (`/pps/system/installer/registeredapps/*`),
   appdetails/icon, authman capability grants — everything that makes the app
   appear on the **Home screen** with a normal icon and honest user consent. The
   native prompt doubles as the whitelist gate. Launch goes through Layer 2.
   (Drop-lane / root file placement is reserved for COMPAT's own compat-layer
   payloads, not user apps.)

Verified lane facts (evidence in `notes/session22-android-runtime-install-lane.md`):
- Files-app tap → installhandlerui/QNXInstallerService (QNX euid 810) → install at
  `/data/app/<pkg>-1.apk` (or in-place upgrade of a pre-existing /system/app copy,
  `UPDATED_SYSTEM_APP`) → registry entry `org.<pkg>.<guid>::andr<guid>,…,source::apk`
  → authman `dyncap` grants → grid icon.
- The grid is a renderer over that native registry; the drop-lane (copy into
  /system/app + restart) installs at the Android level only — no grid icon.

Success metric (P0 milestone): a mid-era APK (e.g. a 2016-2018 build of a popular app)
downloads, taps, installs, and launches from Home with no shell interaction.

---

## 8. Layer 2 — Compat Framework + per-app container

- **Hook engine:** port an LSPosed/Xposed-style loader that installs into each
  wrapped app's process (via the BB10 Dalvik fork + our root autostart). Intercepts
  `DexPathList` / `ClassLoader` resolution — anything the app tries to load that the
  base API 18 lacks is answered by the Compat Framework first. (public sample base:
  Xposed family hooks are extremely well documented for exactly the 4.x Dalvik era.)
- **API surface generator:** generate stub classes for API 19→34 from the modern
  AOSP source tree (android.googlesource.com) diffs; each stub implements the class
  using the *nearest real implementation* below it, then the QNX/BB10 services.
  AI-assisted generation is ideal here (bulk, repetitive, sample-dense) — this is
  the direct payoff of §5.
- **Service stubs (GMS-lite):** MicroG-based providers for Location, Weather cache,
  notification sync, Play-Services-dependent app calls; FCM / billing stubbed to
  fake-success where safe. Keep it minimal per §11 battery rules.
- **WebView:** bind BerryCore's Chromium content_shell as the compat WebView for any
  app that uses a web view — this one move buys both modern rendering AND modern TLS
  inside embedded views, and it is already proven to run on these devices.
- **Per-app container:** one base container; each app gets its own instance (its own
  classloader + simulated API + storage view + permission view). "If a container is
  needed for every application, when it opens, then so be it" — yes, this is the model;
  we keep it lazy (container starts on app open, torn down/kept on exit per profile).

---

## 9. Layer 3 — Hardware + connectivity adaptation

**Device-profile abstraction.** One profile per phone model, version-weighted:

- Classic: 720×720 virtual display mapping (toolbar handled), trackpad→touch
  (hover/tap), physical keyboard→keys, physical RIM keys.
- Passport: 1440×1440 square mapping, keyboard→keys, hub/peek→app corners.
- Input bridge, sensor shim (accelerometer/compass/gyro→Android SensorManager),
  camera passthrough where the HAL allows, audio, LED/notification back-end.

**TLS/SSL layer (explicit requirement #4):**
1. Inject a modern JCE/SSLEngine provider (OpenSSL 3 / BoringSSL, compiled for
   32-bit ARM) as the *first* Java `Security` provider so normal apps get TLS 1.3 and
   current cipher suites with zero app changes.
2. Ship a refreshed CA bundle + trust-anchor injection; wire into Framework's trusts.
3. **Per-app local TLS-terminating proxy (CONNECT)** for apps that do raw sockets
   with their own old OpenSSL: terminates on-device with modern crypto; pinning
   escape hatch documented (some Tier-2 apps become Tier-1, some stay Tier-3).
4. Native lib interpose path for bundled-old-OpenSSL apps via QNX `LD_PRELOAD`
   (QNX loader honors it) pointing to our shim.

---

## 10. Compatibility tiers ("within reason", enforced)

| Tier | Meaning | How it's enforced |
|------|---------|-------------------|
| 1 Full | Single-app core + notifications + web + SSL all work | profile matrix auto-assign; regression-tested per category |
| 2 Core | Runs; some feature degraded (no DRM/Widevine, no maps layer, no push) | runtime shows a one-time note; user decides |
| 3 Won't run | 64-bit-only native libs; missing hardware; apps quarantined by DRM | installer refuses with explanation before install |

Widevine/DRM, hardware video decode height, and missing sensors are the long-tail
reasons for Tier 2/3 in the modern era — set expectations honestly.

---

## 11. RAM + battery budget (explicit requirements #5)

**RAM (Classic = the harsh proof):**
- System baseline 10.3.3 + COMPAT hooks: target < +40 MB idle.
- Per-app ceiling: profile-based cap (e.g. 320-512 MB RSS); Runtime enforces.
- **Background freezer**: only foreground app has real memory; cached apps are
  suspended at QNX process level (proc server), resurrected on switch.
- **zram-ish swap**: enable swap on eMMC + (where possible) compressed swap to
  absorb spikes; tune `vmsIn`/cache via runtime.
  Expectation we design to: *one focused app at a time runs well*; this is the
  2014 daily-driver reality, not a bug.

**Battery:**
- Hooks idle (only intercept on miss): idle spend goal ≈ same as stock runtime.
- Modern WebView spun down when no webview in the process.
- Installer/test tooling runs are one-shot; no background phone-home.
- Per-app CPU monitor (pidin/proc Server) with warn/stop thresholds.

---

## 12. Linux apps (phase 2 of the vision)

- Architecture slot reserved in the runtime so Linux is a *module*, not a rewrite:
  a Linux userspace rootfs chroot (item-4/kernel-class work) presenting under the
  device display, with its own input/SSL/container story.
- NOT P0. P0 = Android path. Linux starts only after §10 tiers are stable for
  Android. Do not cram ELF binaries through the Android shim — that waters down both.

---

## 13. Reference material / repos to lean on

Host (spec ONLY, not style):
- android.googlesource.com — `platform/dalvik`, `platform/frameworks/base`
  branch `android-4.3_r1` (API 18 contract).

Modern (build against, port semantics down):
- github.com/google/r8 — d8/R8 DEX 035 at `--min-api 19` + desugar/shrink.
- LSPosed/EdXposed — hook engine pattern for the (same-family) Dalvik hooks.
- github.com/microg — GmsCore / UnifiedNlp blueprint for service stubs.
- VirtualApp / QTan-style — per-app virtual-application container semantics.
- Waydroid — *design* reference for runtime-container layering on Linux kernels
  (we do NOT run it; QNX is not Linux; ideas only).
- github.com/sw7ft/BerryCore — QNX extended userland + working Chromium
  content_shell `.bar` (our WebView engine) + `qpkg` packaging; sw7ft/blackberry10-apps
  for sideload/app archives; bb10root/bb10mt + bb10.root.sx for root content and
  NVRAM/mod tooling (and upstream credit trail incl. our own root insight).

Our own repo:
- tools/ signing + bundle pipeline, root autostart (context substitution),
  session notes 15-19 (root, NVRAM, runtime internals), dumps/ analysis.
- LEGAL.md: keep APK handling to legally-obtained files; no redistribution of apps;
  GMS-service stubs may conflict with Play terms — document clearly, personal/research
  use only.

---

## 14. Build plan (ordered milestones)

- **M0 (spike, 1-2 weeks):** prove on-device DEX-downgrade loads in Dalvik 4.3
  (d8 `--min-api 19` output on Classic); prove Xposed-style hook loader attaches in
  the BB10 Dalvik fork; prove `.apk` picker + home-screen install path exists.
- **M1 (the big visible demo):** install a mid-era APK end-to-end with NO console;
  it launches from Home. (This is the pitch.)
- **M2:** transform pipeline hardened (dex+resource+lib+manifest+sign) on arbitrary
  APKs; tier engine v1.
- **M3:** hook engine + first API-stub set (10-20 real classes) → one Tier-2 app
  promoted to Tier-1.
- **M4:** WebView = BerryCore Chromium bound in; SSL provider + CA store swapped.
- **M5:** device profiles + input bridge (Classic first) + per-app container polish.
- **M6:** RAM/battery governor (freezer, swap, ceilings, CPU monitor).
- **M7:** on-device profile learning DB; usage telemetry (local only).
- **M8:** Linux module placeholder + docs/legal polish.

Gate for M3+: everything must run on Classic with measured idle overhead and a
battery-vs-stock comparison before expanding scope.

---

## 15. Risks & mitigations

| Risk | Mitigation |
|------|------------|
| Dalvik 4.3 hook attachment unstable on BB fork | Static-graft mode: bake shim calls into the APK at install (no hooks) as fallback |
| DEX/resource reprocessing breaks unusual builds | Tier-3 guard + per-app profile; keep raw APK in cache for re-process attempts |
| 64-bit-only apps | Explicit Tier-3 refusal at install (honest) |
| Battery/RAM creep | Hard budgets + throttles from M0; measured every milestone |
| GMS-stub legal/compat edges | microG-style, optional on/off; documented |
| Device brick risk (root-level service) | All COMPAT code userspace; live in a removable autostart dir; one-line revert |

---

## 16. Non-goals (say it out loud)

- NOT a kernel/Linux dual-boot (that's item-4 work, separate).
- NOT a Widevine/DRM-bypass product. Tier 3 when DRM-walled.
- NOT a tech-support-any-app product: "within reason" is our matrix, not magic.
- NOT a server. Installs and runs on-device, no console at any point.