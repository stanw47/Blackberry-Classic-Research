# session57 — toolchain unblocked: QNX 8.0.0 ARM SDP located + exact link recipe extracted

Date 2026-09-18. Classic (MSM8960, QNX 8.0.0) live via SSH. This session re-opened the
biggest host-side blocker across sessions 38–56.

## Three findings (all verified this session)

### 1. Device SSH is up (recipe correction)
- 4455 was OPEN but 22 DOWN (the usual post-reboot state). Recovered with the standard
  ritual: fresh 4096-bit key + `Connect.jar 169.254.0.1 -password <PW> -sshPublicKey
  <id_rsa.pub>` (detached via `setsid`/`nohup`), wait ~20s for btool → sshd.
- **Key correction vs earlier notes:** the working key is the repo's `id_rsa` (provisioned
  to the device), NOT a per-session fresh key. Fresh keys transfer over 4455 but sshd
  auth-times-out; the repo `id_rsa` authenticates. ALSO: paramiko needs
  `auth_timeout=100` (default 20/30 is too short — device sshd is slow). Both facts matter.
- Live verify: `uname -a` → `QNX BLACKBERRY-528E 8.0.0 ... MSM8960_V3.2.1.1_N_CLASSICNA_Rev:11 armle`;
  NS = `sys.android.gYABgKAOw1czN6neiAT72SGO.ns`; stock `dexopt` = 9684 B root:nto (intact);
  `__root` = `-rwsrwsrwx` present.
- NOTE: this QNX sh lacks `id`/`head`/`head`; use `whoami`, `ls`, `cat` only.

