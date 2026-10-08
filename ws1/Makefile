# ws1/Makefile — A11 bionic-on-QNX shim (GATE B / WS1)
# Builds libc.so (soname) exporting the A11 bionic ABI surface, delegating to
# the real QNX libc.so.3 via generated Thumb trampolines + a dlsym resolver.
#
# Recipe mirrors the proven helloqnx->libc.so.3 link (session38b):
#   ELF32 ARM EABI5 SOFT-FLOAT, -march=armv7-a -mfloat-abi=soft
# No QNX SDP needed; arm-none-eabi-* + the pulled sysroot suffice.

CROSS   := arm-none-eabi
SYSROOT := ../sysroot/target
CC      := $(CROSS)-gcc
AS      := $(CROSS)-gcc
LD      := $(CROSS)-ld
STRIP   := $(CROSS)-strip
LIBGCCDIR := $(shell dirname $(shell $(CROSS)-gcc -print-libgcc-file-name))
CFLAGS  := -march=armv7-a -mfloat-abi=soft -mthumb -Os -Wall -Wextra \
           -nostdlib -fno-builtin -fpic -ffreestanding
LIBGCCDEFSYM := $(foreach s,$(shell cat libgcc_force.txt),-Wl,--defsym=lw_ref_$(s)=$(s))
OBJS    := build/tramps.o build/resolver.o build/resolver_tab.o build/glue_core.o build/lgcc_tramps.o build/signal_block.o build/resolver_entry.o build/glue_impl.o build/ws1_resolver.o build/prop_impl.o build/tls_impl.o build/malloc_impl.o build/extra_impls.o
LDFLAGS := -nostdlib -Wl,-soname,libc.so $(LIBGCCDEFSYM) \
           -Wl,--version-script=hide_slots.map -Lbuild -L$(SYSROOT)/lib \
           -Wl,--no-as-needed -l:libqnxbind.so -l:libc.so.3 \
           -L$(LIBGCCDIR) -lgcc


all: build/libc.so build/libm.so build/libdl.so

build:
	mkdir -p build

build/tramps.o: tramps.S | build
	$(AS) $(CFLAGS) -c $< -o $@

build/resolver.o: resolver.c resolver.h | build
	$(CC) $(CFLAGS) -c resolver.c -o $@

build/resolver_tab.o: resolver_tab.c resolver.h | build
	$(CC) $(CFLAGS) -c resolver_tab.c -o $@

build/glue_core.o: glue_core.c | build
	$(CC) $(CFLAGS) -c glue_core.c -o $@

build/lgcc_tramps.o: lgcc_tramps.S libgcc_force.txt | build
	$(CC) $(CFLAGS) -c lgcc_tramps.S -o $@

build/libc.so: $(OBJS) build/libqnxbind.so
	$(CC) -shared $(OBJS) -o $@ $(LDFLAGS)
	$(CROSS)-readelf -h $@ | grep -E "Class|Machine|Flags"

# link-time binding table: direct references to QNX libc.so.3 symbols, filled
# by the loader at load time (no dlopen/dlsym at resolution time)
build/qnxbind.o: qnxbind.c | build
	$(CC) $(CFLAGS) -c qnxbind.c -o $@

build/libqnxbind.so: build/qnxbind.o
	$(CC) -shared $< -o $@ -nostdlib -Wl,-soname,libqnxbind.so \
	    -L$(SYSROOT)/lib -Wl,--no-as-needed -l:libc.so.3

# soname-correct empty slabs so A11 NEEDED libm.so / libdl.so resolve
build/libm_stub.o: libm_stub.c | build
	$(CC) $(CFLAGS) -c libm_stub.c -o $@

build/libdl_stub.o: libdl_stub.c | build
	$(CC) $(CFLAGS) -c libdl_stub.c -o $@

build/libm.so: build/libm_stub.o
	$(CC) -shared $< -o $@ -nostdlib -Wl,-soname,libm.so -Wl,--version-script=hide_slots.map -L$(SYSROOT)/lib -l:libc.so.3

build/libdl.so: build/libdl_stub.o
	$(CC) -shared $< -o $@ -nostdlib -Wl,-soname,libdl.so -Wl,--version-script=hide_slots.map -L$(SYSROOT)/lib -l:libc.so.3

# regenerate trampolines + slot table from the ref/gate_b export maps
gen:
	python3 gen_tramps.py

# verify the export surface against the A11 reference list
check: build/libc.so
	$(CROSS)-nm -D --defined-only build/libc.so | awk '{print $$3}' | sed 's/@.*//' | sort -u > build/exported.txt
	python3 check_exports.py

# verify a specific bacon lib's UND imports all resolve (shim + QNX libc)
resolvelib: check
	python3 resolve_against.py ../ref/a11_system/system/lib/libz.so

clean:
	rm -rf build

.PHONY: all gen check clean
	$(AS) $(CFLAGS) -c $< -o $@


	$(AS) $(CFLAGS) -c $< -o $@

build/signal_block.o: signal_block.c | build
	$(CC) $(CFLAGS) -c signal_block.c -o $@

# session41: no-NEEDED fully-self-contained PIE (zero NEEDED libs => loader does no lib search, only maps the piece)
build/test_noneed: build/start.o build/note.o build/sig_block_noneed.o build/test_minimal.o | build
	$(CC) -nostdlib -Wl,-pie -Wl,-e,_start -Wl,-z,notext -o $@ build/start.o build/note.o build/sig_block_noneed.o build/test_minimal.o $(CFLAGS) 2>/dev/null || \
	$(CC) -nostdlib -Wl,-pie -Wl,-e,_start -o $@ build/start.o build/note.o build/sig_block_noneed.o build/test_minimal.o

# session42 fork-A: no-NEEDED self-contained PIE (loader has zero deps to resolve)
CFLAGSN := -march=armv7-a -mfloat-abi=soft -mthumb -Os -Wall -Wextra -nostdlib -fno-builtin -fpic -ffreestanding -fno-stack-protector -Wl,-z,defs

build/resolver_entry.o: resolver_entry.c resolver.h | build
	$(CC) $(CFLAGS) -c resolver_entry.c -o $@

build/glue_impl.o: glue_impl.c resolver.h | build
	$(CC) $(CFLAGS) -c glue_impl.c -o $@

build/ws1_resolver.o: ws1_resolver.S | build
	$(AS) $(CFLAGS) -c ws1_resolver.S -o $@

build/prop_impl.o: prop_impl.c resolver.h | build
	$(CC) $(CFLAGS) -c prop_impl.c -o $@

build/tls_impl.o: tls_impl.c resolver.h | build
	$(CC) $(CFLAGS) -c tls_impl.c -o $@

build/malloc_impl.o: malloc_impl.c resolver.h | build
	$(CC) $(CFLAGS) -c malloc_impl.c -o $@

build/extra_impls.o: extra_impls.c | build
	$(CC) $(CFLAGS) -c extra_impls.c -o $@
