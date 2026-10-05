/* a11hello — minimal Android 11 executable that runs *A11 C++ code* on QNX.
 *
 * Uses android::String16 (libutils) so it exercises the real A11 class +
 * operator new + SharedBuffer + libc++/libutils static init, with the WS2
 * QNX `_start` (argc/argv from the initial stack).  Prints "A11-EXE-OK". */
#include <utils/String16.h>

extern "C" int write(int, const void *, unsigned long);

extern "C" int main(int argc, char **argv)
{
    (void)argc; (void)argv;
    android::String16 s(u"hello-a11");
    if (s.size() == 9)
        write(1, "A11-EXE-OK\n", 11);
    else
        write(1, "A11-EXE-BAD\n", 12);
    return 0;
}
