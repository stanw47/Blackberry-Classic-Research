	.arch armv7-a
	.fpu softvfp
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 4
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"test_got.c"
	.text
	.align	1
	.global	test_got
	.syntax unified
	.thumb
	.thumb_func
	.type	test_got, %function
test_got:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	ldr	r3, .L2
	ldr	r0, [r3]
	bx	lr
.L3:
	.align	2
.L2:
	.word	ws1_slots
	.size	test_got, .-test_got
	.ident	"GCC: (15:14.2.rel1-1) 14.2.1 20241119"
