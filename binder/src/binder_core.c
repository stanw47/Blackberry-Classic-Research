/*
 * binder_core.c — portable Android 11 binder driver engine.
 *
 * Faithful port of the android11-5.4 kernel binder driver's transaction flow
 * to a self-contained userland engine. The semantics below match the kernel
 * (verified against graft/a11-kernel/binder.c):
 *
 *   * BC_TRANSACTION / BC_REPLY are plain commands: the trd carries the
 *     payload as *user pointers* (tr.data.ptr.buffer / tr.data.ptr.offsets),
 *     read via the binder_mem accessor. A11 libbinder never uses the _SG
 *     variants (writeTransactionData puts only cmd+trd in the write buffer).
 *
 *   * A sync sender enqueues its txn with t->from = itself and parks in read;
 *     the RECEIVER of a BR_TRANSACTION sets its own thread->transaction_stack
 *     = t. On BC_REPLY the kernel resolves in_reply_to = replying thread's
 *     stack, routes the reply to t->from (the original waiting sender), pops
 *     the sender's stack, and delivers BR_TRANSACTION_COMPLETE to the sender
 *     just before BR_REPLY.
 *
 *   * A thread only drains proc work when it is "available": no pending reply
 *     (transaction_stack == NULL) and its own thread list empty.
 *
 *   * The driver hands the client a real binder_uintptr_t for the payload
 *     buffer (in QNX: an address in the client's shared mapping; in the host
 *     simulator: the malloc'd address). BC_FREE_BUFFER returns that same
 *     pointer. This "allocator" is pluggable per binder_ctx.
 *
 *   * BR_SPAWN_LOOPER is emitted when a returning read finds the proc with no
 *     pending spawn, threads started fewer than max_threads, and no thread
 *     blocked waiting for proc work; the spawned thread registers with
 *     BC_REGISTER_LOOPER (decrements the outstanding request).
 *
 * Returns: 0 or positive on success, negative errno on error. The ioctl
 * negative path mirrors -EPROTO/-EINVAL/etc. that libbinder maps through
 * errno as BR_FAILED_REPLY / BAD_THING.
 */

#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stddef.h>
#include <stdbool.h>
#include <pthread.h>

#include "binder_core.h"
#include "binder_a11.h"

#define TRANS_OF(w) \
    ((struct binder_transaction *)((char *)(w) - \
     offsetof(struct binder_transaction, work)))

static int binder_ioctl_locked(struct binder_ctx *ctx, struct binder_proc *proc,
                               struct binder_thread *thread, unsigned int cmd,
                               const void *arg, const struct binder_mem *mem,
                               int nonblock);
static void proc_close_locked(struct binder_ctx *ctx, struct binder_proc *proc);

/* ---------------- internal data structures ---------------- */

enum {
    WORK_TRANSACTION,
    WORK_TRANSACTION_COMPLETE,
    WORK_DEAD_BINDER,
    WORK_SPAWN_LOOPER,     /* queued to a thread; emits BR_SPAWN_LOOPER */
};

struct binder_work {
    struct binder_work *next;
    int type;
    uint64_t cookie;       /* death notification cookie / node id */
};

enum { LOOPER_NONE = 0, LOOPER_REGISTERED = 1, LOOPER_ENTERED = 2 };

struct binder_ref_death {
    struct binder_ref_death *next;
    uint64_t cookie;
    bool armed;            /* notification requested */
};

struct binder_ref {
    struct binder_ref *next;
    struct binder_proc *proc;   /* proc holding this handle */
    struct binder_node *node;
    uint32_t handle;
    int strong;             /* refcount this handle's holder contributed */
    int weak;
    bool dead;              /* the node's owner is gone */
    struct binder_ref_death *death;      /* death notification registrations */
};

struct binder_node {
    struct binder_node *next;
    struct binder_proc *proc;      /* owning proc */
    binder_uintptr_t ptr;          /* the object pointer, in owner's space */
    binder_uintptr_t cookie;
    int has_strong_ref;            /* global strong ref count on the node */
    int has_weak_ref;              /* global weak ref count on the node */
};

/* A live payload buffer, owned by a proc until BC_FREE_BUFFER. */
struct binder_buf {
    struct binder_buf *next;
    binder_uintptr_t user;         /* address handed to the client */
    uint8_t *driver;               /* engine-visible bytes */
    size_t size;
};

struct binder_transaction {
    struct binder_work work;       /* WORK_TRANSACTION */
    struct binder_proc *from_proc;
    struct binder_thread *from;        /* sync: original waiting sender */
    struct binder_proc *to_proc;
    struct binder_node *target_node;
    struct binder_transaction *from_parent;  /* sender's prior stack */
    struct binder_transaction *to_parent;    /* reader's prior stack */
    uint32_t code;
    uint32_t flags;
    binder_pid_t sender_pid;
    binder_uid_t sender_euid;
    uint8_t *driver_buffer;        /* engine bytes (data + offsets) */
    binder_uintptr_t user_buffer;  /* value handed to client */
    size_t data_size;
    size_t offsets_size;
    bool is_reply;
};

struct binder_thread {
    struct binder_thread *next;
    struct binder_proc *proc;
    int64_t tid;
    int looper;                 /* LOOPER_* */
    struct binder_work *work_head;
    struct binder_work *work_tail;
    struct binder_transaction *transaction_stack;
    bool waiting;
    pthread_cond_t wait_cond;
    bool dead;
};

