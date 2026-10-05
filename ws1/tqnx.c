typedef unsigned long size_t;
extern size_t strlen(const char*);
extern int write(int,const void*,size_t);
extern void* dlopen(const char*,int);
extern void* dlsym(void*,const char*);
extern int dlclose(void*);
extern void exit(int);
static void says(const char*s){ write(1,s,strlen(s)); }
static void hl(const char*l,const void*p){
    unsigned long v=(unsigned long)p; char b[16]; int i; b[0]='0';b[1]='x';
    for(i=0;i<8;i++){ unsigned d=(v>>(28-4*i))&0xf; b[2+i]=d<10?('0'+d):('a'+d-10); }
    b[10]='\n'; write(1,l,strlen(l)); write(1,b,11);
}
int main(void){
    void*h; void*(*zv)(void);
    char v0='A'; char *s;
    says("TQNX: QNX-libc-only smoke (no shim)\n");
    hl("__TLS ptr   ", (void*)&v0);
    h=dlopen("libz.so",1);
    hl("dlopen(z)   ", h);
    if(!h){ says("dlopen FAILED\n"); exit(1); }
    zv=(void*(*)(void))dlsym(h,"zlibVersion");
    s=zv? zv() : 0;
    hl("zlibVersion ", s);
    says(s? s : "(undef)\n");
    says("\n");
    dlclose(h);
    exit(0);
}
