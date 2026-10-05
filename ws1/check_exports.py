import sys
a11=set(open("../ref/gate_b/a11_bionic_exports.txt").read().split())
got=set(open("build/exported.txt").read().split())
miss=a11-got
print("A11 ref: %d  exported: %d  missing: %d"%(len(a11),len(got),len(miss)))
for m in sorted(miss)[:30]: print("  MISS", m)
