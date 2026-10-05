/*
 * gralloc_qnx.c — QNX Screen-backed gralloc implementation for Android 11.
 *
 * Mirrors RIM's libgralloc_screen.so: allocates buffers via QNX Screen API,
 * shares via POSIX shm (fd passing), maps into client/driver address spaces.
 *
 * Build: QNX SDP ARM cross-toolchain, links against libscreen.so.1, libimg.so.1
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <pthread.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#ifdef SCREEN_API_STUB
/* Stub for sys/neutrino.h */
#define _NTO_SIDE_CHANNEL 0
#else
#include <sys/neutrino.h>
#include <screen/screen.h>
#endif
#include <hardware/gralloc.h>
#include <hardware/hardware.h>

#include "gralloc_qnx.h"

/* Private gralloc device structure (defined here since gralloc_qnx.h only forward declares) */
struct gralloc_qnx_device_t {
    struct gralloc_device_t base;

    /* QNX Screen context */
    struct qnx_screen_context *screen_ctx;

    /* Buffer tracking for garbage collection */
    struct gralloc_buffer_entry {
        buffer_handle_t handle;
        int           refcount;
        int           fd;              /* shared memory fd */
        void         *vaddr;           /* mapped virtual address */
        size_t        size;
        uint32_t      width, height;
        uint32_t      format;
        uint32_t      usage;
    } *buffers;
    size_t buffer_capacity;
    size_t buffer_count;

    pthread_mutex_t lock;
};

/* ------------------------------------------------------------------ */
/* Host stubs for QNX Screen API (when SCREEN_API_STUB is defined)    */
/* ------------------------------------------------------------------ */

#ifdef SCREEN_API_STUB

/* Minimal stub types */
typedef void *screen_context_t;
typedef void *screen_window_t;
typedef void *screen_buffer_t;
typedef void *screen_display_t;
typedef void *screen_pixmap_t;

#define SCREEN_APPLICATION_CONTEXT 0
#define SCREEN_FORMAT_RGBA8888 1
#define SCREEN_FORMAT_RGBX8888 2
#define SCREEN_FORMAT_RGB888 3
#define SCREEN_FORMAT_RGB565 4
#define SCREEN_FORMAT_BGRA8888 5
#define SCREEN_FORMAT_YV12 6
#define SCREEN_FORMAT_NV12 7
#define SCREEN_USAGE_READ 0x01
#define SCREEN_USAGE_WRITE 0x02
#define SCREEN_USAGE_OPENGL_ES1 0x04
#define SCREEN_USAGE_OPENGL_ES2 0x08
#define SCREEN_USAGE_OPENGL_ES3 0x10
#define SCREEN_USAGE_ROTATION 0x20
#define SCREEN_USAGE_2D_BLIT 0x40
#define SCREEN_USAGE_COMPOSITION 0x80
#define SCREEN_USAGE_PROTECTED 0x100
#define SCREEN_USAGE_CURSOR 0x200

#define SCREEN_PROPERTY_SIZE 1
#define SCREEN_PROPERTY_FORMAT 2
#define SCREEN_PROPERTY_USAGE 3
#define SCREEN_PROPERTY_STRIDE 4
#define SCREEN_PROPERTY_RENDER_BUFFERS 5
#define SCREEN_PROPERTY_FD 6

static int screen_create_context(screen_context_t *ctx, int type) { (void)ctx; (void)type; return 0; }
static int screen_destroy_context(screen_context_t ctx) { (void)ctx; return 0; }
static int screen_create_window(screen_window_t *win, screen_context_t ctx) { (void)win; (void)ctx; return 0; }
static int screen_destroy_window(screen_window_t win) { (void)win; return 0; }
static int screen_set_window_property_iv(screen_window_t win, int pname, const int *params) { (void)win; (void)pname; (void)params; return 0; }
static int screen_create_window_buffers(screen_window_t win, int nbufs) { (void)win; (void)nbufs; return 0; }
static int screen_get_window_property_pv(screen_window_t win, int pname, void **params) { (void)win; (void)pname; (void)params; return 0; }
static int screen_get_buffer_property_iv(screen_buffer_t buf, int pname, int *params) { (void)buf; (void)pname; (void)params; return 0; }

#endif /* SCREEN_API_STUB */

