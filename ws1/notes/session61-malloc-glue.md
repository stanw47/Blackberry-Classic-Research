# session61 — malloc/dlmalloc glue runs on-device

Date 2026-09-19. Continues session60. Classic live via SSH.

## Milestone
malloc-family glue implemented and verified on-device:

    malloc=1 usable_size=64 realloc=1 calloc=1 calloc_zero=1 reallocarray=1   RC=0

## Key architecture facts (from QNX libc.so.3 export map)
- `malloc`/`free`/`calloc`/`realloc`/`memalign`/`posix_memalign` are ALREADY in the
  ALIAS list — they resolve to QNX libc via dlsym, no shim impl needed. This is the
  single biggest simplification: QNX ships a full malloc.
- `_msize` (usable size) and `__brk`/`_curbrk` are also in QNX libc.so.3.

## What was implemented (ws1/malloc_impl.c)
bionic-SPECIFIC surface with no QNX equivalent:
- dlmalloc/dlfree/dlcalloc/dlrealloc/dlmemalign -> forward to QNX malloc family
- malloc_usable_size / dlmalloc_usable_size -> QNX `_msize`
- reallocarray -> overflow-checked realloc
- brk/sbrk -> QNX __brk/_curbrk
- dlmalloc_footprint/max_footprint/trim/stats/inspect_all -> stubs (0/empty)
- malloc_info/enable/disable/iterate/backtrace -> stubs

## RIM reference (4.3 libbionic disasm)
- RIM shipped a FULL dlmalloc inside libbionic (dlmalloc at 0xff04 does the classic
  "adds r0,#11; bic #7; subs #4" chunk-header adjustment then jumps to a real
  dlmalloc core at __udivdi3+0x44c). We do NOT need to port it — QNX malloc suffices
  for the shim; dlmalloc* forwards to it.

## Hook globals (__malloc_hook/__free_hook/__realloc_hook/__memalign_hook/__bionic_brk)
These are DATA symbols (NULL globals in bionic) but gen_tramps.py generated FUNCTION
trampolines for them (they're in the A11 export list). Defining them as globals
caused "multiple definition" link errors vs the trampolines. Deferred: they remain
trampoline-exports for now; proper data-symbol support in the trampoline generator
is a follow-up (rarely used in the smoke phase).

## Build/verify
- 12 ws1_impl_* malloc functions; 3 undefined (__brk/_curbrk/_msize — resolved at
  load from libc.so.3); 0 TEXTREL.

## Next (WS1b)
- Data-symbol support in gen_tramps.py (for __malloc_hook etc. + __errno + environ).
- Re-run binder resmgr (WS2) verification against the now-correct shim.
- GATE C: live A/B swap harness in the .ns container.
