# session49 — THE EXEC-SHAPE MATRIX IS COMPLETE (5 shapes, 5 behaviors — all live-verified)

Date 2026-09-16, grader: device live via tunnel (169.254.0.1), arm-none-eabi, devuser.

## Live matrix (each row = a real on-device exec probe with readelf-verified ELF):
| #  | Type| INTERP            | NEEDED     | TEXTREL | devuser exec result            | meaning |
|----|----|-------------------|------------|---------|--------------------------------|---------|
| 1  | DYN| /proc/boot/libc.so.3| libc+dl+m | 0       | EINTR RC=1 (both stock/devinodes)| dyld reloc = EINTR site |
| 2  | DYN| /proc/boot/libc.so.3| 0 (shim)   | 0       | EINTR RC=1 (signal_block NO help)| dyld EINTR is unconditional |
| 3  | DYN| (none)            | 0          | 0       | "Attempting to exec a shared lib" | DYN-no-interp: exec class reject |
| 4  | EXEC| (none)          | 0          | 0       | ENOEXEC → ash "syntax error"      | EXEC-no-interp: ENOEXEC, gate PASS |
| 5  | EXEC| /proc/boot/libc.so.3| 0        | 0       | **(UNPROBED)** — the ONLY remaining | queued probe #6 = last wall test |

## So the wall is PROVEN loader-relocation at PT_INTERP; three candidate dyld-EINTRE freeze configs all failed to clear. 
## Next (probe #6, queued): Type EXEC + STOCK interp /proc/boot/libc.so.3 + 0 NEEDED + 0 TEXTREL.
##   → if RC=0: GATE+LOADER defeated with the STOCK-INTERPROCESS shape (dynamic privileged loader medl.. !!) 
##   → if RC=EINTR again: dyld EINTR at interp fetch is unconditional → must skip dyld (SVC-direct payload).

## Build (host verify then deploy):
# (link command incl. resolver.o+tramp set that produces this shape — FIXING the last link's dropped objs)
arm-none-eabi-gcc -march=armv7-a -mfloat-abi=soft -mthumb -Os -Wall -Wextra -nostdlib -fno-builtin -fno-pic -ffreestanding -fno-stack-protector \
  -Wl,-Ttext=0x08000000 -Wl,-e,_start -Wl,-Bstatic -Wl,-z,now \
  -o build/test_interp_i486318 build/start_i486318.o build/note_i486318.o build/test_minimal_i486318.o build/signal_block_i486318.o build/glue_core_i486318.o build/tramps_i486318.o build/resolver_i486318.o build/resolver_tab_i486318.o build/lgcc_tramps_i486318.o \
  $(arm-none-eabi-gcc -march=armv7-a -mfloat-abi=soft -mthumb -print-libgcc-file-name) \
  -Wl,--dynamic-linker=/proc/boot/libc.so.3 -Wl,--no-as-needed
echo "LINK_RC=$?"
echo "== verify: Type EXEC / INTERP=/proc/boot/libc.so.3 / NEEDED should be 0 / TEXTREL 0 =="
arm-none-eabi-readelf -h build/test_interp_i486318 2>/dev/null | grep -E "Type:|Machine|Entry"
echo " INTERP=$(arm-none-eabi-readelf -l build/test_interp_i486318 2>/dev/null | grep -c INTERP) NEEDED=$(arm-none-eabi-readelf -d build/test_interp_i486318 2>/dev/null | grep -c NEEDED) TEXTREL=$(arm-none-eabi-readelf -d build/test_interp_i486318 2>/dev/null | grep -c TEXTREL)"
ls -ln build/test_interp_i486318 2>/dev/null
echo "SES49_BUILD_DONE"
