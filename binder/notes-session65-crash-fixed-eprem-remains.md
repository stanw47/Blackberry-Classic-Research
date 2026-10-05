# session65 — binder resmgr RUNS: two crash root-causes fixed from real loader
# disassembly; sole remaining blocker is resmgr_attach -> EPERM (ability)

Date 2026-09-19. Continues session64. Classic live via SSH. Binder resmgr A/B resolved.

## HEADLINE
The binder resmgr no longer crashes. It runs end-to-end and `resmgr_attach`
returns a **real errno (EPERM)**. Both SIGSEGVs were root-caused by reading the
**actual QNX loader machine code** (`specimens/linker` == `/usr/lib/ldqnx.so.2`,
which has symbols: `pathmgr_link @0x2b790`, `resmgr_attach @0x264fc`) and RIM's
own binder entry point (`specimens/binder @0x1930`) — NOT by guessing struct
layouts. The previous session's "struct-layout" theory was a dead end.

## Root cause #1 — start.S never set argc/argv  (crash ref=0xff200121)
Real loader flow, decoded:
- `resmgr_attach(dpp=r0, attr=r1, path=r2, ftype=r3, ...)`; at `0x266cc` it calls
  `pathmgr_link(r0 = the PATH string, ...)`.
- `pathmgr_link @0x2b790`; `+0x54` = `0x2b7e4` = `ldrsb r3, [r6]` where `r6=r0=path`
  — it reads **the first byte of the path string**.
- On device this faulted at `ref=0xff200121`: the path pointer itself was garbage.
- Our `start.S` was literally `b main`. It never loaded argc/argv from the initial
  stack the QNX loader sets up, so `main`'s `argv[i]` was junk -> resmgr_attach
  got a garbage path -> `pathmgr_link` crashed reading it.
- RIM's real entry (`specimens/binder @0x1930`) does:
      ldr r0, [sp]              @ argc
      add r1, sp, #4            @ argv
      add r2, r1, r0, lsl #2    @ envp
  Rewrote `start.S` accordingly, and added `bl exit` after `main` (else main's
  `return` fell off `_start` into data -> `ip=6363612e` ("acc") fault).

## Root cause #2 — stderr aliased to _Stderr  (crash _Lockfilelock+0x2c)
- `specimens/linker` exports BOTH:
    `stderr  @0x444f0  DO .data 4`    -> a **FILE* variable**
    `_Stderr @0x4453c  DO .data 0x50` -> the **FILE object**
- Our stub did `extern void *_Stderr; #define stderr _Stderr`, so `fprintf(stderr,…)`
  passed the object's FIRST WORD (0x802) as the FILE*. That crashed inside
  `_Lockfilelock+0x2c` = `ldr r3,[r4,#72]` with r4=0x802 -> `ref=0x84a`.
- Fix: `extern void *stderr;` (use QNX's exported FILE* variable). Committed.

## build_qnx.sh (new, committed)
Reproducible freestanding PIE cross-build (start.S + binder.c + binder_core.c +
binder_handlers.c). Flags (from user-supplied notes session63/64):
  -march=armv7-a -mfloat-abi=soft -mthumb -Os -nostdinc -nostdlib -fpic
  -ffreestanding -fno-builtin
  compile: -Iqnxinc -Iinclude -Isrc -include sys/cdefs.h -include qnx_resmgr_proto.h
  link:    -Wl,-pie -Wl,-e,_start -Wl,--dynamic-linker=/usr/lib/ldqnx.so.2
           -Wl,--hash-style=gnu -Wl,--build-id=md5
           -Wl,--export-dynamic -Wl,--unresolved-symbols=ignore-all
           -Wl,--no-as-needed -L../sysroot/target/lib -l:libc.so.3
start.S is assembled separately (no C -include).

## On-device result now (devuser, LD_LIBRARY_PATH via /tmp/ws1ok)
```
usage: binder <path> [<path> ...]          (no-args path works)
[binder] init: before dispatch_create
[binder] init: before iofunc_func_init
[binder] init: after iofunc_func_init
[binder] init: iofunc_attr_init(/dev/binder)
[binder] init: before resmgr_attach(/dev/binder)
resmgr_attach('/dev/binder') failed: Operation not permitted
RC=1
```
No crash, no fault, clean exit.

## SOLE REMAINING BLOCKER — resmgr_attach -> EPERM (ability/security policy)
- EPERM is set by `pathmgr_link`'s `_connect` to the path manager (per the
  disassembly failure path: pathmgr_link returns -1, resmgr_attach frees the link
  and preserves errno). So it is a **path-manager/kernel authorization** result.
