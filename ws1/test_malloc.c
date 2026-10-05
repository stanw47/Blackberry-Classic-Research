/* ws1/test_malloc.c — exercise malloc-family glue on-device. */
typedef unsigned long size_t;
extern int write(int, const void *, size_t);
extern size_t strlen(const char *);
extern void _exit(int);

extern void *malloc(size_t);
extern void free(void *);
extern void *calloc(size_t, size_t);
extern void *realloc(void *, size_t);
extern size_t malloc_usable_size(void *);
extern void *reallocarray(void *, size_t, size_t);

static void wr(const char *s){ write(1, s, strlen(s)); }
static void wrn(int n){ char b[16]; int i=0; if(n<0){n=-n;write(1,"-",1);} do{b[i++]='0'+n%10;n/=10;}while(n); while(i>0){char c=b[--i];write(1,&c,1);} write(1,"\n",1); }

int main(void)
{
    char *p = malloc(64);
    wr("malloc="); wrn(p ? 1 : 0);
    if (p) { p[0]='A'; p[1]='B'; p[2]='C'; p[3]='\0'; }

    size_t us = malloc_usable_size(p);
    wr("usable_size="); wrn((int)us);

    p = realloc(p, 128);
    wr("realloc="); wrn(p ? 1 : 0);

    char *q = calloc(4, 8);
    wr("calloc="); wrn(q ? 1 : 0);
    wr("calloc_zero="); wrn(q && q[0]==0 && q[1]==0 ? 1 : 0);
    free(q);

    void *r = reallocarray(0, 10, 8);
    wr("reallocarray="); wrn(r ? 1 : 0);
    free(r);

    free(p);
    wr("MALLOC OK\n");
    _exit(0);
    return 0;
}
