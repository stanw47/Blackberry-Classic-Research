/* ws1/start.S — QNX entry point: run libc's startup init before main.
 * Mirrors RIM's crt (specimen __android_system @0x8e8):
 *   argc/argv/envp from the initial stack, auxv scan, _init_libc(argc,argv,envp),
 *   then main(argc,argv,envp) -> exit().
 */
.syntax unified
.arch armv7-a
.text
.global _start
.type _start, %function
.thumb_func
_start:
    ldr r0, [sp]            @ argc
    add r1, sp, #4          @ argv
    add r2, r1, r0, lsl #2
    add r2, r2, #4          @ envp = &argv[argc+1]
    push {r0, r1, r2}       @ keep argc/argv/envp (also 8-aligns sp)
    mov r3, r2
1:  ldr ip, [r3], #4        @ scan past envp strings (auxv position)
    teq ip, #0
    bne 1b
    bl _init_libc           @ QNX libc startup (connection/fd state etc.)
    pop {r0, r1, r2}        @ restore args
    bl main
    mov r4, r0
    bl exit
2:  b 2b
.size _start, .-_start