- Reproduced for every path tried: `/dev/binder`, `/tmp/bnode`, relative `bnode`
  (so it is NOT a directory-permission problem; `/dev` is drwxr-xr-x root:nto but
  /tmp is writable by devuser and still EPERM).
- RIM's binder imports NO ability-granting call (only geteuid / isAndroidClient /
  retainBinderSystemCapabilities, and that runs AFTER attach). => In RIM's
  environment the resmgr name is granted by security policy to the signed/shipped
  binary. Our unsigned devuser PIE is refused.
- Corollary confirmed: run as `root` (via /base/bin/__root) the SAME binary is
  refused at exec by the loader trust gate ("Operation not permitted") — the
  session41 EINTR/trust-gate class — which is a SEPARATE problem from the EPERM.

## Next (session66) — the ability/policy question, in order
1. Determine which QNX ability gates resmgr path registration on this Classic
   (likely the `PATH`/`PROCMGR`/`NTO` ability, or a secpol entry for the binary).
   Look at: `procmgr_ability`(not exported by linker — check libc.so.3),
   `/etc/secpol` / security policy files, and how other /dev resmgrs are launched.
2. Decide which fork the user wants:
   (a) get our binder the needed ability (secpol entry / signed .bar / launch
       under a privileged launcher), or
   (b) drop the QNX-native resmgr path and revisit the Android-runtime graft
       (ws1) line, which is where the A11 binder actually needs to live.
3. Do NOT re-open struct-layout debugging: resmgr_attr_t (nparts_max@+4,
   msg_max_size@+8), thread_pool_attr_t (68B), iofunc_mount_t (24B),
   iofunc_funcs_t (24B), connect=8, io=29 are all now confirmed against the
   loader's own code (resmgr_attach reads [rattr+4] and [rattr+8]; clamps
   msg_max_size to >=1557).

## Files
- binder/start.S        (rewritten: argc/argv + exit)
- binder/build_qnx.sh   (new: reproducible cross-build)
- binder/qnxinc/qnx_compat.h (stderr -> extern FILE* variable)
- binder/notes-session65-*.md (this file)
Commits: see git log (session65 crash fixes).

## session65 cont. — ABILITY/POLICY INVESTIGATION (user chose this fork)

### Verified facts from the real binaries
- `specimens/linker` (== /usr/lib/ldqnx.so.2, symbol-rich) contains the SOURCE URLs:
    lib/c/services/pathmgr_link.c
    lib/c/services/procmgr_ability_lookup.c
    lib/c/iofunc/iofunc_ability.c
- `procmgr_ability_lookup` (linker @0x3c1ac) builds a **message type 26** and sends
  it via MsgSendvnc_r to the process manager, with an ability-name STRING.
- The ONLY ability-name strings present anywhere in libc/ldqnx are:
    "iofunc/chown", "iofunc/read", "iofunc/exec", "iofunc/dup"
  -> These are CLIENT-side iofunc checks. There is NO "pathmgr"/"pathspace"/
  resmgr-registration ability name in this OS build.
- The ability RAISER `procmgr_ability()` is NOT exported by ldqnx (only
  `procmgr_ability_lookup`). So a userland process on this Classic cannot grant
  itself a path-registration ability at all.

