/* ws1/libdl_stub.c — A11 libdl.so is an empty slab ort AOSP.
 * dlopen/dlsym/dlclose/dlerror are re-exported by the shim (libc.so)
 * as alias trampolines to the real QNX libc.so.3 implementations.
 */
int __ws1_libdl_dummy;