/* ------------------------------------------------------------------ */
/* QNX Screen context wrapper                                         */
/* ------------------------------------------------------------------ */

struct qnx_screen_context {
    screen_context_t ctx;
    int              initialized;
};

struct qnx_screen_context *
qnx_screen_context_create(void)
{
    struct qnx_screen_context *sctx = calloc(1, sizeof(*sctx));
    if (!sctx)
        return NULL;

    int rc = screen_create_context(&sctx->ctx, SCREEN_APPLICATION_CONTEXT);
    if (rc != 0) {
        free(sctx);
        return NULL;
    }
    sctx->initialized = 1;
    return sctx;
}

void
qnx_screen_context_destroy(struct qnx_screen_context *sctx)
{
    if (sctx && sctx->initialized) {
        screen_destroy_context(sctx->ctx);
        sctx->initialized = 0;
    }
    free(sctx);
}

/* Convert Android gralloc format to QNX Screen format */
int
android_format_to_screen(int format)
{
    switch (format) {
    case HAL_PIXEL_FORMAT_RGBA_8888: return SCREEN_FORMAT_RGBA8888;
    case HAL_PIXEL_FORMAT_RGBX_8888: return SCREEN_FORMAT_RGBX8888;
    case HAL_PIXEL_FORMAT_RGB_888:   return SCREEN_FORMAT_RGB888;
    case HAL_PIXEL_FORMAT_RGB_565:   return SCREEN_FORMAT_RGB565;
    case HAL_PIXEL_FORMAT_BGRA_8888: return SCREEN_FORMAT_BGRA8888;
    case HAL_PIXEL_FORMAT_YV12:      return SCREEN_FORMAT_YV12;
    case HAL_PIXEL_FORMAT_YCbCr_420_888: return SCREEN_FORMAT_NV12;
    default: return SCREEN_FORMAT_RGBA8888;
    }
}

/* Convert Android gralloc usage to QNX Screen usage */
int
android_usage_to_screen(int usage)
{
    int screen_usage = 0;
    if (usage & GRALLOC_USAGE_SW_READ_MASK)    screen_usage |= SCREEN_USAGE_READ;
    if (usage & GRALLOC_USAGE_SW_WRITE_MASK)   screen_usage |= SCREEN_USAGE_WRITE;
    if (usage & GRALLOC_USAGE_HW_TEXTURE)      screen_usage |= SCREEN_USAGE_OPENGL_ES1 | SCREEN_USAGE_OPENGL_ES2 | SCREEN_USAGE_OPENGL_ES3;
    if (usage & GRALLOC_USAGE_HW_RENDER)       screen_usage |= SCREEN_USAGE_ROTATION; /* close enough */
    if (usage & GRALLOC_USAGE_HW_2D)           screen_usage |= SCREEN_USAGE_2D_BLIT;
    if (usage & GRALLOC_USAGE_HW_COMPOSER)     screen_usage |= SCREEN_USAGE_COMPOSITION;
    if (usage & GRALLOC_USAGE_PROTECTED)       screen_usage |= SCREEN_USAGE_PROTECTED;
    if (usage & GRALLOC_USAGE_CURSOR)          screen_usage |= SCREEN_USAGE_CURSOR;
    return screen_usage ? screen_usage : SCREEN_USAGE_READ | SCREEN_USAGE_WRITE;
}

