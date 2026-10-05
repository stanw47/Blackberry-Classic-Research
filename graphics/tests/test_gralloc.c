/*
 * test_gralloc.c — Basic validation test for gralloc_qnx module.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>
#include <hardware/gralloc.h>
#include <hardware/hardware.h>

#define CHECK(cond, msg) do { \
    if (!(cond)) { \
        fprintf(stderr, "FAIL: %s\n", msg); \
        exit(1); \
    } else { \
        printf("PASS: %s\n", msg); \
    } \
} while (0)

int main(void)
{
    void *dlhandle = dlopen("./build/libgralloc_qnx.so", RTLD_LAZY);
    CHECK(dlhandle != NULL, "dlopen libgralloc_qnx.so");

    struct hw_module_t *module = dlsym(dlhandle, "HAL_MODULE_INFO_SYM");
    CHECK(module != NULL, "HAL_MODULE_INFO_SYM found via dlsym");

    CHECK(strcmp(module->id, GRALLOC_HARDWARE_MODULE_ID) == 0, "module ID is gralloc");
    CHECK(module->hal_api_version != 0, "HAL API version non-zero");

    struct hw_device_t *device = NULL;
    int rc = module->methods->open(module, GRALLOC_HARDWARE_GPU0, &device);
    CHECK(rc == 0, "gralloc device open");
    CHECK(device != NULL, "device handle non-NULL");

    struct gralloc_device_t *gralloc = (struct gralloc_device_t *)device;

    /* Test allocation */
    buffer_handle_t handle = NULL;
    int stride = 0;
    rc = gralloc->alloc(gralloc, 1920, 1080, HAL_PIXEL_FORMAT_RGBA_8888,
                        GRALLOC_USAGE_HW_TEXTURE | GRALLOC_USAGE_SW_WRITE_OFTEN,
                        &handle, &stride);
    CHECK(rc == 0, "alloc 1920x1080 RGBA_8888");
    CHECK(handle != NULL, "alloc returned handle");
    CHECK(stride > 0, "stride > 0");
    printf("  stride = %d\n", stride);

    /* Test lock */
    void *vaddr = NULL;
    rc = gralloc->lock(gralloc, handle, GRALLOC_USAGE_SW_WRITE_OFTEN, 0, 0, 1920, 1080, &vaddr);
    CHECK(rc == 0, "lock buffer");
    CHECK(vaddr != NULL, "lock returned valid address");
    printf("  vaddr = %p\n", vaddr);

    /* Test unlock */
    rc = gralloc->unlock(gralloc, handle);
    CHECK(rc == 0, "unlock buffer");

    /* Test register/unregister */
    rc = gralloc->register_buffer(gralloc, handle);
    CHECK(rc == 0, "register_buffer");
    rc = gralloc->unregister_buffer(gralloc, handle);
    CHECK(rc == 0, "unregister_buffer (refcount > 0, not freed)");

    /* Free the buffer */
    rc = gralloc->free(gralloc, handle);
    CHECK(rc == 0, "free buffer");

    /* Close device */
    rc = device->close(device);
    CHECK(rc == 0, "device close");

    dlclose(dlhandle);
    printf("\nAll gralloc tests passed!\n");
    return 0;
}