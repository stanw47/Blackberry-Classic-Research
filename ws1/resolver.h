#ifndef WS1_RESOLVER_H
#define WS1_RESOLVER_H

enum ws1_kind { WS1_ALIAS = 0, WS1_GLUE = 1, WS1_OVERLAP = 2 };

struct ws1_slot {
    void **ptr;        /* <- points at the .data storage word in tramps.S */
    const char *name;  /* bionic ABI symbol name being exported         */
    int kind;          /* how the slot was classified during WS1 mapping */
};

extern struct ws1_slot ws1_slots[];
extern unsigned ws1_nslots;

/* glue-stub landing pad: replace per-symbol glue later (WS1b) */
extern void __ws1_unimplemented(void);

void __attribute__((visibility("hidden"))) ws1_resolve_all(void);

/* glue lookup (defined in glue_impl.c); hidden so the resolver's reference is
 * bound at link time and never routed through a trampoline slot. */
void * __attribute__((visibility("hidden"))) ws1_lookup_glue(const char *name);

/* Resolve a single slot on demand (idempotent) and return the resolved fn.
 * Called by ws1_resolver.S when it finds an unfilled slot, so the shim works
 * regardless of constructor/init-array ordering relative to other DSOs. */
void * __attribute__((visibility("hidden"))) ws1_resolve_slot(struct ws1_slot *s);

#endif