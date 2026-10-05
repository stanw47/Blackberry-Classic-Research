# usage: resolve_against.py <A11 ELF .so or binary>
# Reconstructs the link resolution ldqnx will perform for each undefined
# symbol: it must be exported by the WS1 shim (tramp/libgcc/glue_core) or by
# an already-loaded QNX libc.so.3 that ldqnx pulls in.
import subprocess, sys, os, re

sysroot = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "ref", "gate_b")


def load(p):
    return set(open(p).read().split())


exports = load(f"{sysroot}/a11_bionic_exports.txt")
qnx = load(f"{sysroot}/qnx_libc_exports.txt")
alias = load(f"{sysroot}/a11_alias_to_qnx.txt")
overlap = load(f"{sysroot}/43_libbionic_exports.txt")
glue = load(f"{sysroot}/a11_need_glue.txt")
libgcc = set(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "libgcc_impl.txt")).read().split())
gcore = set(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "glue_core_impl.txt")).read().split())

tgt = sys.argv[1]
need_of = subprocess.run(["arm-none-eabi-readelf", "--dyn-syms", tgt],
                         capture_output=True, text=True).stdout
needed = []
for line in need_of.splitlines():
    f = line.split()
    if len(f) == 8 and f[6] == "UND":
        needed.append(f[7])
miss = []
reroute = []
for raw in needed:
    n = raw.split("@")[0]
    if n in exports:
        if n in libgcc or n in gcore:
            reroute.append((raw, n, "GLUE/libgcc (real impl)"))
        elif n in glue:
            reroute.append((raw, n, "GLUE stub (abort pad)"))
        elif n in alias:
            reroute.append((raw, n, "alias->QNX"))
        else:
            reroute.append((raw, n, "shim export"))
    elif n in qnx:
        reroute.append((raw, n, "direct QNX libc.so.3 symbol"))
    else:
        miss.append(raw)
print(f"{os.path.basename(tgt)}: {len(needed)} undefined import(s)")
for raw, n, how in sorted(reroute):
    print(f"  OK   {raw:32s} -> {how}")
for m in sorted(miss):
    print(f"  MISS {m}")
sys.exit(1 if miss else 0)