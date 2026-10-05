# Session 30 - Can we redo the Android runtime via the autoloader? (user: MINIMUM 11, PREFERABLY 15)

Device: PRD-64100 Classic, OS 10.3.3, rooted. Date: 2026-09-13.

## User directive

- Provided: `/home/stanw47/Downloads/Z30_10.3.03.3216_STA100-1-2-3-4-5-6-root_v2.exe`
  (a 3 GB Z30 rooted autoloader).
- Question: is there a way to completely redo the Android runtime via the autoloader
  method? Goal articulated: MINIMUM Android 11, PREFERABLY Android 15, in the runtime.
  Reverse-engineer EXACTLY how the autoloader installs the runtime (.bar), then replace
  it ourselves.

## Part 1 - We can already decode and rebuild autoloaders (verified live)

Our own tooling read BlackBerry's Z30 install table byte-accurately:

`tools/check_autoloader.py` on the 3 GB exe:
- PE tail signature OK (`0x9cd5c597` x3), nfiles=2.
- file0 @0x8d2e84 (mfcq, v2): IFS(11010048) + RFS(402849792) + SIG2(65536) + OS/MBR(65536) + User/UFS(2598567936) = 3012559248 B.
- file1 @0xb41d3014 (mfcq): Radio RFS(54525952) + sig2 + mbr = 54657856 B.

We already own the equivalent for our Classic:
- `work/classic_root.0.lst` lists the 5 OS images and 3 radio images.
- `work/classic_root.0.signed` (3012559248 B) + `work/classic_root.ex` (the 3 GB
  autoloader we BUILT and previously flashed) — i.e. `tools/make_autoloader.py` already
  produces and we already flashed our own signed autoloaders.
- The Android runtime `.bar` (`sys.android.<ns>`) lives inside the UFS (User) image that
  the autoloader writes to the device's user storage — the same one we mount/edit as root.

Conclusion: packaging-wise, we can produce, sign, and flash a custom autoloader whose UFS
carries a replaced/modified runtime. That half of the premise is TRUE and proven.

## Part 2 - The hard ceiling: Android 11/15 cannot run "in the runtime", because there is
no Linux kernel under the runtime

The runtime is NOT an Android-OS container. It is a QNX-native userland port (proven in
session29 + libbionic ELF analysis): Android 4.3's framework/zygote/libdvm compiled as
**QNX processes** on the QNX microkernel. Android 11 (kernel 5.4/GKI) and Android 15
(kernel 6.x/GKI 2.0) are Linux-kernel operating systems. Requirements push against:
- No Linux ELF/binary ABI on QNX procnto -> stock AOSP 11/15 userland cannot exec.
- No Linux kernel that the Android userland needs (binder v2 required, proper Binderfs,
  DRM/KMS, ION/DMA-buf of the 5.x/6.x era) -> QNX provides none of these; android_resmgr
  only FAKES a Linux 3.2.41 banner to the 4.3 userland.
- The SoC (MSM8960, Adreno 225 = OpenGL ES 2.0 only) cannot satisfy Android 11/15 stack
  requirements (Vulkan/GLES3, modern GPU stacks). Community Lineage cap for this SoC class
  is roughly Android 9-11 tops, and even that only on Linux-native phones (Razr HD class),
  never on QNX hardware.
- No one has ever produced Android 5+ binaries for QNX. BlackBerry themselves stopped the
  runtime at Android 4.3.

So "replace the .bar with an Android 11/15 runtime in the autoloader" has no target to
install: the artifact does not exist and cannot be built from available materials.

## Part 3 - What the autoloader lane DOES buy us (real deliverables)

1. **Bake the graft INTO the autoloader** instead of live device edits: replace runtime
   framework jars / BaseBundle inside `native/system` of the UFS before flashing. Clean
   image -> ability to produce the "COMPAT ROM" as a distributable flashable we ship/keep.
2. **Swap the whole runtime bar variant** (e.g., a different OS build's sys.android) or
   restore pristine copies for A/B experiments with rollback via re-flash.
3. **Full OS replacement is theoretically possible in the same container format** — but a
   Linux-kernel AOSP/Lineage for this hardware is a separate, very large BSP project
   (touch, display, radio RIL, etc.), analogous to community mainboard-swap efforts, and it
   would ABANDON BB10 entirely. Android 15 on Adreno 225 is broadly out of reach even then.

## Verdict for the user decision
- "Completely redo the runtime via autoloader" = YES for everything within the QNX 4.3
  runtime (framework replacement baked into the flash image).
- "Android 11-15 in the runtime" = NO, regardless of autoloader. It needs a Linux kernel
  under Android; there is no Linux kernel; the SoC also can't run 11/15 meaningfully.
- Realistic envelope of "COMPAT runtime": stay on the 4.3 QNX native core; maximize the
  Java/framework layer (session29). If true modern Android is the goal, it requires the
  full-OS-replacement route (a different class of project).

## Artifacts
- `tools/check_autoloader.py` output above (decodes the Z30 exe's 2 mfcq tables).
- `tools/make_autoloader.py` + `work/classic_root.*` (our proven own-image build/flash).
- Z30 exe untouched on disk.

## Next action proposed
Decide the definition of "redo": (a) distribute the framework-graft as a custom autoloader
ROM (achievable now), or (b) pivot to the full-OS-replacement Linux/Android BSP (major
project, abandons BB10, Adreno 225 caps it well below 15).