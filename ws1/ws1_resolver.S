	.syntax unified
	.arch armv7-a
	.thumb
	.fpu softvfp
	.text

/* ws1_resolver — tail-jump to the resolved function, preserving r0-r3 (args),
 * r9 (PIC SB) and lr.  The trampolines pass the symbol index in r12 (ip).
 *
 * Lazy-safe: if the slot has not been filled yet (constructor not run, or run
 * out of order relative to other DSOs), call the hidden C helper
 * ws1_resolve_slot(&ws1_slots[idx]) to fill it, then use the returned pointer.
 * This removes any dependency on .init_array ordering across libraries.
 *
 * Only r0-r3/r12/lr are scratch here; r4-r11 are left untouched so no callee-
 * saved register has to be preserved.  sp stays 8-byte aligned (6-word frame).
 */
	.global ws1_resolver
	.hidden ws1_resolver
	.type ws1_resolver, %function
	.thumb_func
ws1_resolver:
	push	{r0, r1, r2, r3, r4, lr}   @ 24-byte frame (keeps 8-byte alignment)
	mov	r1, r12                    @ r1 = idx
	ldr	r0, .Lgotbase
.Lpic:
	add	r0, pc                     @ r0 = GOT base
	ldr	r2, .Lslots
	add	r2, r0
	ldr	r2, [r2]                   @ r2 = &ws1_slots
	add	r3, r2, r1, lsl #4         @ r3 = &ws1_slots[idx] (16-byte struct)
	ldr	r2, [r3]                   @ r2 = slot.ptr
	ldr	r0, [r2]                   @ r0 = *ptr (resolved fn, 0 if unfilled)
	cmp	r0, #0
	bne	.Lhave
	mov	r0, r3                     @ arg = &slot
	bl	ws1_resolve_slot           @ hidden -> bound at link time
.Lhave:
	mov	r12, r0
	ldr	r0, [sp, #0]
	ldr	r1, [sp, #4]
	ldr	r2, [sp, #8]
	ldr	r3, [sp, #12]
	ldr	r4, [sp, #16]
	ldr	lr, [sp, #20]
	add	sp, sp, #24
	bx	r12
	.align 2
.Lgotbase:
	.word	_GLOBAL_OFFSET_TABLE_ - .Lpic - 4
.Lslots:
	.word	ws1_slots(GOT)