### RIM's binder ordering re-checked (specimens/binder main @0x16dc)
  setgroups(0,0) -> setregid(1000,1000) -> setreuid(1000,1000)   [drops to uid 1000]
  -> ChannelCreate(0)+pthread (notif thread) -> dispatch_create
  -> iofunc_func_init(8,...,29,...) -> iofunc_attr_init(S_IFCHR|0666)
  -> attr.mount = STATIC iofunc_mount_t (never sets mount->funcs)
  -> resmgr_attach(dpp,&rattr(32B),path,_FTYPE_ANY=0,0,connect,io,&attr)
  -> retainBinderSystemCapabilities()   [AFTER attach]
  -> thread_pool_start
RIM makes NO ability call before attach, and attaches successfully **as uid 1000**.
=> the grant is by SECURITY POLICY / process identity, not a runtime API.

### Live device probes (Classic)
- `resmgr_attach` EPERM for every path: /dev/binder, /tmp/bnode, relative "bnode".
  => not a directory-permission issue; it is process-authorization.
- `/bin/on -u root <our binder>` -> "Unable to init user root (Operation not permitted)"
  => devuser cannot switch to a privileged user.
- `/bin/on <our binder>` (no user) -> same resmgr_attach EPERM.
- root channel (`/base/bin/__root`) -> the SAME binary fails to EXEC at all
  ("Operation not permitted") => the session41 loader trust-gate, a distinct gate.
- Stock resmgrs in /dev are all root:nto and launched by the system image.

### CONCLUSION (definitive for this environment)
Our unsigned devuser PIE cannot register a resmgr path name on this Classic:
- no grantable path-registration ability exists to call, and
- the path manager authorizes by process identity/policy, which an unsigned
  PIE run from /tmp does not have.
The binder code itself is now correct (no crashes; real errno). The remaining
blocker is fundamentally about **process identity/policy** (signed .bar / system
image launch), not about the resmgr ABI.

### Consequence for the two paths
- QNX-native resmgr line: to actually attach /dev/binder we must deploy the binary
  the way shipped resmgrs are deployed: inside a signed .bar / as a system-image
  service launched by init with the right identity — NOT exec'd from /tmp.
- WS1/Android-runtime line: the A11 binder lives in the Android namespace anyway;
  the loader trust-gate there remains the real battleground (session39-41).

### Recommended next
Package `binder` into the existing BB10 .bar/service flow used by
`/apps/sys.android.*.ns` (see notes/ session28 APK->drawer, session30 autoloader)
so it can be started as a recognized service, OR accept the WS1 graft line.

## session65 cont.2 — DECISIVE CONTEXT: /dev/binder ALREADY EXISTS in the Android
## namespace (owned uid 1000:10011); our EPERM was the WRONG NAMESPACE/IDENTITY

Live device facts (Classic, devuser SSH):
- `/dev/binder` is a QNX namespace link, `nrw-rw---- 1 1000 10011` (uid 1000 =
  android `system`, gid 10011 = android_system). It was created Sep 17 05:04.
- Sibling Android bridge nodes all present:
    /dev/android/{eventfd,lowmemorykiller,acquire/release_partial_wake_lock,epoll}
    /dev/alarm (android_system:10011), /dev/activity, /dev/backlight, etc.
- So the Classic ALREADY RUNS the Android runtime's own QNX namespace with a
  binder node in it. (Matches notes/ANDROID-RUNTIME-COMPLETE-MAP.md: the runtime
  lives in `/apps/sys.android.gYABgKAOw1czN6neiAT72SGO.ns/native/`.)
- devuser cannot read other procs (`/proc/<pid>/as` EPERM spam) and cannot create
  names in the base `/dev` (root-only, 0755) — hence resmgr_attach EPERM in the
  BASE namespace.

=> The EPERM is NOT "no ability exists"; it is that our binder attached in the
   WRONG namespace as the WRONG identity. The target is the `.ns` container's
   Android namespace, running as the Android system user, which is exactly how
   RIM's binder is deployed (session38 model: Android procs are QNX-native ELFs
   in the .ns container interposed by libbionic).

