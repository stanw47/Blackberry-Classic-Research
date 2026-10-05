# session39 — GATE B/WS1: A11 bionic export-map + libbionic-on-QNX scaffold builds

## Milestone
- **GATE B export map is now complete** (was the "Blocked" item: `qnx_libc_exports.txt` empty because binutils can't parse QNX's nonstandard `.dynamic`).
- **WS1 scaffold (`ws1/`) builds and exports the FULL A11 bionic surface** with the existing `arm-none-eabi` toolchain + pulled sysroot — no QNX SDP needed.
- `make check`: **A11 ref 1668 ↔ exported 1669, missing 0** (only extra is `_stack`, which QNX libc.so.3 itself exports).

## Unblocking the QNX libc export list
- `readelf/objdump/nm` all fail on `sysroot/target/lib/libc.so.3`:
  - host `readelf --dyn-syms` → `Error: no .dynamic section in the dynamic segment`
  - `objdump -T` → `invalid operation` ; `nm -D` → `no symbols`
  - Root cause: QNX uses its own dynamic segment layout/tags that binutils rejects (GNU_HASH present, sysv hash absent).
- Fix: small Python parser walks the `.dynsym` directly (`SYMTAB` @0x4bc8, entsize 16, `STRTAB` @0xd678, 27407 bytes from `readelf -d`);
  extracted **2215 unique global exports** → `ref/gate_b/qnx_libc_exports.txt`.
  (Names confirmed sane by eyeball: `ChannelCreate`, `MsgSendv`, `CacheFlush`, `Idle`, 25 `pthread_mutex_*`, `__stack_chk_fail`, `__aeabi_*`, ...)
- Also fixed a latent data bug: `a11_bionic_exports.txt` had been built with `sed 's/@@.*//'` which strips the `@@LIBC` default version but **leaves `@LIBC_PRIVATE`** on the ARM ABI helpers, so 14 `__aeabi_*`/`__gnu_Unwind_Find_exidx` symbols dropped out of the mapping. Rebuilt with `sed 's/@.*//'` → dedup list is 1668 (1682 raw incl. version tags).

## GATE B classification (the 1539 A11-only surface)
| group | count | meaning |
|---|---|---|
| total A11 bionic exports | 1682 (1668 dedup) | bionic libc.so/@LIBC |
| overlap with RIM 4.3 libbionic | 143 | RIM's QNX glue already exists → port their mappings |
| **same-name in QNX libc.so.3** | **667** | direct alias, `dlsym`-resolvable |
| **genuine bionic glue** | **858** | `__system_property_*`, `android_fdsan_*`, `futex`→SyncCondvar, `__libc_init`, `android_mallopt`, `__bionic_brk`, net-stats, `__get_tls`/`__get_thread` handling, etc. |

Files: `ref/gate_b/a11_alias_to_qnx.txt` (667), `a11_need_glue.txt` (858), `qnx_libc_exports.txt` (2215), `a11_bionic_exports.txt` (1668), `43_libbionic_exports.txt` (265).

## WS1 scaffold (`ws1/`)
Builds `libc.so` (soname `libc.so`, NEEDED `libc.so.3`) exporting the full A11 surface via per-symbol Thumb trampolines that jump through writable `.data` slots, filled at load by a constructor that `dlsym`s each alias straight out of the real QNX libc.so.3 (resolved against that handle only, so it can't recurse into our own re-export).

- `gen_tramps.py` — emits `tramps.S` (~25k lines) + `resolver_tab.c` from the three gate-B sets
- `resolver.c`/`resolver.h` — constructor resolver (RTLD scoping to libc.so.3) + `__ws1_unimplemented` abort landing pad
- `Makefile` — same recipe as the helloqnx probe: `-march=armv7-a -mfloat-abi=soft -mthumb -nostdlib`, link `-L../sysroot/target/lib -l:libc.so.3`
- Build+check: `make gen && make && make check`
- Verified output: `ELF32, ARM, Flags 0x5000200 (Version5 EABI, soft-float ABI)`, soname `libc.so`, `NEEDED libc.so.3`; `memcpy` disassembles to `ldr.w ip,[pc,#8] / ldr.w ip,[ip] / bx ip` (Thumb, interworking-safe).
- glue (858) + overlap-with-4.3 (143) currently resolve to the `__ws1_unimplemented` landing pad; they are the WS1b work items.

## WS1b next-work (needs QNX headers, else hand-declared)
- `__system_property_*` → PPS/shmem broker; `futex`/`__futex_wait/wake` → QNX SyncCondvar; `android_fdsan_*` table; `android_mallopt`; `__bionic_brk`/`sbrk`; uid/gid translation (`android_get_device_api_level` → build props).
- Port RIM 4.3 mappings for the 143 overlap (specimens/libbionic.so 265 exports is the reference).
- If run: trigger on-device via the GATE C hot-swap harness (not started this session).

## Not done / parking-lot
- `ref/a11_system` symlink-vs-file inconsistency still unresolved (451 `-type l` vs sym=0 dump).
- `_stack` joins the export list (harmless; QNX libc.so.3 also exports it) — optional `.hidden`.
- F2 (runtime-stopped boot survives) was already confirmed back during basebundle-graft work; not re-run.
- SDP 6.5 extraction still blocked (JRE/sudo/wine); no QNX headers on host or device.