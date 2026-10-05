/* Simple shim: direct alias to QNX libc.so.3 symbols via asm jump */
__attribute__((naked)) void write(void) {
    asm("ldr r12, =0xdeadbeef\n\tbx r12"); // placeholder
}
__attribute__((naked)) void exit(void) {
    asm("ldr r12, =0xdeadbeef\n\tbx r12");
}
__attribute__((naked)) void strlen(void) {
    asm("ldr r12, =0xdeadbeef\n\tbx r12");
}
__attribute__((naked)) void __errno(void) {
    asm("ldr r12, =0xdeadbeef\n\tbx r12");
}
__attribute__((naked)) void __strlen_chk(void) {
    asm("ldr r12, =0xdeadbeef\n\tbx r12");
}
__attribute__((naked)) void dlopen(void) {
    asm("ldr r12, =0xdeadbeef\n\tbx r12");
}
__attribute__((naked)) void dlsym(void) {
    asm("ldr r12, =0xdeadbeef\n\tbx r12");
}
__attribute__((naked)) void dlclose(void) {
    asm("ldr r12, =0xdeadbeef\n\tbx r12");
}
__attribute__((naked)) void malloc(void) {
    asm("ldr r12, =0xdeadbeef\n\tbx r12");
}
__attribute__((naked)) void free(void) {
    asm("ldr r12, =0xdeadbeef\n\tbx r12");
}
__attribute__((naked)) void abort(void) {
    asm("ldr r12, =0xdeadbeef\n\tbx r12");
}
