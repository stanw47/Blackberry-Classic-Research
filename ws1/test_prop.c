typedef unsigned long size_t;
extern int write(int, const void *, size_t);
extern size_t strlen(const char *);
extern void _exit(int);
extern int __system_property_set(const char *, const char *);
extern int __system_property_get(const char *, char *);
extern const void *__system_property_find(const char *);

int main(void)
{
    char val[64];
    int r1 = __system_property_set("test.foo", "hello");
    int r2 = __system_property_get("test.foo", val);
    const void *f = __system_property_find("test.foo");
    int r3 = __system_property_get("test.missing", val);
    char out[8];
    out[0] = (r1==0)?'1':'X';
    out[1] = (r2==5)?'2':'X';
    out[2] = f?'3':'X';
    out[3] = (r3==-1)?'4':'X';
    out[4] = '\n';
    write(1, out, 5);
    write(1, val, r2>0?r2:0);
    write(1, "\n", 1);
    _exit(0);
    return 0;
}
