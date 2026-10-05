# Host build for the portable A11 binder engine + tests.
# No QNX toolchain is required here; glue layers elsewhere swap the alloc hook.

CC      ?= gcc
CFLAGS  ?= -O2 -g
CWARN    = -Wall -Wextra
PINCS    = -Iinclude -Isrc
PTHREAD  = -pthread

all: build/test_abi build/test_binder build/test_glue

build:
	mkdir -p $@

build/test_abi: tests/test_abi.c include/binder_a11.h | build
	$(CC) $(CFLAGS) $(CWARN) $(PTHREAD) $(PINCS) $< -o $@

build/test_binder: tests/test_binder.c src/binder_core.c src/binder_core.h include/binder_a11.h | build
	$(CC) $(CFLAGS) $(CWARN) $(PTHREAD) $(PINCS) src/binder_core.c tests/test_binder.c -o $@

build/test_binder_asan: tests/test_binder.c src/binder_core.c | build
	$(CC) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer \
	    $(CWARN) $(PTHREAD) $(PINCS) src/binder_core.c tests/test_binder.c -o $@

build/test_glue: tests/test_glue.c src/binder_core.c src/binder_handlers.c src/binder_core.h src/binder_handlers.h include/binder_a11.h | build
	$(CC) $(CFLAGS) $(CWARN) $(PTHREAD) $(PINCS) src/binder_core.c src/binder_handlers.c tests/test_glue.c -o $@

build/test_glue_asan: tests/test_glue.c src/binder_core.c src/binder_handlers.c | build
	$(CC) -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer \
	    $(CWARN) $(PTHREAD) $(PINCS) src/binder_core.c src/binder_handlers.c tests/test_glue.c -o $@

test: build/test_abi build/test_binder build/test_glue
	@./build/test_abi
	@./build/test_binder
	@./build/test_glue

asan: build/test_binder_asan build/test_glue_asan
	ASAN_OPTIONS=detect_leaks=1 ./build/test_binder_asan
	ASAN_OPTIONS=detect_leaks=1 ./build/test_glue_asan

clean:
	rm -rf build

.PHONY: all test asan clean