struct binder_proc {
    struct binder_proc *next;
    struct binder_ctx *ctx;
    int32_t pid;
    int32_t uid;
    bool is_context_manager;
    struct binder_thread *threads;
    struct binder_node *nodes;
    struct binder_ref *refs;
    struct binder_buf *buffers;
    struct binder_work *todo;      /* proc-wide work queue */
    struct binder_work *todo_tail;
    int max_threads;
    int requested_threads;         /* outstanding BR_SPAWN_LOOPER */
    int requested_threads_started; /* threads that registered so far */
    bool frozen;
    bool dead;
};

/* ---------------- logging ---------------- */

#define blog(ctx, ...) do { if ((ctx) && (ctx)->debug) \
        fprintf(stderr, "[binder] " __VA_ARGS__); } while (0)

/* ---------------- defaults (host allocator) ---------------- */

static int
host_alloc(void *opaque, struct binder_proc *for_proc, size_t size,
           void **driver_ptr, binder_uintptr_t *user_ptr)
{
    (void)opaque;
    (void)for_proc;
    uint8_t *p = malloc(size ? size : 1);
    if (!p) return -ENOMEM;
    *driver_ptr = p;
    *user_ptr = (binder_uintptr_t)p;
    return 0;
}

static void
host_free(void *opaque, struct binder_proc *of_proc, binder_uintptr_t user)
{
    (void)opaque;
    (void)of_proc;
    free((void *)(uintptr_t)user);
}

/* ---------------- list helpers ---------------- */

static void
queue_work_list(struct binder_work **head, struct binder_work **tail,
                struct binder_work *w)
{
    if (*tail) (*tail)->next = w;
    else *head = w;
    *tail = w;
}

static struct binder_work *
dequeue_work_list(struct binder_work **head, struct binder_work **tail)
{
    struct binder_work *w = *head;
    if (w) {
        *head = w->next;
        if (!*head) *tail = NULL;
    }
    return w;
}

static struct binder_work *
work_new(int type, uint64_t cookie)
{
    struct binder_work *w = calloc(1, sizeof(*w));
    if (w) { w->type = type; w->cookie = cookie; }
    return w;
}

static void
thread_enqueue_work(struct binder_thread *t, struct binder_work *w)
{
    struct binder_proc *p = t->proc;
    queue_work_list(&t->work_head, &t->work_tail, w);
    if (t->waiting) pthread_cond_signal(&t->wait_cond);
    (void)p;
}

static void
proc_enqueue_todo(struct binder_proc *p, struct binder_work *w)
{
    queue_work_list(&p->todo, &p->todo_tail, w);
}

/* ---------------- lookups ---------------- */

static struct binder_thread *
thread_lookup(struct binder_proc *p, int64_t tid)
{
    for (struct binder_thread *t = p->threads; t; t = t->next)
        if (t->tid == tid) return t;
    return NULL;
}

static struct binder_node *
node_lookup(struct binder_proc *p, binder_uintptr_t ptr)
{
    for (struct binder_node *n = p->nodes; n; n = n->next)
        if (n->ptr == ptr) return n;
    return NULL;
}

static struct binder_ref *
ref_lookup_handle(struct binder_proc *p, uint32_t handle)
{
    for (struct binder_ref *r = p->refs; r; r = r->next)
        if (r->handle == handle) return r;
    return NULL;
}

static void
proc_wakeup(struct binder_proc *p)
{
    for (struct binder_thread *t = p->threads; t; t = t->next)
        if (t->waiting) {
            pthread_cond_signal(&t->wait_cond);
            return;
        }
}

/* Context-wide count of threads parked on a read (for BR_SPAWN_LOOPER). */
static int
ctx_waiting_count(struct binder_ctx *ctx)
{
    int n = 0;
    for (struct binder_proc *p = ctx->procs; p; p = p->next)
        for (struct binder_thread *t = p->threads; t; t = t->next)
            if (t->waiting) n++;
    return n;
}

/* ---------------- public lifecycle ---------------- */

struct binder_ctx *
binder_ctx_alloc(size_t max_txn_size)
{
    struct binder_ctx *c = calloc(1, sizeof(*c));
    if (!c) return NULL;
    c->max_txn_size = max_txn_size ? max_txn_size : (1u << 20);
    c->alloc_buffer = host_alloc;
    c->free_buffer = host_free;
    pthread_mutex_init(&c->lock, NULL);
    c->debug = !!getenv("BINDER_DEBUG");
    return c;
}

void
binder_ctx_free(struct binder_ctx *ctx)
{
    if (!ctx) return;
    pthread_mutex_lock(&ctx->lock);
    struct binder_proc *p = ctx->procs;
    while (p) {
        struct binder_proc *n = p->next;
        proc_close_locked(ctx, p);
        p = n;
    }
    pthread_mutex_unlock(&ctx->lock);
    pthread_mutex_destroy(&ctx->lock);
    free(ctx);
}

struct binder_proc *
binder_proc_open(struct binder_ctx *ctx, int32_t pid, int32_t uid)
{
    struct binder_proc *p = calloc(1, sizeof(*p));
    if (!p) return NULL;
    p->ctx = ctx;
    p->pid = pid;
    p->uid = uid;
    p->max_threads = 16;   /* kernel default BINDER_DEFAULT_MAX_THREADS */
    p->next = ctx->procs;
    ctx->procs = p;
    return p;
}

