#!/usr/bin/env python3
"""Split an Android boot.img into kernel + ramdisk (header v0-v2)."""
import struct, sys

def main(path, outdir):
    f = open(path, 'rb').read()
    assert f[:8] == b'ANDROID!'
    ksz = struct.unpack_from('<I', f, 8)[0]
    rsz = struct.unpack_from('<I', f, 16)[0]
    page = struct.unpack_from('<I', f, 36)[0]
    base = page
    kernel = f[base:base + ksz]
    koff = ((base + ksz + page - 1) // page) * page
    ramdisk = f[koff:koff + rsz]
    open(f"{outdir}/kernel.bin", "wb").write(kernel)
    open(f"{outdir}/ramdisk.gz", "wb").write(ramdisk)
    print(f"kernel {len(kernel)}B page={page}; ramdisk {len(ramdisk)}B")

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])