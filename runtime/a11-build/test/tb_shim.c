/* tb_shim — control probe.  Links ONLY the WS1 shim (libc.so) + the real QNX
 * libc.so.3 (no libc++), so it exercises the shim constructor + trampolines
 * without any C++ static-init ordering.  Expected on-device: "[SHIM] init"
 * from the shim ctor, then "A11 libs loaded", RC=0. */
typedef unsigned long size_t;
extern int write(int, const void *, size_t);
extern void _exit(int);
extern int __system_property_set(const char *, const char *);

int main(void)
{
    __system_property_set("tb.shim", "1");
    write(1, "A11 libs loaded\n", 16);
    _exit(0);
    return 0;
}