/* Allocate a buffer via QNX Screen */
int
qnx_screen_alloc_buffer(struct qnx_screen_context *sctx,
                        uint32_t w, uint32_t h, uint32_t format, uint32_t usage,
                        int *out_fd, void **out_vaddr, size_t *out_size, int *out_stride)
{
    if (!sctx || !sctx->initialized)
        return -EINVAL;

    screen_buffer_t screen_buf = NULL;
    int screen_format = android_format_to_screen(format);
    int screen_usage  = android_usage_to_screen(usage);

    /* Create a window to back the buffer (RIM used offscreen windows) */
    screen_window_t win = NULL;
    int rc = screen_create_window(&win, sctx->ctx);
    if (rc != 0)
        return -errno;

    /* Set window properties */
    int size[2] = { (int)w, (int)h };
    rc = screen_set_window_property_iv(win, SCREEN_PROPERTY_SIZE, size);
    if (rc != 0) goto fail;

    int fmt = screen_format;
    rc = screen_set_window_property_iv(win, SCREEN_PROPERTY_FORMAT, &fmt);
    if (rc != 0) goto fail;

    int usg = screen_usage;
    rc = screen_set_window_property_iv(win, SCREEN_PROPERTY_USAGE, &usg);
    if (rc != 0) goto fail;

    /* Create window buffers (this allocates the actual memory) */
    int nbufs = 1;
    rc = screen_create_window_buffers(win, nbufs);
    if (rc != 0) goto fail;

    /* Get the buffer handle */
    rc = screen_get_window_property_pv(win, SCREEN_PROPERTY_RENDER_BUFFERS, (void **)&screen_buf);
    if (rc != 0 || !screen_buf) {
        rc = -EINVAL;
        goto fail;
    }

    /* Query buffer properties */
    int stride = 0;
    rc = screen_get_buffer_property_iv(screen_buf, SCREEN_PROPERTY_STRIDE, &stride);
    if (rc != 0) goto fail;

    int buf_size = 0;
    rc = screen_get_buffer_property_iv(screen_buf, SCREEN_PROPERTY_SIZE, &buf_size);
    if (rc != 0) goto fail;

    /* Get the fd for sharing (SCREEN_PROPERTY_FD) */
    int fd = -1;
    rc = screen_get_buffer_property_iv(screen_buf, SCREEN_PROPERTY_FD, &fd);
    if (rc != 0 || fd < 0) {
        rc = -EINVAL;
        goto fail;
    }

    /* Map into our address space for CPU access */
    void *vaddr = mmap(NULL, buf_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (vaddr == MAP_FAILED) {
        rc = -errno;
        goto fail;
    }

    /* Lock physical pages (RIM used mem_offset64 + mlock for DMA) */
    off64_t phys_offset;
    if (mem_offset64(vaddr, 0, buf_size, &phys_offset, &fd) == 0) {
        mlock(vaddr, buf_size);
    }

    *out_fd     = fd;
    *out_vaddr  = vaddr;
    *out_size   = buf_size;
    *out_stride = stride;

    /* Note: we keep the window alive as long as the buffer exists.
     * In a real implementation, we'd store the window in the buffer handle. */
    (void)win; /* suppress unused warning for now */

    return 0;

fail:
    if (win) screen_destroy_window(win);
    return rc;
}

void
qnx_screen_free_buffer(struct qnx_screen_context *sctx, int fd, void *vaddr, size_t size)
{
    (void)sctx;
    if (vaddr && vaddr != MAP_FAILED) {
        munmap(vaddr, size);
    }
    if (fd >= 0) {
        close(fd);
    }
}

/* ------------------------------------------------------------------ */
/* Buffer handle definition                                           */
/* ------------------------------------------------------------------ */

struct gralloc_qnx_buffer {
    /* Must match private_handle_t layout for binder transport */
    int       fd;            /* shared memory fd */
    int       width;
    int       height;
    int       format;
    int       usage;
    int       stride;
    size_t    size;
    void     *vaddr;
    int       refcount;
    int       magic;         /* validation */
};

#define GRALLOC_QNX_MAGIC 0x47524C58 /* "GRLX" */

/* ------------------------------------------------------------------ */
/* gralloc device implementation                                      */
/* ------------------------------------------------------------------ */

int
gralloc_qnx_alloc(struct gralloc_device_t *dev, uint32_t w, uint32_t h, uint32_t format, uint32_t usage, buffer_handle_t *handle, int *stride)
{
    struct gralloc_qnx_device_t *qdev = (struct gralloc_qnx_device_t *)dev;
    int fd, ret_stride;
    void *vaddr;
    size_t size;

    int rc = qnx_screen_alloc_buffer(qdev->screen_ctx, w, h, format, usage, &fd, &vaddr, &size, &ret_stride);
    if (rc != 0)
        return rc;

    struct gralloc_qnx_buffer *buf = calloc(1, sizeof(*buf));
    if (!buf) {
        qnx_screen_free_buffer(qdev->screen_ctx, fd, vaddr, size);
        return -ENOMEM;
    }

    buf->magic     = GRALLOC_QNX_MAGIC;
    buf->fd        = fd;
    buf->width     = w;
    buf->height    = h;
    buf->format    = format;
    buf->usage     = usage;
    buf->stride    = ret_stride;
    buf->size      = size;
    buf->vaddr     = vaddr;
    buf->refcount  = 1;

    /* Track buffer for garbage collection */
    pthread_mutex_lock(&qdev->lock);
    if (qdev->buffer_count >= qdev->buffer_capacity) {
        size_t new_cap = qdev->buffer_capacity ? qdev->buffer_capacity * 2 : 16;
        struct gralloc_buffer_entry *new_bufs = realloc(qdev->buffers, new_cap * sizeof(*new_bufs));
        if (!new_bufs) {
            pthread_mutex_unlock(&qdev->lock);
            free(buf);
            qnx_screen_free_buffer(qdev->screen_ctx, fd, vaddr, size);
            return -ENOMEM;
        }
        qdev->buffers = new_bufs;
        qdev->buffer_capacity = new_cap;
    }
    qdev->buffers[qdev->buffer_count++] = (struct gralloc_buffer_entry){
        .handle = (buffer_handle_t)buf,
        .refcount = 1,
        .fd = fd,
        .vaddr = vaddr,
        .size = size,
        .width = w, .height = h, .format = format, .usage = usage
    };
    pthread_mutex_unlock(&qdev->lock);

    *handle = (buffer_handle_t)buf;
    if (stride) *stride = ret_stride;
    return 0;
}

int
gralloc_qnx_free(struct gralloc_device_t *dev, buffer_handle_t handle)
{
    struct gralloc_qnx_device_t *qdev = (struct gralloc_qnx_device_t *)dev;
    struct gralloc_qnx_buffer *buf = (struct gralloc_qnx_buffer *)handle;

    if (!buf || buf->magic != GRALLOC_QNX_MAGIC)
        return -EINVAL;

    pthread_mutex_lock(&qdev->lock);
    /* Find and remove from tracking */
    for (size_t i = 0; i < qdev->buffer_count; i++) {
        if (qdev->buffers[i].handle == handle) {
            qdev->buffers[i] = qdev->buffers[--qdev->buffer_count];
            break;
        }
    }
    pthread_mutex_unlock(&qdev->lock);

    qnx_screen_free_buffer(qdev->screen_ctx, buf->fd, buf->vaddr, buf->size);
    buf->magic = 0;
    free(buf);
    return 0;
}

int
gralloc_qnx_register_buffer(struct gralloc_device_t *dev, buffer_handle_t handle)
{
    struct gralloc_qnx_buffer *buf = (struct gralloc_qnx_buffer *)handle;
    if (!buf || buf->magic != GRALLOC_QNX_MAGIC)
        return -EINVAL;
    __sync_fetch_and_add(&buf->refcount, 1);
    return 0;
}

int
gralloc_qnx_unregister_buffer(struct gralloc_device_t *dev, buffer_handle_t handle)
{
    struct gralloc_qnx_buffer *buf = (struct gralloc_qnx_buffer *)handle;
    if (!buf || buf->magic != GRALLOC_QNX_MAGIC)
        return -EINVAL;
    if (__sync_sub_and_fetch(&buf->refcount, 1) == 0) {
        /* Last reference; free it */
        return gralloc_qnx_free(dev, handle);
    }
    return 0;
}

int
gralloc_qnx_lock(struct gralloc_device_t *dev, buffer_handle_t handle, uint32_t usage, int l, int t, int w, int h, void **vaddr)
{
    (void)usage; (void)l; (void)t; (void)w; (void)h;
    struct gralloc_qnx_buffer *buf = (struct gralloc_qnx_buffer *)handle;
    if (!buf || buf->magic != GRALLOC_QNX_MAGIC)
        return -EINVAL;
    *vaddr = buf->vaddr;
    return 0;
}

int
gralloc_qnx_unlock(struct gralloc_device_t *dev, buffer_handle_t handle)
{
    (void)dev; (void)handle;
    /* No-op: buffer stays mapped */
    return 0;
}

int
gralloc_qnx_lock_ycbcr(struct gralloc_device_t *dev, buffer_handle_t handle, uint32_t usage, int l, int t, int w, int h, struct android_ycbcr *ycbcr)
{
    struct gralloc_qnx_buffer *buf = (struct gralloc_qnx_buffer *)handle;
    if (!buf || buf->magic != GRALLOC_QNX_MAGIC)
        return -EINVAL;

    /* For YUV formats, we need to set up the planes */
    if (buf->format == HAL_PIXEL_FORMAT_YV12 || buf->format == HAL_PIXEL_FORMAT_YCbCr_420_888) {
        ycbcr->y = buf->vaddr;
        ycbcr->ystride = buf->stride;
        ycbcr->cb = (char *)buf->vaddr + buf->stride * buf->height;
        ycbcr->cr = (char *)ycbcr->cb + (buf->stride/2) * (buf->height/2);
        ycbcr->cstride = buf->stride / 2;
        ycbcr->chroma_step = 1;
    } else {
        ycbcr->y = buf->vaddr;
        ycbcr->ystride = buf->stride;
        ycbcr->cb = ycbcr->cr = NULL;
        ycbcr->cstride = 0;
    }
    return 0;
}

int
gralloc_qnx_perform(struct gralloc_device_t *dev, int op, ...)
{
    (void)dev; (void)op;
    return -ENOSYS;
}

/* ------------------------------------------------------------------ */
/* Module open/close                                                  */
/* ------------------------------------------------------------------ */

int
gralloc_qnx_open(const struct hw_module_t *module, const char *name, struct hw_device_t **device)
{
    if (strcmp(name, GRALLOC_HARDWARE_GPU0) != 0)
        return -EINVAL;

    struct gralloc_qnx_device_t *qdev = calloc(1, sizeof(*qdev));
    if (!qdev)
        return -ENOMEM;

    qdev->screen_ctx = qnx_screen_context_create();
    if (!qdev->screen_ctx) {
        free(qdev);
        return -ENODEV;
    }

    pthread_mutex_init(&qdev->lock, NULL);

    qdev->base.common.tag     = HARDWARE_DEVICE_TAG;
    qdev->base.common.version = GRALLOC_DEVICE_API_VERSION_1_0;
    qdev->base.common.module  = (struct hw_module_t *)module;
    qdev->base.common.close   = gralloc_qnx_close;

    qdev->base.alloc          = gralloc_qnx_alloc;
    qdev->base.free           = gralloc_qnx_free;
    qdev->base.register_buffer   = gralloc_qnx_register_buffer;
    qdev->base.unregister_buffer = gralloc_qnx_unregister_buffer;
    qdev->base.lock           = gralloc_qnx_lock;
    qdev->base.unlock         = gralloc_qnx_unlock;
    qdev->base.lock_ycbcr     = gralloc_qnx_lock_ycbcr;
    qdev->base.perform        = gralloc_qnx_perform;

    *device = &qdev->base.common;
    return 0;
}

int
gralloc_qnx_close(struct hw_device_t *device)
{
    struct gralloc_qnx_device_t *qdev = (struct gralloc_qnx_device_t *)device;
    if (!qdev) return 0;

    /* Free all tracked buffers */
    for (size_t i = 0; i < qdev->buffer_count; i++) {
        struct gralloc_qnx_buffer *buf = (struct gralloc_qnx_buffer *)qdev->buffers[i].handle;
        if (buf) {
            qnx_screen_free_buffer(qdev->screen_ctx, buf->fd, buf->vaddr, buf->size);
            free(buf);
        }
    }
    free(qdev->buffers);

    qnx_screen_context_destroy(qdev->screen_ctx);
    pthread_mutex_destroy(&qdev->lock);
    free(qdev);
    return 0;
}

/* ------------------------------------------------------------------ */
/* Module definition                                                  */
/* ------------------------------------------------------------------ */

static struct hw_module_methods_t gralloc_qnx_module_methods = {
    .open = gralloc_qnx_open,
};

struct hw_module_t HAL_MODULE_INFO_SYM = {
    .tag = HARDWARE_MODULE_TAG,
    .module_api_version = GRALLOC_MODULE_API_VERSION_1_0,
    .hal_api_version = HARDWARE_HAL_API_VERSION,
    .id = GRALLOC_HARDWARE_MODULE_ID,
    .name = "QNX Screen Gralloc",
    .author = "BlackBerry Research",
    .methods = &gralloc_qnx_module_methods,
    .dso = NULL,
    .reserved = {0},
};