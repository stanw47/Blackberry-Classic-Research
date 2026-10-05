# session50 — exec-shape decision matrix (live-verified) + correct queued final link

Date 2026-09-16 · Device tunnel volatile all session; several deploy probes garbled by my own
host heredoc/quoting (single-quote + paramiko recipe) — those failures are HOST my-fault, NOT
device findingsched. Only readelf-verified-on-both-sides datapoints are listed below.

## The 5 real datapoints (host `arm-none-eabi-readelf` sync-verified BEFORE deploy)
| shape            | ELF type | PT_INTERP         | NEEDED | TEXTREL | devuser exec (live)          |
|------------------|----------|-------------------|--------|---------|------------------------------|
| stock dexopt     | EXEC     | /proc/boot/libc.so.3 | 0    | 0       | N/A (stock baseline)          |
| our PIE          | DYN      | /proc/boot/libc.so.3 | libc/libdl/libm | 0 | **RC=1 EINTR** (gate PASSES ours) |
| PIE + signal_block| DYN     | same               | same   | 0       | **RC=1 EINTR** (ctor too late) |
| no-NEEDED PIE    | DYN      | (none)             | 0      | 0       | "Attempting to exec a shared lib" RC=1 [ENOEXEC-class] |
| fully-static EXEC| EXEC     | (none)             | 0      | 0       | ash fallback "syntax error" → ENOEXEC-class, NO EINTR |

## Verdict
- **Trust gate is content/open**: our bytes on both trusted-inode(9824) and fresh untrusted
  inode give the SAME EINTR (never EPERM). The only wall is QNX dyld EINTR during its
  relocation pass, and it fires only when PT_INTERP is present (it does NOT fire for
  no-interp shapes — those die at ENOEXEC-class instead, i.e. the gate lets them through
  differently).
- The remaining, ONLY unprobed, and **stock-identical** shape: `Type EXEC + PT_INTERP
  /proc/boot/libc.so.3 + 0 NEEDED + 0 TEXTREL` — exactly what stock dexopt already is. If
  that execs as devuser → endgame proven (loader bypassed without touching the gate).

## Queued correct final link (was failing ONLY because I kept dropping resolver objs)
Use the FULL ws1 object set incl. resolver/resolver_tab (defines ws1_resolver — my last 3
link attempts undefined-referenced it):

```bash
cd ws1
arm-none-eabi-gcc -march=armv7-a -mfloat-abi=soft -mthumb -Os -Wall -Wextra \
  -nostdlib -fno-builtin -fno-pic -ffreestanding -fno-stack-protector \
  -nostartfiles -fno-common \
  -Wl,-e,_start -Wl,-Ttext=0x08000000 -Wl,-z,noreloc -Wl,-Bstatic \
  -o build/test_interp \
  build/glue_core.o build/note.o build/resolver.o build/resolver_tab.o \
  build/start.o build/tramps.o build/signal_block.o build/lgcc_tramps.o build/test_minimal.o \
  $(arm-none-eabi-gcc -march=armv7-a -mfloat-abi=soft -mthumb -print-libgcc-file-name)
# verify: Type EXEC / INTERP=/proc/boot/libc.so.3 / NEEDED=0 / TEXTREL=0
arm-none-eabi-readelf -h  build/test_interp | grep -E "Type|Machine|Entry"
arm-none-eabi-readelf -l  build/test_interp | grep -A1 INTERP
arm-none-eabi-readelf -d  build/test_interp | grep -cE "NEEDED|TEXTREL"
```

## Next (single move)
1. Run the link above → readelf-verify the 4 markers.
2. sftp to /tmp/ws1ok (fresh tmpfs each boot), root-pipe `chown 89:89`+`chmod 555`
   (numeric uid per deploy docs), exec `./test_interp` as devuser t≥300:
   - RC=0 → GATE OPEN + LOADER BYPASSED, WS1 in-place proven on stock-identical shape.
   - RC=1 → the EINTR persists on this shape too → pivot to SVC-direct payload (Fork B).
