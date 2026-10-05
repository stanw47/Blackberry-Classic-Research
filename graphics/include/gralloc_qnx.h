/*
 * gralloc_qnx.h — QNX screen-backed gralloc module for Android 11.
 *
 * Implements the gralloc1 (hardware_module_t) interface using QNX Screen API
 * for buffer allocation, mirroring RIM's libgralloc_screen.so pattern.
 *
 * References:
 *   - RIM libgralloc_screen.so exports: gralloc_alloc, gralloc_free,
 *     gralloc_register_buffer, gralloc_unregister_buffer, gralloc_garbage_collect
 *   - QNX Screen API: screen_create_context, screen_create_window_buffers,
 *     screen_get_buffer_property_iv, mem_offset64, mlock
 */

#ifndef GRALLOC_QNX_H
#define GRALLOC_QNX_H

#include <stdint.h>
#include <sys/types.h>

/* Forward declarations from hardware/gralloc.h and hardware/hardware.h */
struct hw_module_t;
struct hw_device_t;
struct gralloc_device_t;
struct android_ycbcr;
typedef struct native_handle *buffer_handle_t;

#ifdef SCREEN_API_STUB
typedef long off64_t;
static inline int mem_offset64(void *addr, size_t offset, size_t len, off64_t *phys, int *fd) {
    (void)addr; (void)offset; (void)len; (void)phys; (void)fd;
    return -1;
}
#else
#include <sys/neutrino.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* QNX Screen context handle (opaque) */
struct qnx_screen_context;

/* Private gralloc device structure - defined in gralloc_qnx.c */
struct gralloc_qnx_device_t;

/* Module methods */
int gralloc_qnx_open(const struct hw_module_t *module, const char *name, struct hw_device_t **device);
int gralloc_qnx_close(struct hw_device_t *device);

/* gralloc1 device methods */
int gralloc_qnx_alloc(struct gralloc_device_t *dev, uint32_t w, uint32_t h, uint32_t format, uint32_t usage, buffer_handle_t *handle, int *stride);
int gralloc_qnx_free(struct gralloc_device_t *dev, buffer_handle_t handle);
int gralloc_qnx_register_buffer(struct gralloc_device_t *dev, buffer_handle_t handle);
int gralloc_qnx_unregister_buffer(struct gralloc_device_t *dev, buffer_handle_t handle);
int gralloc_qnx_lock(struct gralloc_device_t *dev, buffer_handle_t handle, uint32_t usage, int l, int t, int w, int h, void **vaddr);
int gralloc_qnx_unlock(struct gralloc_device_t *dev, buffer_handle_t handle);
int gralloc_qnx_lock_ycbcr(struct gralloc_device_t *dev, buffer_handle_t handle, uint32_t usage, int l, int t, int w, int h, struct android_ycbcr *ycbcr);
int gralloc_qnx_perform(struct gralloc_device_t *dev, int op, ...);

/* Internal helpers */
struct qnx_screen_context *qnx_screen_context_create(void);
void qnx_screen_context_destroy(struct qnx_screen_context *ctx);
int qnx_screen_alloc_buffer(struct qnx_screen_context *ctx, uint32_t w, uint32_t h, uint32_t format, uint32_t usage, int *out_fd, void **out_vaddr, size_t *out_size, int *out_stride);
void qnx_screen_free_buffer(struct qnx_screen_context *ctx, int fd, void *vaddr, size_t size);

#ifdef __cplusplus
}
#endif
#endif /* GRALLOC_QNX_H */