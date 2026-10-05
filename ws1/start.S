/* ws1/start.S — minimal QNX entry point for the freestanding smoke test. */
.syntax unified
.arch armv7-a
.text
.global _start
.type _start, %function
.thumb_func
_start:
    b main
.size _start, .-_start