### 2. The full QNX 8.0.0 ARM toolchain is present (Windows host build)
- `/home/stanw47/priv-research/bbndk-tools/bbndk.win32.tools.zip` (304 MB) contains the
  complete **QNX SDP 8.0.0 ARMv7 cross-toolchain**:
  - `qcc.exe` (the QNX compiler driver) + `etc/qcc/gcc/{4.6.3,4.8.3}/gcc_ntoarmv7le*.conf`
  - `ntoarmv7-gcc-4.8.3.exe`, `ntoarmv7-g++-4.8.3.exe`, `ntoarm-ld.exe`, `ntoarmv7-as.exe`,
    `arm-unknown-nto-qnx8.0.0eabi-*` (as/cpp/ar/ranlib/strip/objdump/readelf), `ld.gold`.
  - These are **Windows `.exe`** (no wine on this host; qemu-i386/qemu-arm present but
    Windows PE ≠ Linux ELF, so qemu won't run them directly).
- Also in Downloads: `qnxsdp-6.5.0SP1-x86-201206261830-linux.bin` (111 MB, InstallShield
  MultiPlatform). It needs a 1.5-era **32-bit** JRE and refuses Java 25. `-is:extract`
  only yields `Verify.class` + JVM descriptors; the 110 MB tail is ISMP "product pack"
  beans (compressed; no plaintext `resmgr.h`/`iofunc.h` hits).

### 3. THE EINTR WALL ROOT CAUSE IS NOW EXPLAINED (extracted qcc link recipe)
`ws1/ref/qcc_ntoarmv7le_link_recipe.conf` (extracted from the win32 zip) documents the
EXACT QNX ELF link recipe. This is why every `arm-none-eabi-gcc` build EINTR'd:

```
ld       = ntoarm-ld  (emulation: -m armnto)      <- QNX-specific ld emulation, NOT armelf
ld_opt   = -EL -m armnto --dynamic-linker /usr/lib/ldqnx.so.2 --sysroot=$QNX_TARGET/armle-v7
           --hash-style=gnu --build-id=md5 --warn-shared-textrel -zrelro --eh-frame-hdr
           %(!nopie:-pie)                           <- PIE is the DEFAULT
ld_script= -T$QNX_TARGET/armle-v7/lib/nto.link      <- REQUIRED linker script (we never had it)
startup  = crt1.o crti.o crtbegin.o ... crtend.o crtn.o   (from $QNX_TARGET/armle-v7/lib)
stdlib   = ... -lc -Bstatic -lcS  ...               <- "libcS" startup lib (QNX-only)
cc_opt   = -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -mthumb -mlittle-endian
           -D__QNX__ -D__QNXNTO__ -D__ARM__ ...    (NOT -mfloat-abi=soft, NOT -marm)
```

Corrections this forces on all prior assumptions:
- Interp is `/usr/lib/ldqnx.so.2` which is a symlink to `../../proc/boot/libc.so.3`
  (so `/proc/boot/libc.so.3` was right as the *target*, but the loader is `ldqnx.so.2`).
- The loader requires the `-m armnto` ld emulation + `nto.link` script + QNX `crt*.o` +
  `libcS`. None of these exist in `arm-none-eabi`'s `armelf` backend. That mismatch is
  the most likely source of the EINTR ("Interrupted function call") seen for 16 sessions:
  QNX's loader chokes on a GNU-`armelf`-linked PIE with `-z text`/wrong startup objects.
- Correct flags are `-mfloat-abi=softfp -mfpu=vfpv3-d16` (hard-float calling convention on
  soft-float libc) — sessions used `-mfloat-abi=soft`, another ABI mismatch.

## What this unlocks (the "best and most efficient way")

The #1 blocker is now a known, solvable toolchain problem, not a mystery:
1. **Extract the QNX target tree** (`$QNX_TARGET/armle-v7`: headers `resmgr.h/iofunc.h/iomsg.h`,
   `crt1/crti/crtn.o`, `nto.link`, `libcS`/libc stubs) from either the win32 zip (targets dir
   may be in a sibling `bbndk.win32.target.zip`) or the SDP 6.5.0 installer (needs 32-bit JRE,
   or unpack the ISMP beans manually).
2. **Then produce a genuinely-QNX ELF** using either (a) the Windows toolchain under wine/qemu,
   or (b) `arm-none-eabi`/GNU ld with `-m armnto`-equivalent + the real `nto.link` + QNX crt,
   correcting `-mfloat-abi` and the startup object set. This is the missing fix for GATE A/B/C.
3. The binder resmgr (WS2) and bionic shim (WS1) both need re-verification against a *real*
   QNX ELF, because all current `.so`s are GNU-`armelf` builds — that is likely why nothing
   has executed on-device yet (EINTR), not a trust-gate issue (gate already proven content-based).

## Next concrete actions (ranked)
1. Locate/extract `QNX_TARGET/armle-v7` (headers + crt + nto.link + libc stubs) — check for a
   `bbndk.*.target.zip` or extract SDP 6.5.0's ISMP beans.
2. Rebuild `ws1/libc.so` shim with the correct recipe (`-m armnto`/`nto.link`/QNX crt/`libcS`,
   `-mfloat-abi=softfp -mfpu=vfpv3-d16`), then re-test the exec-gate probe.
3. If EINTR clears → GATE B (bionic) + GATE C (live swap) proceed on real QNX ELFs.

## Safety (unchanged)
- Stock `dexopt` verified intact (9684 B) this session; NS re-derived live.
- `id_rsa` is a live credential — never commit it (already gitignored).

## ADDENDUM — the EINTR smoking gun (found this session)

Characterized the REAL QNX PIE (`dexopt`, pulled from device) byte-for-byte vs our build:

| Field | real dexopt (QNX) | our ws1 build |
|---|---|---|
| Type | DYN (PIE), entry 0x1294 | varies |
| e_flags | 0x5000202 EABI5 **soft-float** | 0x5000200 EABI5 soft-float (match) |
| interp | /usr/lib/ldqnx.so.2 | (PIE tests used /proc/boot/libc.so.3) |
| .note | 04 00 00 00 08 00 00 00 03 00 00 00 "QNX\0" 00 00 00 00 00 10 00 00 | **note.S matches byte-for-byte** |
| .note.gnu.build-id | GNU md5 (--build-id=md5) | missing |
| .gnu.hash | present (--hash-style=gnu) | (host ld default) |
| PIC discipline | -fpic everywhere | **`-fno-pic` in CFLAGS (Makefile:17,93)** |
| text relocs | 0 (pure PIC) | 0 text, BUT 3191 R_ARM_RELATIVE/ABS32 in .data |

**Root cause candidate for the 16-session EINTR wall:** `-fno-pic` in the ws1 CFLAGS
produces a shared object carrying 3191 absolute relocations, and the shim is linked
`-shared` without QNX's `-m armnto`/`nto.link`/`libcS` startup. QNX's `ldqnx.so.2`
loader almost certainly rejects/EINTRs on that non-PIC dynamic object. The fix is:
- `-fpic`/`-fPIC` (not `-fno-pic`) for all shim objects (the trampoline-through-.data
  design already keeps .text clean, so PIC is safe),
- link with `--build-id=md5 --hash-style=gnu`,
- for the executable probe: use interp `/usr/lib/ldqnx.so.2` and a PIE that the QNX
  loader can actually relocate (0 absolute relocs).
- (Longer-term) obtain `nto.link` + QNX crt1/crti/crtn.o + libcS from the SDP target
  package — none present on-device (`/proc/boot/*.o`, `/usr/lib/nto.link` all absent).

## ADDENDUM 2 — EINTR WALL BROKEN (live result)

Two fixes made the difference (both this session):
1. `-fno-pic` → `-fpic` (shim now 0 TEXTREL, was 89 ABS32 text relocs + DT_TEXTREL).
2. **Added `resolver_entry.o` to OBJS** — the shim had an UNDEFINED `ws1_resolver`
   (trampolines `b ws1_resolver` but nothing defined it; the `.S` variant uses
   `:GOTOFF:` which GNU as can't assemble). The C variant `resolver_entry.c` builds
   PIC-clean and now provides `ws1_resolver` (T). Shim went from "0 defined of
   ws1_resolver / U ws1_resolver" to **1729 T, 0 U, 0 TEXTREL**.

Live device result after deploying BOTH the fixed shim AND a rebuilt `test_minimal`
PIE (interp `/usr/lib/ldqnx.so.2`, NEEDED libc.so+libc.so.3, 0 relocs):

    OLD (16 sessions):  sh: ./test_minimal: Interrupted function call   RC=1
    NEW:                ldd:FATAL: Unable to lock mutex
                        Process ... terminated SIGSEGV code=1 fltno=11 ip=01934140
                        RC=139 (core dumped)

=> The QNX dynamic loader now ACCEPTS and begins loading our PIE + shim (it reaches
   pthread mutex init during relocation), instead of EINTR-refusing it. The remaining
   crash is in dynamic-init (our `ws1_onload` constructor's dlopen/dlsym, or a missing
   pthread/TLS init in the shim), a normal debugging target — NOT the exec gate.

This is the "best and most efficient way" landing: the correct QNX ELF recipe
(interp ldqnx.so.2 + PIC + build-id + gnu hash + fully-resolved shim) is what was
missing, and it is now reproduced with the on-hand arm-none-eabi toolchain.

## ADDENDUM 3 — WS1 SHIM RUNS ON DEVICE (RC=0, GOAL ACHIEVED)

The final fix: reorder NEEDED so the REAL QNX `libc.so.3` loads FIRST and the shim
`libc.so` SECOND. Our shim exports `dlopen/dlsym/malloc/free/exit/abort/pthread_*`
(the A11 bionic re-export surface); if the shim is resolved first (LD_LIBRARY_PATH
reorder), the QNX dynamic loader binds ITS OWN needs (mutex init, dlopen) to our
trampolines → `ldd:FATAL: Unable to lock mutex` + SIGSEGV.

    NEEDED order fix: -l:libc.so.3 BEFORE -lc  (libc.so.3 first, shim second)

Live result (devuser, in the sys.android container, LD_LIBRARY_PATH=/tmp/ws1ok):

    [SHIM] init
    Minimal test
    write() works
    RC=0

**THIS IS THE WS1 MILESTONE.** The A11 bionic shim (soname libc.so, 1729 exports,
0 undefined, 0 TEXTREL, PIC) loads and runs on-device; a userland program linked
against it executes `write()` through the shim and exits cleanly. The 16-session
"Interrupted function call" EINTR wall is fully explained and cleared.

### Complete root-cause chain (final, pinned)
1. `-fno-pic` → text relocations (DT_TEXTREL) in the shim → loader rejects. FIX: `-fpic`.
2. `ws1_resolver` was UNDEFINED (trampolines `b ws1_resolver`, but only the
   `:GOTOFF:`-asm variant defined it, which GNU as can't assemble). FIX: link
   `resolver_entry.c` (C variant) → `ws1_resolver` defined, shim self-contained.
3. Shim shadowed loader-critical symbols (dlopen/dlsym/pthread/malloc) because
   LD_LIBRARY_PATH put it ahead of libc.so.3. FIX: NEEDED libc.so.3 FIRST.

### Next (WS1b onward, now unblocked)
- The 858 genuine-bionic glue symbols (futex, __system_property_*, TLS/pthread,
  fdsan, android_mallopt) still resolve to the `__ws1_unimplemented` spin — now
  that the shim loads, replace them one by one with real QNX implementations.
- Re-verify binder resmgr (WS2) + servicemanager against this loading recipe.
- GATE C: live A/B swap harness in the .ns container with the 4.3 fallback.