### Corrected next step for the binder
Deploy `binder` INTO the Android runtime container
(`/apps/sys.android.gYABgKAOw1czN6neiAT72SGO.ns/native/system/...`) and launch it
there with the Android identity/namespace, rather than exec'ing from /tmp/ws1ok
in the base QNX namespace. That is also the real WS2 milestone (session38 M4:
"A11 binder resmgr drops into the running container; first binder-mediated ping").
The base-namespace EPERM result is expected and is not the blocker it appeared.

### Evidence trail
- specimens/linker = ldqnx.so.2 (symbols); pathmgr_link@0x2b790, resmgr_attach@0x264fc
- specimens/binder = RIM 4.3 binder (main@0x16dc; entry@0x1930 loads argc/argv)
- live: /dev/binder n 1000:10011; /dev/android/* ; /dev/alarm android_system:10011

## session65 cont.3 — THE DEPLOYMENT CONTRACT (pulled live from the container)

The container's own launcher script is authoritative. From
`/apps/sys.android.gYABgKAOw1czN6neiAT72SGO.ns/native/scripts/start-android-core.sh`:

    export PATH=/system/bin:/proc/boot:/bin:/usr/bin:/sbin:/usr/sbin:...
    export LD_LIBRARY_PATH=/system/lib:/proc/boot:/lib:/usr/lib:/lib/dll
    export ANDROID_PLAYER_HOME=$appdir
    lowmemorykiller &   ; waitfor /dev/android/lowmemorykiller 20
    android_resmgr &    ; waitfor /data 20
    epolld &            ; waitfor /dev/android/epoll 20
    logd &              ; waitfor /dev/log/main 20 ; waitfor /dev/log/system 20
    binder &            ; waitfor /dev/binder 20        <-- OUR TARGET
    shrimp &

Key facts:
- `binder` is invoked by BARE NAME -> resolved via PATH=/system/bin. The container
  ALREADY SHIPS RIM's 4.3 `binder` at `native/system/bin/binder` (30440 B == the
  exact bytes in specimens/binder).
- It runs INSIDE the Android Player (comment: "intended for use within the Android
  Player, *not* from a root shell"). That is what gives it the namespace +
  Android identity under which `/dev/binder` (uid 1000:10011) is legal.
- LD_LIBRARY_PATH includes `/system/lib` = the container's own libs (libbionic.so,
  libbinder.so, ...). Our freestanding binder needs QNX libc.so.3 which is on the
  same path, so no change needed there.

### => The concrete WS2/M4 action (session38 M4: "A11 resmgr drops into the
### running container; first binder-mediated ping over the live resmgr")
1. Stage our A11 `binder` at `native/system/bin/binder` (container `system/` is
   drwxrwxrwx; scripts/ dir is drwxrwxrwx -> writable from devuser).
2. Preserve RIM's original (copy to `binder.rim43`) for A/B fallback (session38 M3).
3. Restart the Android core (restart-android-core.sh) so the container's
   start-android-core.sh launches OUR binder and `waitfor /dev/binder` gates on it.
4. First test: attach succeeds (no EPERM — right namespace/identity), then a
   binder-mediated ping.

This supersedes the base-namespace /tmp exec test, which correctly returned EPERM
and is not the deploy path.

## session65 cont.4 — deployment staging done; PLAYER STATE for next session
- Android core is currently NOT running (pidin: no binder/init/zygote/epolld/etc).
  `/dev/binder` is a STALE namespace link from the last player run (Sep 17,
  uid 1000:10011) — namespace links outlive the process.
- Backed up RIM's binder: `native/system/bin/binder.rim43` (30440 B) — A/B fallback
  preserved (session38 M3).
- Staged our A11 binder at `/tmp/a11binder` (15516 B, freestanding PIE, NEEDED
  libc.so.3). NOT yet installed over `native/system/bin/binder` (safe; core down).
- devuser CAN write `native/system/bin` (world-writable) but CANNOT write
  `/dev/android` (root) — confirms the privileged namespace is the player's.

### Next session (M4) exact sequence
1. `cp /tmp/a11binder <ns>/native/system/bin/binder` (RIM original already backed up).
2. Launch the Android player so the container namespace + `start-android-core.sh`
   run and gate on `waitfor /dev/binder`. (Player launch path: see
   notes/ANDROID-RUNTIME-COMPLETE-MAP.md §7 `launch-android.sh` /
   msg::start_system into /pps/services/launcher/control, and session22.)
3. Observe: does OUR binder register /dev/binder (no EPERM in the right namespace)?
   Does `waitfor /dev/binder 20` pass?
4. If it attaches, do the first binder-mediated ping; if not, restore binder.rim43.

### Open question for M4
Whether our freestanding PIE (linked against libc.so.3 with GNU hash / NEEDED) is
accepted by the container's own `linker` (AOSP-style, /system/bin/linker) OR by the
QNX loader. Inside the player the interpreter is the container's `/system/bin/linker`
for Android libs; our binary's INTERP is `/usr/lib/ldqnx.so.2`. Need to confirm the
player runs QNX-native ELFs directly (RIM's binder IS a QNX ELF with the same
/usr/lib/ldqnx.so.2 interp — see specimens/binder), which it does. So ours matches.

## session65 cont.5 — A11 binder INSTALLED in the container (A/B ready)
- `mv` (atomic rename) succeeded where `cp` failed with "Resource busy" (QNX holds an
  ETXTBSY on in-use executables; rename swaps cleanly).
- State now:
    native/system/bin/binder        = 15516 B  <- OUR A11 binder (freestanding PIE)
    native/system/bin/binder.rim43  = 30440 B  <- RIM 4.3 binder (preserved fallback)
- Android player is DOWN (pidin shows only 6 procs: sh, test_futex, qconn, sshd).
  `/dev/binder` is a stale namespace link (uid 1000), not a live resmgr.
- Launching the player needs root: `launch-android.sh` writes
  `/pps/services/launcher/control` (msg::start_system ...) -> devuser denied.

### To activate the A/B (needs one root/UI action)
Option 1 (UI): open the Android player app on the device (launcher icon / a .bar
  Android app) -> QNX app registry boots the container -> start-android-core.sh runs
  -> launches OUR binder, gates on `waitfor /dev/binder`.
Option 2 (root): write `msg::start_system\ndat::sys.android.<ns>\n` into
  `/pps/services/launcher/control` as root.
Then observe whether /dev/binder re-registers (our binder, no EPERM) and whether
the core comes up; if binder fails, restore binder.rim43.

## session65 cont.6 — activation limit: PPS start_system did not boot the player
- Ran `launch-android.sh` as root (`__root`); it returned rc=0 and (should have)
  written `msg::start_system\ndat::sys.android.<ns>\n` into
  `/pps/services/launcher/control`.
- Result after waiting: NO change. pidin still shows only 5 procs (sh, test_futex,
  qconn, sshd, pidin). `/dev/binder` unchanged (stale Sep 17, uid 1000).
- Cause: `/pps/services/launcher/control` is a PPS object consumed by a running
  launcher service. With no launcher/app-manager running in this rooted-userland
  SSH session, the message is inert. Also `cat` of control shows empty (PPS reads
  require open-for-read + struct semantics, not cat).

### => Activation must be a DEVICE UI action (or a running UI session)
Tap an Android app icon on the Classic (or otherwise invoke the Android Player) so
the QNX app framework boots the container; its `scripts/start-android-core.sh` then
launches `binder` (now OUR A11 binder) and gates on `waitfor /dev/binder`.

### A/B is STAGED and READY (one UI tap away)
    native/system/bin/binder       = OUR A11 binder (15516 B)
    native/system/bin/binder.rim43 = RIM 4.3 (30440 B) fallback
When the player is next started from the UI, observe:
  - Does `waitfor /dev/binder` pass (our resmgr registers in the right namespace)?
  - binder-mediated ping.
If our binder fails, restore: `mv binder.rim43 binder` (via root/UI shell).

Everything is committed; this is the clean handoff point for the next session.
