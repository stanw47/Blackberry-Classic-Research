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
	.file	"resolver_entry.c"
	.text
	.align	1
	.global	ws1_resolver
	.syntax unified
	.thumb
	.thumb_func
	.type	ws1_resolver, %function
ws1_resolver:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	ldr	r3, .L2
	ldr	r2, .L2+4
.LPIC0:
	add	r3, pc
	ldr	r3, [r3, r2]
	movs	r2, #12
	muls	r0, r2, r0
	ldr	r0, [r3, r0]
	bx	lr
.L3:
	.align	2
.L2:
	.word	_GLOBAL_OFFSET_TABLE_-(.LPIC0+4)
	.word	ws1_slots(GOT)
	.size	ws1_resolver, .-ws1_resolver
	.section	.text.startup,"ax",%progbits
	.align	1
	.global	ws1_init
	.syntax unified
	.thumb
	.thumb_func
	.type	ws1_init, %function
ws1_init:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	bx	lr
	.size	ws1_init, .-ws1_init
	.section	.init_array,"aw",%init_array
	.align	2
	.word	ws1_init(target1)
	.ident	"GCC: (15:14.2.rel1-1) 14.2.1 20241119"
