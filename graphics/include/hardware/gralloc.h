/*
 * gralloc.h — Minimal Android gralloc HAL header for QNX build.
 * Subset of system/core/include/hardware/gralloc.h from AOSP 11.
 */

#ifndef ANDROID_GRALLOC_H
#define ANDROID_GRALLOC_H

#include <stdint.h>
#include <sys/cdefs.h>
#include <hardware/hardware.h>

__BEGIN_DECLS

/* gralloc module API versions */
#define GRALLOC_MODULE_API_VERSION_1_0 HARDWARE_MODULE_API_VERSION(1, 0)
#define GRALLOC_MODULE_API_VERSION_2_0 HARDWARE_MODULE_API_VERSION(2, 0)
#define GRALLOC_MODULE_API_VERSION_3_0 HARDWARE_MODULE_API_VERSION(3, 0)
#define GRALLOC_MODULE_API_VERSION_4_0 HARDWARE_MODULE_API_VERSION(4, 0)

#define GRALLOC_HARDWARE_MODULE_ID "gralloc"
#define GRALLOC_HARDWARE_GPU0 "gpu0"

/* Device API versions */
#define GRALLOC_DEVICE_API_VERSION_1_0 HARDWARE_DEVICE_API_VERSION(1, 0)

/* gralloc usage bits */
#define GRALLOC_USAGE_SW_READ_MASK          0x000000FF
#define GRALLOC_USAGE_SW_READ_NEVER         0x00000000
#define GRALLOC_USAGE_SW_READ_RARELY        0x00000002
#define GRALLOC_USAGE_SW_READ_OFTEN         0x00000003
#define GRALLOC_USAGE_SW_WRITE_MASK         0x0000FF00
#define GRALLOC_USAGE_SW_WRITE_NEVER        0x00000000
#define GRALLOC_USAGE_SW_WRITE_RARELY       0x00000200
#define GRALLOC_USAGE_SW_WRITE_OFTEN        0x00000300

#define GRALLOC_USAGE_HW_TEXTURE            0x00000001
#define GRALLOC_USAGE_HW_RENDER             0x00000002
#define GRALLOC_USAGE_HW_2D                 0x00000004
#define GRALLOC_USAGE_HW_COMPOSER           0x00000008
#define GRALLOC_USAGE_HW_FB                 0x00000010
#define GRALLOC_USAGE_HW_VIDEO_ENCODER      0x00000020
#define GRALLOC_USAGE_HW_CAMERA_WRITE       0x00000040
#define GRALLOC_USAGE_HW_CAMERA_READ        0x00000080
#define GRALLOC_USAGE_HW_CAMERA_ZSL         0x00000100
#define GRALLOC_USAGE_HW_CAMERA_MASK        0x000001C0
#define GRALLOC_USAGE_HW_MASK               0x00007FFF

#define GRALLOC_USAGE_PROTECTED             0x00010000
#define GRALLOC_USAGE_CURSOR                0x00020000
#define GRALLOC_USAGE_PRIVATE_0             0x10000000
#define GRALLOC_USAGE_PRIVATE_1             0x20000000
#define GRALLOC_USAGE_PRIVATE_2             0x40000000
#define GRALLOC_USAGE_PRIVATE_3             0x80000000

/* Pixel formats (matching android_pixel_format_t) */
enum {
    HAL_PIXEL_FORMAT_RGBA_8888          = 1,
    HAL_PIXEL_FORMAT_RGBX_8888          = 2,
    HAL_PIXEL_FORMAT_RGB_888            = 3,
    HAL_PIXEL_FORMAT_RGB_565            = 4,
    HAL_PIXEL_FORMAT_BGRA_8888          = 5,
    HAL_PIXEL_FORMAT_RGBA_5551          = 6,
    HAL_PIXEL_FORMAT_RGBA_4444          = 7,
    HAL_PIXEL_FORMAT_YV12               = 0x32315659,  /* YCrCb 4:2:0 planar */
    HAL_PIXEL_FORMAT_YCbCr_422_I        = 0x16,
    HAL_PIXEL_FORMAT_YCbCr_422_SP       = 0x17,
    HAL_PIXEL_FORMAT_YCrCb_420_SP       = 0x18,
    HAL_PIXEL_FORMAT_YCbCr_420_SP       = 0x19,        /* NV21 */
    HAL_PIXEL_FORMAT_YCbCr_420_888      = 0x23,        /* YUV 4:2:0 flexible */
};

/* YCbCr layout for lock_ycbcr - must be defined before gralloc_device_t */
struct android_ycbcr {
    void *y;
    void *cb;
    void *cr;
    void *y_end;
    void *cb_end;
    void *cr_end;
    size_t ystride;
    size_t cstride;
    size_t chroma_step;
    int reserved[4];
};

/* Buffer handle */
typedef struct native_handle {
    int version;
    int numFds;
    int numInts;
    int data[0];
} native_handle_t;

typedef native_handle_t *buffer_handle_t;

/* gralloc1 device */
struct gralloc_device_t {
    struct hw_device_t common;

    int (*alloc)(struct gralloc_device_t *dev, uint32_t w, uint32_t h, uint32_t format, uint32_t usage, buffer_handle_t *handle, int *stride);
    int (*free)(struct gralloc_device_t *dev, buffer_handle_t handle);
    int (*register_buffer)(struct gralloc_device_t *dev, buffer_handle_t handle);
    int (*unregister_buffer)(struct gralloc_device_t *dev, buffer_handle_t handle);
    int (*lock)(struct gralloc_device_t *dev, buffer_handle_t handle, uint32_t usage, int l, int t, int w, int h, void **vaddr);
    int (*unlock)(struct gralloc_device_t *dev, buffer_handle_t handle);
    int (*lock_ycbcr)(struct gralloc_device_t *dev, buffer_handle_t handle, uint32_t usage, int l, int t, int w, int h, struct android_ycbcr *ycbcr);
    int (*perform)(struct gralloc_device_t *dev, int op, ...);
};

/* gralloc2/3/4 device types (forward declarations) */
struct gralloc2_device_t;
struct gralloc3_device_t;
struct gralloc4_device_t;

__END_DECLS
#endif /* ANDROID_GRALLOC_H */