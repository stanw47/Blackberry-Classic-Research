/*
 * hardware.h — Minimal Android hardware HAL header for QNX build.
 * Subset of system/core/include/hardware/hardware.h from AOSP 11.
 */

#ifndef ANDROID_HARDWARE_H
#define ANDROID_HARDWARE_H

#include <stdint.h>
#include <sys/cdefs.h>

__BEGIN_DECLS

#include <errno.h>

#define HARDWARE_MODULE_TAG MAKE_TAG('H', 'W', 'M', 'T')
#define HARDWARE_DEVICE_TAG MAKE_TAG('H', 'W', 'D', 'T')

#define MAKE_TAG(t1, t2, t3, t4) \
    ((t1) | ((t2) << 8) | ((t3) << 16) | ((t4) << 24))

#define HARDWARE_HAL_API_VERSION_MAJOR_MIN  1
#define HARDWARE_HAL_API_VERSION_MINOR_MIN  0
#define HARDWARE_HAL_API_VERSION            \
    ((HARDWARE_HAL_API_VERSION_MAJOR_MIN << 16) | HARDWARE_HAL_API_VERSION_MINOR_MIN)

struct hw_module_t;
struct hw_module_methods_t;
struct hw_device_t;

struct hw_module_methods_t {
    int (*open)(const struct hw_module_t *module, const char *name, struct hw_device_t **device);
};

struct hw_module_t {
    uint32_t tag;
    uint16_t module_api_version;
    uint16_t hal_api_version;
    const char *id;
    const char *name;
    const char *author;
    struct hw_module_methods_t *methods;
    void *dso;
    uint32_t reserved[32-7];
};

struct hw_device_t {
    uint32_t tag;
    uint32_t version;
    struct hw_module_t *module;
    int (*close)(struct hw_device_t *device);
};

#define HARDWARE_MODULE_API_VERSION(maj, min) (((maj) << 8) | (min))
#define HARDWARE_DEVICE_API_VERSION(maj, min) (((maj) << 8) | (min))

static inline int hw_get_module(const char *id, const struct hw_module_t **module)
{
    (void)id; (void)module;
    return -ENOSYS;
}

__END_DECLS
#endif /* ANDROID_HARDWARE_H */