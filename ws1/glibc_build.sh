#!/bin/bash
set -e
CROSS=arm-none-eabi
SYSROOT=../sysroot/target
CC=${CROSS}-gcc
CFLAGS="-march=armv7-a -mfloat-abi=soft -mthumb -Os -nostdlib -fno-builtin -fno-pic -ffreestanding -fPIC"
LIBGCCDIR=$(${CROSS}-gcc -print-libgcc-file-name | xargs dirname)
LIBGCCDEFSYM=$(for s in $(cat libgcc_force.txt); do echo "-Wl,--defsym=lw_ref_${s}=${s}"; done)
LDFLAGS="-nostdlib -Wl,-soname,libc.so ${LIBGCCDEFSYM} -Wl,--version-script=hide_slots.map -L${SYSROOT}/lib -l:libc.so.3 -L${LIBGCCDIR} -lgcc"

# Build objects with -fPIC
${CC} ${CFLAGS} -c tramps.S -o build/tramps.o
${CC} ${CFLAGS} -c resolver.c -o build/resolver.o
${CC} ${CFLAGS} -c resolver_tab.c -o build/resolver_tab.o
${CC} ${CFLAGS} -c glue_core.c -o build/glue_core.o
${CC} ${CFLAGS} -c lgcc_tramps.S -o build/lgcc_tramps.o

# Link shim with -fPIC
${CC} -shared ${CFLAGS} build/tramps.o build/resolver.o build/resolver_tab.o build/glue_core.o build/lgcc_tramps.o -o build/libc.so ${LDFLAGS}
${CROSS}-readelf -h build/libc.so | grep -E "Class|Machine|Flags"

# Build libm.so
${CC} ${CFLAGS} -c libm_stub.c -o build/libm_stub.o
${CC} -shared ${CFLAGS} build/libm_stub.o -o build/libm.so -nostdlib -Wl,-soname,libm.so -Wl,--version-script=hide_slots.map -L${SYSROOT}/lib -l:libc.so.3

# Build libdl.so
${CC} ${CFLAGS} -c libdl_stub.c -o build/libdl_stub.o
${CC} -shared ${CFLAGS} build/libdl_stub.o -o build/libdl.so -nostdlib -Wl,-soname,libdl.so -Wl,--version-script=hide_slots.map -L${SYSROOT}/lib -l:libc.so.3

# Verify text relocations
echo "libc.so text relocations:"
${CROSS}-readelf -r build/libc.so | grep -c "R_ARM_RELATIVE"
