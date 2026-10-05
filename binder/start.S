/* binder/start.S — QNX ARM entry point (Thumb).
 *
 * Reconstructed from RIM's own binder entry (specimens/binder @ 0x1930), which
 * loads argc/argv from the initial stack that the QNX loader sets up:
 *
 *   ldr r0, [sp]          @ argc
 *   add r1, sp, #4        @ argv = sp + 4
 *   add r2, r1, r0, lsl#2 @ envp = argv + argc*4
 *   add r2, r2, #4        @ (past the NULL argv terminator)
 *   bl  main
 *
 * The previous `b main` left argc/argv undefined, so main()'s argv[i] was
 * garbage and resmgr_attach passed a bad path pointer to pathmgr_link
 * (ldrsb [path] -> SIGSEGV ref=0xff200121).
 */
.syntax unified
.arch armv7-a
.thumb
.text
.global _start
.type _start, %function
.thumb_func
_start:
    mov     r4, r0              @ preserve loader-passed r0
    ldr     r0, [sp]            @ argc
    add     r1, sp, #4          @ argv = &argv[0]
    lsl     r3, r0, #2
    add     r2, r1, r3          @ envp = argv + argc*4
    add     r2, r2, #4          @ envp (past NULL terminator)
    mov     r3, r2
    bl      main
    bl      exit                @ r0 = main's return; RIM's crt does the same
.size _start, .-_start