/* Find/create a thread; called when a client opens a new thread's context. */
struct binder_thread *
binder_thread_get(struct binder_proc *proc, int64_t tid)
{
    struct binder_thread *t = thread_lookup(proc, tid);
    if (t) return t;
    t = calloc(1, sizeof(*t));
    if (!t) return NULL;
    t->proc = proc;
    t->tid = tid;
    pthread_cond_init(&t->wait_cond, NULL);
    t->next = proc->threads;
    proc->threads = t;
    return t;
}

/* ---------------- node/ref management ---------------- */

static struct binder_node *
node_new(struct binder_proc *owner, binder_uintptr_t ptr,
         binder_uintptr_t cookie)
{
    struct binder_node *n = node_lookup(owner, ptr);
    if (n) return n;
    n = calloc(1, sizeof(*n));
    if (!n) return NULL;
    n->proc = owner;
    n->ptr = ptr;
    n->cookie = cookie;
    n->next = owner->nodes;
    owner->nodes = n;
    return n;
}

/* Establish (`ref`) in `proc` to `node`; optional strong/weak increment.
 * Returns 0 (ref found/created, handle filled) or -ENOMEM. */
static int
inc_ref_for_node(struct binder_proc *proc, struct binder_node *node,
                 bool strong, struct binder_ref **out_ref,
                 uint32_t *out_handle)
{
    struct binder_ref *ref = NULL;
    for (struct binder_ref *r = proc->refs; r; r = r->next)
        if (r->node == node) { ref = r; break; }
    if (!ref) {
        ref = calloc(1, sizeof(*ref));
        if (!ref) return -ENOMEM;
        uint32_t h = 1;
        for (;;) {
            bool taken = false;
            for (struct binder_ref *r = proc->refs; r; r = r->next)
                if (r->handle == h) { taken = true; break; }
            if (!taken) break;
            h++;
        }
        ref->proc = proc;
        ref->node = node;
        ref->handle = h;
        ref->next = proc->refs;
        proc->refs = ref;
    }
    if (strong) {
        ref->strong++;
        node->has_strong_ref++;
    } else {
        ref->weak++;
        node->has_weak_ref++;
    }
    if (out_ref) *out_ref = ref;
    if (out_handle) *out_handle = ref->handle;
    return 0;
}

/* ---------------- buffer management ---------------- */

static int
buffer_alloc(struct binder_ctx *ctx, struct binder_proc *for_proc,
             size_t data_size, size_t offsets_size,
             uint8_t **driver, binder_uintptr_t *user,
             struct binder_buf **slot_out)
{
    if (data_size + offsets_size > ctx->max_txn_size)
        return -EINVAL;
    void *dv = NULL;
    int r = ctx->alloc_buffer(ctx->alloc_opaque, for_proc,
                              data_size + offsets_size, &dv, user);
    if (r < 0) return r;
    *driver = (uint8_t *)dv;

    struct binder_buf *b = calloc(1, sizeof(*b));
    if (!b) {
        ctx->free_buffer(ctx->alloc_opaque, for_proc, *user);
        return -ENOMEM;
    }
    b->user = *user;
    b->driver = *driver;
    b->size  = data_size + offsets_size;
    b->next = for_proc->buffers;
    for_proc->buffers = b;
    if (slot_out) *slot_out = b;
    return 0;
}

static void
buffer_free(struct binder_ctx *ctx, struct binder_proc *proc,
            binder_uintptr_t user)
{
    struct binder_buf **pp = &proc->buffers;
    while (*pp) {
        struct binder_buf *b = *pp;
        if (b->user == user) {
            *pp = b->next;
            ctx->free_buffer(ctx->alloc_opaque, proc, user);
            free(b);
            return;
        }
        pp = &b->next;
    }
}

/* ---------------- object fixup ---------------- */

static int
fixup_objects(struct binder_ctx *ctx,
              struct binder_proc *from_proc,
              struct binder_proc *to_proc,
              uint8_t *buf, size_t data_size, size_t offsets_size)
{
    (void)ctx;
    size_t n = offsets_size / sizeof(uint64_t);
    for (size_t i = 0; i < n; i++) {
        uint64_t off;
        memcpy(&off, buf + data_size + i * 8, 8);
        if (off + sizeof(struct binder_object_header) > data_size)
            continue;

        struct binder_object_header hdr;
        memcpy(&hdr, buf + off, sizeof(hdr));

        switch (hdr.type) {
        case BINDER_TYPE_BINDER:
        case BINDER_TYPE_WEAK_BINDER: {
            /* sender passes a LOCAL object: node in sender, ref in target */
            bool strong = (hdr.type == BINDER_TYPE_BINDER);
            struct flat_binder_object fb;
            memcpy(&fb, buf + off, sizeof(fb));
            struct binder_node *n = node_new(from_proc, fb.binder, fb.cookie);
            if (!n) return -ENOMEM;
            uint32_t handle;
            int r = inc_ref_for_node(to_proc, n, strong, NULL, &handle);
            if (r < 0) return r;
            struct flat_binder_object nb;
            memset(&nb, 0, sizeof(nb));
            nb.hdr.type = strong ? BINDER_TYPE_HANDLE : BINDER_TYPE_WEAK_HANDLE;
            nb.flags = fb.flags;
            nb.handle = handle;
            memcpy(buf + off, &nb, sizeof(nb));
            break;
        }
        case BINDER_TYPE_HANDLE:
        case BINDER_TYPE_WEAK_HANDLE: {
            /* sender passes a handle it holds; translate for the target */
            bool strong = (hdr.type == BINDER_TYPE_HANDLE);
            struct flat_binder_object fb;
            memcpy(&fb, buf + off, sizeof(fb));
            struct binder_ref *ref = ref_lookup_handle(from_proc, fb.handle);
            if (!ref || !ref->node) return -EINVAL;
            struct binder_node *node = ref->node;
            struct flat_binder_object nb;
            memset(&nb, 0, sizeof(nb));
            if (node->proc == to_proc) {
                /* target owns the object: send back ptr+cookie */
                nb.hdr.type = strong ? BINDER_TYPE_BINDER : BINDER_TYPE_WEAK_BINDER;
                nb.flags = fb.flags;
                nb.binder = node->ptr;
                nb.cookie = node->cookie;
            } else {
                uint32_t handle;
                int r = inc_ref_for_node(to_proc, node, strong, NULL, &handle);
                if (r < 0) return r;
                nb.hdr.type = hdr.type;
                nb.flags = fb.flags;
                nb.handle = handle;
            }
            memcpy(buf + off, &nb, sizeof(nb));
            break;
        }
        case BINDER_TYPE_FD:
        case BINDER_TYPE_FDA:
        case BINDER_TYPE_PTR:
        default:
            /* QNX target shares the driver address space conceptually;
             * fd/paren spans are handled by the glue. No-op for now. */
            break;
        }
    }
    return 0;
}

