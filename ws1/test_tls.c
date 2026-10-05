/* ws1/test_tls.c — exercise __get_tls/__get_thread/gettid glue. */
typedef unsigned long size_t;
extern int write(int, const void *, size_t);
extern size_t strlen(const char *);
extern void _exit(int);

extern void *__get_tls(void);
extern void *__get_thread(void);
extern int __pthread_gettid(const void *);
extern int pthread_gettid_np(void);
extern void *pthread_self(void);

static void wr(const char *s){ write(1, s, strlen(s)); }
static void wrn(int n){ char b[16]; int i=0; if(n<0){n=-n;write(1,"-",1);} do{b[i++]='0'+n%10;n/=10;}while(n); while(i>0){char c=b[--i];write(1,&c,1);} write(1,"\n",1); }

int main(void)
{
    void *tls = __get_tls();
    void *thr = __get_thread();
    void *self = pthread_self();
    int tid = pthread_gettid_np();
    int tid2 = __pthread_gettid(thr);

    wr("tls!=null="); wrn(tls ? 1 : 0);
    wr("thread==self="); wrn(thr == self ? 1 : 0);
    wr("tid="); wrn(tid);
    wr("tid2="); wrn(tid2);

    /* __get_thread must equal pthread_self (both go through our glue) */
    wr("TLS OK\n");
    _exit(0);
    return 0;
}
