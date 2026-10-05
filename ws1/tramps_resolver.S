	.syntax unified
	.arch armv7-a
	.thumb
	.fpu softvfp
	.text

	.global ws1_resolver
	.type ws1_resolver, %function
	.thumb_func
ws1_resolver:
	/* r0 = index */
	/* ws1_slots address passed in r9 (SB) by the dynamic linker */
	/* Use r9 as GOT base - standard ARM EABI for PIC */
	/* ws1_slots is at fixed offset from GOT base */
	ldr r12, [r9, #:GOTOFF:ws1_slots]
	lsl r0, r0, #2
	add r12, r12, r0
	ldr r12, [r12]
	bx r12