/* ---------------- transactions ---------------- */

static int
binder_transaction(struct binder_ctx *ctx,
                   struct binder_proc *from_proc,
                   struct binder_thread *from_thread,
                   uint32_t target_handle,
                   uint32_t code, uint32_t flags,
                   const uint8_t *data, size_t data_size,
                   const uint8_t *offsets, size_t offsets_size,
                   int is_reply,
                   const struct binder_mem *mem)
{
    struct binder_proc *to_proc;
    struct binder_node *target_node = NULL;
    struct binder_thread *target_thread = NULL;
    struct binder_transaction *in_reply_to = NULL;

    if (is_reply) {
        in_reply_to = from_thread->transaction_stack;
        if (!in_reply_to) {
            blog(ctx, "%d tx: BC_REPLY with no pending txn\n", from_proc->pid);
            return -EPROTO;
        }
        /* the reply returns to the original waiting sender */
        target_thread = in_reply_to->from;
        if (!target_thread) return -EPROTO;
        to_proc = target_thread->proc;
    } else if (target_handle == 0) {
        to_proc = ctx->ctx_mgr;
        target_node = ctx->ctx_mgr_node;
        if (!to_proc || !target_node) return -EINVAL;
    } else {
        struct binder_ref *ref = ref_lookup_handle(from_proc, target_handle);
        if (!ref || !ref->node) return -EINVAL;
        target_node = ref->node;
        to_proc = ref->node->proc;
    }

    if (!to_proc) return -EINVAL;

    /* The target must be able to dereference the payload buffer. For a
     * reply the bytes live in a buffer owned by the RECEIVER (the original
     * sender) — kernel binder_proc_transaction semantics. */
    uint8_t *dbuf = NULL;
    binder_uintptr_t ubuf = 0;
    int r = buffer_alloc(ctx, to_proc, data_size, offsets_size, &dbuf, &ubuf, NULL);
    if (r < 0) return r;

    if (data_size)
        memcpy(dbuf, data, data_size);
    if (offsets_size)
        memcpy(dbuf + data_size, offsets, offsets_size);

    r = fixup_objects(ctx, from_proc, to_proc, dbuf, data_size, offsets_size);
    if (r < 0) {
        ctx->free_buffer(ctx->alloc_opaque, to_proc, ubuf);
        buffer_free(ctx, to_proc, ubuf);
        return r;
    }

    struct binder_transaction *t = calloc(1, sizeof(*t));
    if (!t) {
        ctx->free_buffer(ctx->alloc_opaque, to_proc, ubuf);
        buffer_free(ctx, to_proc, ubuf);
        return -ENOMEM;
    }

    t->work.type = WORK_TRANSACTION;
    t->from_proc = from_proc;
    t->from = is_reply ? in_reply_to->from : from_thread;
    t->to_proc = to_proc;
    t->target_node = target_node;
    t->code = code;
    t->flags = flags;
    t->sender_pid = from_proc->pid;
    t->sender_euid = from_proc->uid;
    t->driver_buffer = dbuf;
    t->user_buffer = ubuf;
    t->data_size = data_size;
    t->offsets_size = offsets_size;
    t->is_reply = is_reply;

    if (is_reply) {
        /* The replying thread gets its completed txn popped; the ORIGINAL
         * waiting sender (t->from) has its transaction_stack popped too
         * (kernel binder_pop_transaction_ilocked on the target thread). */
        from_thread->transaction_stack = in_reply_to->to_parent;    /* replier */
        target_thread->transaction_stack = in_reply_to->from_parent; /* sender */

        /* deferred BR_TRANSACTION_COMPLETE first, then the reply */
        struct binder_work *tc = work_new(WORK_TRANSACTION_COMPLETE, 0);
        if (tc) thread_enqueue_work(target_thread, tc);
        thread_enqueue_work(target_thread, &t->work);
        blog(ctx, "%d tx: reply r%llu -> %d thr %lld\n",
             from_proc->pid, (unsigned long long)ubuf,
             to_proc->pid, (long long)target_thread->tid);
        free(in_reply_to);
    } else if (flags & TF_ONE_WAY) {
        /* immediate BR_TRANSACTION_COMPLETE to the sender */
        struct binder_work *tc = work_new(WORK_TRANSACTION_COMPLETE, 0);
        if (tc) thread_enqueue_work(from_thread, tc);
        proc_enqueue_todo(to_proc, &t->work);
        proc_wakeup(to_proc);
        blog(ctx, "%d tx: oneway t%llu -> %d\n",
             from_proc->pid, (unsigned long long)ubuf, to_proc->pid);
    } else {
        /* sync send: park the sender, defer the complete */
        t->from_parent = from_thread->transaction_stack;
        from_thread->transaction_stack = t;
        proc_enqueue_todo(to_proc, &t->work);
        proc_wakeup(to_proc);
        blog(ctx, "%d tx: t%llu -> %d thr %lld (sync)\n",
             from_proc->pid, (unsigned long long)ubuf, to_proc->pid,
             (long long)from_thread->tid);
    }
    (void)mem;
    return 0;
}

