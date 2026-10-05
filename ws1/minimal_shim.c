/* Absolute minimal shim - just the symbols test_smoke needs */
__attribute__((naked)) void write(void) { asm("ldr r12, =0xdeadbeef; bx r12"); }
__attribute__((naked)) void exit(void) { asm("ldr r12, =0xdeadbeef; bx r12"); }
__attribute__((naked)) void strlen(void) { asm("ldr r12, =0xdeadbeef; bx r12"); }
__attribute__((naked)) void __errno(void) { asm("ldr r12, =0xdeadbeef; bx r12"); }
__attribute__((naked)) void __strlen_chk(void) { asm("ldr r12, =0xdeadbeef; bx r12"); }
__attribute__((naked)) void dlopen(void) { asm("ldr r12, =0xdeadbeef; bx r12"); }
__attribute__((naked)) void dlsym(void) { asm("ldr r12, =0xdeadbeef; bx r12"); }
__attribute__((naked)) void dlclose(void) { asm("ldr r12, =0xdeadbeef; bx r12"); }
__attribute__((naked)) void malloc(void) { asm("ldr r12, =0xdeadbeef; bx r12"); }
__attribute__((naked)) void free(void) { asm("ldr r12, =0xdeadbeef; bx r12"); }
__attribute__((naked)) void abort(void) { asm("ldr r12, =0xdeadbeef; bx r12"); }
