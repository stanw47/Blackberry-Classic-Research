# Graphics subsystem build for QNX target
# Host build: stubs QNX Screen API for compilation validation
# Target build: links against libscreen.so.1, libimg.so.1

CC      ?= gcc
CFLAGS  ?= -O2 -g -std=c99
CWARN   = -Wall -Wextra -Wno-unused-parameter
PINCS   = -Iinclude -Isrc
LDFLAGS = -pthread -ldl

# Host stubs for QNX Screen API (compile validation only)
HOST_STUBS = -DSCREEN_API_STUB

all: build/libgralloc_qnx.so build/test_gralloc

build:
	mkdir -p $@

# Host build with stubbed Screen API
build/libgralloc_qnx.so: src/gralloc_qnx.c include/hardware/gralloc.h include/hardware/hardware.h | build
	$(CC) $(CFLAGS) $(CWARN) $(HOST_STUBS) $(PINCS) -fPIC -shared $< -o $@ $(LDFLAGS)

build/test_gralloc: tests/test_gralloc.c build/libgralloc_qnx.so | build
	$(CC) $(CFLAGS) $(CWARN) $(PINCS) $< -o $@ $(LDFLAGS)

# Target build (uncomment when QNX toolchain available)
# QCC = qcc -Vgcc_ntoarmv7le
# QFLAGS = -O2 -g -fPIC -shared
# QINCS = -Iinclude -Isrc
# QLDFLAGS = -lscreen -limg -pthread
# build/libgralloc_qnx.so: src/gralloc_qnx.c include/hardware/gralloc.h include/hardware/hardware.h | build
# 	$(QCC) $(QFLAGS) $(QINCS) $< -o $@ $(QLDFLAGS)

test: build/test_gralloc
	LD_LIBRARY_PATH=./build ./build/test_gralloc

clean:
	rm -rf build

.PHONY: all test clean