/* ---------------- BR emission ---------------- */

static int
write_br(struct binder_ctx *ctx, const struct binder_mem *mem,
         binder_uintptr_t read_buffer, size_t read_size, size_t *consumed,
         uint32_t cmd, const void *payload, size_t payload_size)
{
    (void)ctx;
    if (*consumed + 4 + payload_size > read_size)
        return -EAGAIN;
    int r = mem->write(mem->opaque, read_buffer + *consumed, &cmd, 4);
    if (r) return r;
    *consumed += 4;
    if (payload_size) {
        r = mem->write(mem->opaque, read_buffer + *consumed, payload,
                       payload_size);
        if (r) return r;
        *consumed += payload_size;
    }
    return 0;
}

/* ---------------- read loop ---------------- */

static int
binder_thread_read(struct binder_ctx *ctx, struct binder_thread *thread,
                   const struct binder_mem *mem,
                   binder_uintptr_t read_buffer, size_t read_size,
                   size_t *consumed, int nonblock)
{
    struct binder_proc *proc = thread->proc;
    size_t c = *consumed;
    int delivered = 0;

    /* Kernel writes BR_NOOP at the head of a fresh read. */
    if (c == 0) {
        uint32_t noop = BR_NOOP;
        int r = mem->write(mem->opaque, read_buffer, &noop, 4);
        if (r) return r;
        c += 4;
    }

    for (;;) {
        struct binder_work *w;
        bool avail = (thread->transaction_stack == NULL);

        if (thread->work_head) {
            w = dequeue_work_list(&thread->work_head, &thread->work_tail);
        } else if (avail && proc->todo) {
            w = dequeue_work_list(&proc->todo, &proc->todo_tail);
        } else if (nonblock) {
            *consumed = c;
            return (delivered || c > 4) ? 0 : -EAGAIN;
        } else {
            if (delivered || c > 4) {
                /* We already put commands in the buffer this call; return
                 * them and let libbinder re-enter the driver. */
                break;
            }
            /* park. Only proc-work is meaningful: a thread with a pending
             * reply must wait only for its own work (its wait_cond is
             * signalled by the reply path). */
            thread->waiting = true;
            pthread_cond_wait(&thread->wait_cond, &ctx->lock);
            thread->waiting = false;
            continue;
        }

        if (!w) break;

        switch (w->type) {
        case WORK_TRANSACTION: {
            /* equallivent condition for direct BR_TRANSACTION delivery */
            struct binder_transaction *t = TRANS_OF(w);
            struct binder_transaction_data trd;
            memset(&trd, 0, sizeof(trd));

            if (t->is_reply) {
                trd.cookie = 0;
                trd.target.ptr = 0;
                trd.target.handle = 0;
            } else {
                trd.target.ptr = t->target_node ? t->target_node->ptr : 0;
                trd.cookie = t->target_node ? t->target_node->cookie : 0;
            }
            trd.code = t->code;
            trd.flags = t->flags;
            trd.sender_pid = t->sender_pid;
            trd.sender_euid = t->sender_euid;
            trd.data_size = t->data_size;
            trd.offsets_size = t->offsets_size;
            trd.data.ptr.buffer = t->user_buffer;
            trd.data.ptr.offsets = t->user_buffer + t->data_size;

            uint32_t cmd = t->is_reply ? BR_REPLY : BR_TRANSACTION;
            int r = write_br(ctx, mem, read_buffer, read_size, &c,
                             cmd, &trd, sizeof(trd));
            if (r == -EAGAIN) {
                /* requeue at front; caller re-reads */
                t->work.next = NULL;
                if (thread->work_head) {
                    t->work.next = thread->work_head;
                    thread->work_head = &t->work;
                } else {
                    thread->work_head = thread->work_tail = &t->work;
                }
                break;
            }
            if (r < 0) { free(t); return r; }

            int was_reply = t->is_reply;
            uint32_t tcode = t->code;
            size_t tdsize = t->data_size;

            if (!was_reply && !(t->flags & TF_ONE_WAY)) {
                t->to_parent = thread->transaction_stack;
                thread->transaction_stack = t;
            } else {
                free(t);   /* buffer persists; tracked on to_proc */
            }
            delivered = 1;
            blog(ctx, "%d thr %lld <- %s code=%u size=%zu\n",
                 proc->pid, (long long)thread->tid,
                 was_reply ? "BR_REPLY" : "BR_TRANSACTION",
                 tcode, tdsize);
            break;
        }
        case WORK_TRANSACTION_COMPLETE: {
            int r = write_br(ctx, mem, read_buffer, read_size, &c,
                             BR_TRANSACTION_COMPLETE, NULL, 0);
            if (r < 0) return r;
            free(w);
            delivered = 1;
            break;
        }
        case WORK_DEAD_BINDER: {
            uint64_t cookie = w->cookie;
            int r = write_br(ctx, mem, read_buffer, read_size, &c,
                             BR_DEAD_BINDER, &cookie, 8);
            if (r < 0) return r;
            free(w);
            delivered = 1;
            break;
        }
        case WORK_SPAWN_LOOPER: {
            int r = write_br(ctx, mem, read_buffer, read_size, &c,
                             BR_SPAWN_LOOPER, NULL, 0);
            if (r < 0) return r;
            free(w);
            delivered = 1;
            break;
        }
        default:
            free(w);
            break;
        }
    }

    /* Post-read check: ask for a new thread only if no spawn is pending, the
     * started pool is below the cap, and nobody is already waiting for more
     * proc work (so this thread becoming busy would strand work). */
    if (proc->requested_threads == 0 &&
        proc->requested_threads_started < proc->max_threads &&
        (thread->looper & (LOOPER_REGISTERED | LOOPER_ENTERED)) &&
        ctx_waiting_count(ctx) == 0 && delivered) {
        uint32_t spawn = BR_SPAWN_LOOPER;
        int r = mem->write(mem->opaque, read_buffer, &spawn, 4);
        if (r == 0 && c >= 4) {
            /* overwrite the BR_NOOP we wrote at offset 0 (kernel quirk) */
            proc->requested_threads++;
            blog(ctx, "%d: BR_SPAWN_LOOPER\n", proc->pid);
        }
    }

    *consumed = c;
    return 0;
}

