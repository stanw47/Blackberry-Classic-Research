/* tb_qnxb — print qnxb_ptrs entries (link-time bound QNX pointers). */
typedef unsigned long size_t;
extern int write(int, const void *, size_t);
extern void _exit(int);
extern void *qnxb_ptrs[];

static void ph(unsigned long v)
{
    static const char hx[] = "0123456789abcdef";
    char b[11];
    int i;
    b[0] = '0'; b[1] = 'x';
    for (i = 0; i < 8; ++i) b[2 + i] = hx[(v >> ((7 - i) * 4)) & 0xf];
    b[10] = ' ';
    write(1, b, 11);
}

int main(void)
{
    write(1, "write@", 6); ph((unsigned long)(void *)write); write(1, "\n", 1);
    write(1, "ptr[667] ", 9); ph((unsigned long)qnxb_ptrs[667]); write(1, "\n", 1);
    write(1, "ptr[380] ", 9); ph((unsigned long)qnxb_ptrs[380]); write(1, "\n", 1);
    write(1, "ptr[489] ", 9); ph((unsigned long)qnxb_ptrs[489]); write(1, "\n", 1);
    write(1, "ptr[97]  ", 9); ph((unsigned long)qnxb_ptrs[97]); write(1, "\n", 1);
    _exit(0);
    return 0;
}
