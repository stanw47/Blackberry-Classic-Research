#!/usr/bin/env python3
"""Rebuild an ext4 system image from an Android OTA transfer list.

Usage:
    brotlidec <file.dat.br> -> <file.dat>            (streaming brotli decode)
    sdat2img <transfer.list> <new.dat> <output.img>  (reassemble ext4)

Reference: AOSP system/updater / sdat2img. Verified on:
  lineage-18.1-20250101-UNOFFICIAL-wseries (Passport, A11, 2GiB image).
"""
import brotli, os, re, sys

def brotlidec(src, dst):
    inp = open(src, 'rb').read()
    out = brotli.decompress(inp)   # one-shot; ~8GiB RAM enough for a 2GiB img
    with open(dst, 'wb') as f:
        f.write(out)
    print(f"[brotlidec] {len(out)} bytes -> {dst}")

def sdat2img(transfer, newdat, img):
    with open(transfer) as f:
        lines = [l.strip() for l in f if l.strip() and not l.startswith('#')]
    version = int(lines[0])
    BLOCK = 4096
    cmds = []
    for l in lines[4:]:
        m = re.match(r'^(new|zero|erase)\s+(.*)$', l)
        if m:
            nums = [int(x) for x in m.group(2).split(',')]
            cmds.append((m.group(1), nums))
    maxblk = 0
    with open(img, 'wb') as of:
        for typ, nums in cmds:
            if typ == 'erase':
                for a, b in zip(nums[1::2], nums[2::2]):
                    maxblk = max(maxblk, b)
                    of.seek(b * BLOCK - 1); of.write(b'\0')
        of.truncate(maxblk * BLOCK)
        of.seek(0)
        with open(newdat, 'rb') as nf:
            for typ, nums in cmds:
                if typ == 'new':
                    for a, b in zip(nums[1::2], nums[2::2]):
                        nb = b - a
                        if nb > 0:
                            chunk = nf.read(nb * BLOCK)
                            of.seek(a * BLOCK); of.write(chunk)
                elif typ == 'zero':
                    for a, b in zip(nums[1::2], nums[2::2]):
                        if b > a:
                            of.seek(a * BLOCK); of.write(b'\0' * ((b - a) * BLOCK))
    print(f"[sdat2img] {os.path.getsize(img)} bytes -> {img}")

if __name__ == '__main__':
    if sys.argv[1] == 'brotlidec':
        brotlidec(sys.argv[2], sys.argv[3])
    elif sys.argv[1] == 'sdat2img':
        sdat2img(sys.argv[2], sys.argv[3], sys.argv[4])
    else:
        sys.exit('usage: sdat2img.py [brotlidec|sdat2img] ...')