/* ---------------- ioctl dispatch ---------------- */

static int
ioctl_write_read(struct binder_ctx *ctx, struct binder_proc *proc,
                 struct binder_thread *thread, const struct binder_mem *mem,
                 void *arg)
{
    struct binder_write_read *bwr = arg;
    if (bwr->write_size > 0) {
        size_t sz = bwr->write_size;
        if (sz < 4) return -EINVAL;
        size_t cap = sz;

        uint8_t *wbuf = malloc(cap ? cap : 1);
        if (!wbuf) return -ENOMEM;
        int r = mem->read(mem->opaque, bwr->write_buffer, wbuf, sz);
        if (r) { free(wbuf); return r; }

        size_t p = 0;
        while (p + 4 <= sz) {
            uint32_t cmd;
            memcpy(&cmd, wbuf + p, 4);
            p += 4;

            switch (cmd) {
            case BC_TRANSACTION:
            case BC_REPLY: {
                struct binder_transaction_data td;
                if (p + sizeof(td) > sz) { free(wbuf); return -EPROTO; }
                memcpy(&td, wbuf + p, sizeof(td));
                p += sizeof(td);

                /* payload is referenced by USER pointers (A11 libbinder) */
                size_t dsz = td.data_size;
                size_t osz = td.offsets_size;
                if (dsz + osz > ctx->max_txn_size) { free(wbuf); return -EINVAL; }
                uint8_t *data = malloc(dsz ? dsz : 1);
                uint8_t *offs = malloc(osz ? osz : 1);
                if (!data || !offs) { free(data); free(offs); free(wbuf); return -ENOMEM; }
                if (dsz) {
                    r = mem->read(mem->opaque, td.data.ptr.buffer, data, dsz);
                    if (r) { free(data); free(offs); free(wbuf); return r; }
                }
                if (osz) {
                    r = mem->read(mem->opaque, td.data.ptr.offsets, offs, osz);
                    if (r) { free(data); free(offs); free(wbuf); return r; }
                }
                int rr = binder_transaction(ctx, proc, thread,
                                            td.target.handle, td.code, td.flags,
                                            data, dsz, offs, osz,
                                            cmd == BC_REPLY, mem);
                free(data);
                free(offs);
                if (rr < 0) { free(wbuf); return rr; }
                break;
            }
            case BC_TRANSACTION_SG:
            case BC_REPLY_SG: {
                struct binder_transaction_data_sg tds;
                if (p + sizeof(tds) > sz) { free(wbuf); return -EPROTO; }
                memcpy(&tds, wbuf + p, sizeof(tds));
                p += sizeof(tds);
                if (p + tds.transaction_data.data_size +
                    tds.transaction_data.offsets_size > sz) {
                    free(wbuf); return -EINVAL;
                }
                int rr = binder_transaction(ctx, proc, thread,
                                            tds.transaction_data.target.handle,
                                            tds.transaction_data.code,
                                            tds.transaction_data.flags,
                                            wbuf + p,
                                            tds.transaction_data.data_size,
                                            wbuf + p + tds.transaction_data.data_size,
                                            tds.transaction_data.offsets_size,
                                            cmd == BC_REPLY_SG, mem);
                if (rr < 0) { free(wbuf); return rr; }
                p += tds.transaction_data.data_size +
                     tds.transaction_data.offsets_size;
                break;
            }
            case BC_FREE_BUFFER: {
                uint64_t user;
                if (p + 8 > sz) { free(wbuf); return -EPROTO; }
                memcpy(&user, wbuf + p, 8);
                p += 8;
                buffer_free(ctx, proc, user);
                break;
            }
            case BC_INCREFS:
            case BC_ACQUIRE:
            case BC_RELEASE:
            case BC_DECREFS: {
                uint32_t h;
                if (p + 4 > sz) { free(wbuf); return -EPROTO; }
                memcpy(&h, wbuf + p, 4);
                p += 4;
                struct binder_ref *ref = ref_lookup_handle(proc, h);
                if (ref) {
                    if (cmd == BC_ACQUIRE) ref->strong++;
                    else if (cmd == BC_RELEASE && ref->strong > 0) ref->strong--;
                    else if (cmd == BC_INCREFS) ref->weak++;
                    else if (cmd == BC_DECREFS && ref->weak > 0) ref->weak--;
                }
                break;
            }
            case BC_INCREFS_DONE:
            case BC_ACQUIRE_DONE: {
                struct binder_ptr_cookie pc;
                if (p + 16 > sz) { free(wbuf); return -EPROTO; }
                memcpy(&pc, wbuf + p, 16);
                p += 16;
                (void)pc;
                break;
            }
            case BC_REGISTER_LOOPER:
                if (proc->requested_threads > 0) {
                    proc->requested_threads--;
                    proc->requested_threads_started++;
                }
                thread->looper = LOOPER_REGISTERED;
                break;
            case BC_ENTER_LOOPER:
                thread->looper = LOOPER_ENTERED;
                break;
            case BC_EXIT_LOOPER:
                thread->looper = LOOPER_NONE;
                break;
            case BC_REQUEST_DEATH_NOTIFICATION:
            case BC_CLEAR_DEATH_NOTIFICATION: {
                uint32_t h;
                uint64_t co;
                if (p + 12 > sz) { free(wbuf); return -EPROTO; }
                memcpy(&h, wbuf + p, 4);
                memcpy(&co, wbuf + p + 4, 8);
                p += 12;
                struct binder_ref *ref = ref_lookup_handle(proc, h);
                if (ref) {
                    struct binder_ref_death *d;
                    for (d = ref->death; d; d = d->next)
                        if (d->cookie == co) break;
                    if (cmd == BC_REQUEST_DEATH_NOTIFICATION) {
                        if (!d) {
                            d = calloc(1, sizeof(*d));
                            if (!d) { free(wbuf); return -ENOMEM; }
                            d->cookie = co;
                            d->next = ref->death;
                            ref->death = d;
                        }
                        d->armed = true;
                    } else if (d) {
                        d->armed = false;
                    }
                }
                break;
            }
            case BC_DEAD_BINDER_DONE:
                if (p + 8 > sz) { free(wbuf); return -EPROTO; }
                p += 8;
                break;
            case BC_ATTEMPT_ACQUIRE:
                if (p + 8 > sz) { free(wbuf); return -EPROTO; }
                p += 8;
                break;
            case BC_ACQUIRE_RESULT:
            case BC_REQUEST_FREEZE_NOTIFICATION:
            case BC_CLEAR_FREEZE_NOTIFICATION:
                if (p + 12 > sz) { free(wbuf); return -EPROTO; }
                p += 12;
                break;
            case BC_FREEZE_NOTIFICATION_DONE:
                if (p + 8 > sz) { free(wbuf); return -EPROTO; }
                p += 8;
                break;
            default:
                free(wbuf);
                return -EINVAL;
            }
        }
        bwr->write_consumed = sz;
        free(wbuf);
    }

    if (bwr->read_size > 0) {
        size_t rc = bwr->read_consumed;
        int r = binder_thread_read(ctx, thread, mem,
                                   bwr->read_buffer, bwr->read_size,
                                   &rc, 0);
        if (r < 0) return r;
        bwr->read_consumed = rc;
    }

    return 0;
}

int
binder_ioctl(struct binder_ctx *ctx, struct binder_proc *proc,
             struct binder_thread *thread, unsigned int cmd,
             const void *arg, const struct binder_mem *mem, int nonblock)
{
    int ret;
    if (!proc) return -ENXIO;

    pthread_mutex_lock(&ctx->lock);
    ret = binder_ioctl_locked(ctx, proc, thread, cmd, arg, mem, nonblock);
    pthread_mutex_unlock(&ctx->lock);
    return ret;
}

static int
binder_ioctl_locked(struct binder_ctx *ctx, struct binder_proc *proc,
                    struct binder_thread *thread, unsigned int cmd,
                    const void *arg, const struct binder_mem *mem,
                    int nonblock)
{
    (void)nonblock;
    switch (cmd) {
    case BINDER_WRITE_READ:
        return ioctl_write_read(ctx, proc, thread, mem, (void *)arg);
    case BINDER_VERSION: {
        struct binder_version v;
        v.protocol_version = BINDER_CURRENT_PROTOCOL_VERSION;
        memcpy((void *)arg, &v, sizeof(v));
        return 0;
    }
    case BINDER_SET_CONTEXT_MGR_EXT: {
        const struct flat_binder_object *fbo = arg;
        if (ctx->ctx_mgr) return -EBUSY;
        if (fbo->flags & FLAT_BINDER_FLAG_TXN_SECURITY_CTX)
            ctx->ctx_mgr_security_ctx = 1;
        ctx->ctx_mgr = proc;
        proc->is_context_manager = true;
        ctx->ctx_mgr_node = node_new(proc, 0, 0);
        blog(ctx, "%d: SET_CONTEXT_MGR_EXT\n", proc->pid);
        return ctx->ctx_mgr_node ? 0 : -ENOMEM;
    }
    case BINDER_SET_CONTEXT_MGR:
        if (ctx->ctx_mgr) return -EBUSY;
        ctx->ctx_mgr = proc;
        proc->is_context_manager = true;
        ctx->ctx_mgr_node = node_new(proc, 0, 0);
        return ctx->ctx_mgr_node ? 0 : -ENOMEM;
    case BINDER_SET_MAX_THREADS: {
        int32_t mt;
        memcpy(&mt, arg, 4);
        proc->max_threads = mt > 0 ? mt : 16;
        return 0;
    }
    case BINDER_GET_NODE_INFO_FOR_REF: {
        struct binder_node_info_for_ref *info = (void *)arg;
        struct binder_ref *ref = ref_lookup_handle(proc, info->handle);
        if (!ref) return -EINVAL;
        info->strong_count = ref->node->has_strong_ref;
        info->weak_count = ref->node->has_weak_ref;
        info->reserved1 = info->reserved2 = info->reserved3 = 0;
        return 0;
    }
    case BINDER_GET_NODE_DEBUG_INFO: {
        struct binder_node_debug_info *info = (void *)arg;
        info->ptr = 0;   /* sentinel: no more nodes */
        info->cookie = 0;
        info->has_strong_ref = 0;
        info->has_weak_ref = 0;
        return 0;
    }
    case BINDER_FREEZE: {
        const struct binder_freeze_info *fi = arg;
        for (struct binder_proc *p = ctx->procs; p; p = p->next)
            if (p->pid == (int32_t)fi->pid) {
                p->frozen = fi->enable != 0;
                return 0;
            }
        return -EINVAL;
    }
    case BINDER_GET_FROZEN_INFO: {
        struct binder_frozen_status_info *si = (void *)arg;
        for (struct binder_proc *p = ctx->procs; p; p = p->next)
            if (p->pid == (int32_t)si->pid) {
                si->sync_recv = (p->frozen ? 1 : 0);
                si->async_recv = 0;
                return 0;
            }
        return -EINVAL;
    }
    case BINDER_ENABLE_ONEWAY_SPAM_DETECTION:
        return 0;
    case BINDER_THREAD_EXIT:
        return 0;
    case BINDER_SET_IDLE_TIMEOUT:
    case BINDER_SET_IDLE_PRIORITY:
        return 0;
    default:
        return -EINVAL;
    }
}

/* Free every still-queued work item in a single-linked work list. Used on
 * proc teardown for anything never delivered to a thread. */
static void
drain_work_list(struct binder_work **head, struct binder_work **tail)
{
    struct binder_work *w = *head;
    while (w) {
        struct binder_work *n = w->next;
        free(w);
        w = n;
    }
    *head = *tail = NULL;
}

/* ---------------- proc lifecycle ---------------- */

/* Queue BR_DEAD_BINDER to every proc holding a ref to a node owned by
 * `victim`. Caller holds ctx->lock. */
static void
fire_death_notifications(struct binder_ctx *ctx, struct binder_proc *victim)
{
    for (struct binder_proc *p = ctx->procs; p; p = p->next) {
        if (p == victim) continue;
        for (struct binder_ref *r = p->refs; r; r = r->next) {
            if (!r->dead && r->node && r->node->proc == victim) {
                r->dead = true;
                for (struct binder_ref_death *d = r->death; d; d = d->next) {
                    if (d->armed) {
                        struct binder_work *w = work_new(WORK_DEAD_BINDER,
                                                         d->cookie);
                        if (w) proc_enqueue_todo(p, w);
                    }
                }
                proc_wakeup(p);
            }
        }
    }
}

void
binder_proc_close(struct binder_ctx *ctx, struct binder_proc *proc)
{
    if (!proc || proc->dead) return;
    pthread_mutex_lock(&ctx->lock);
    proc_close_locked(ctx, proc);
    pthread_mutex_unlock(&ctx->lock);
}

static void
proc_close_locked(struct binder_ctx *ctx, struct binder_proc *proc)
{
    int32_t pid = proc->pid;
    proc->dead = true;

    if (ctx->ctx_mgr == proc) {
        ctx->ctx_mgr = NULL;
        ctx->ctx_mgr_node = NULL;
    }

    fire_death_notifications(ctx, proc);

    /* unlink */
    if (ctx->procs == proc) {
        ctx->procs = proc->next;
    } else {
        for (struct binder_proc *p = ctx->procs; p; p = p->next)
            if (p->next == proc) { p->next = proc->next; break; }
    }

    /* threads: drop queued work, then free the thread structs */
    struct binder_thread *t = proc->threads;
    while (t) {
        struct binder_thread *n = t->next;
        drain_work_list(&t->work_head, &t->work_tail);
        pthread_cond_destroy(&t->wait_cond);
        free(t);
        t = n;
    }
    drain_work_list(&proc->todo, &proc->todo_tail);

    /* refs + deaths */
    struct binder_ref *r = proc->refs;
    while (r) {
        struct binder_ref *n = r->next;
        struct binder_ref_death *d = r->death;
        while (d) {
            struct binder_ref_death *dn = d->next;
            free(d);
            d = dn;
        }
        free(r);
        r = n;
    }

    /* nodes */
    struct binder_node *nn = proc->nodes;
    while (nn) {
        struct binder_node *n = nn->next;
        free(nn);
        nn = n;
    }

    /* buffers */
    struct binder_buf *b = proc->buffers;
    while (b) {
        struct binder_buf *n = b->next;
        ctx->free_buffer(ctx->alloc_opaque, proc, b->user);
        free(b);
        b = n;
    }

    /* todo */
    while (proc->todo) {
        struct binder_work *w = proc->todo;
        proc->todo = w->next;
        free(w);
    }

    free(proc);
    blog(ctx, "%d: proc closed\n", pid);
}