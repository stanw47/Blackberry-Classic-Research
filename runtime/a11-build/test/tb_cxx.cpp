/* tb_cxx — regression probe for the ip=00000000 fault.
 *
 * Pulls in libc++'s iostream static initializer (_GLOBAL__sub_I_iostream.cpp ->
 * std::ios_base::Init::Init()) and a global std::ostringstream, so libc++'s
 * .init_array runs and calls into the shim.  Before the two ws1 fixes this ran
 * before the shim's resolver ctor and hit an unfilled slot -> bx 0 (ip=0).
 * Expected now: the lazy resolver fills the slot on demand -> "A11 libs loaded"
 * + RC=0. */
#include <iostream>
#include <sstream>
#include <string>

extern "C" {
int write(int, const void *, unsigned long);
void _exit(int);
}

/* Constructing iostream/ostringstream globals forces libc++'s
 * _GLOBAL__sub_I_iostream.cpp (std::ios_base::Init) to run at load, which is
 * exactly where the ip=0 fault used to occur.  We deliberately do NOT use
 * operator<< here: that additionally needs libc++'s locale facets wired to a
 * real platform locale (separate WS1b work). */
static std::ostringstream ws1_force_iostream_init;
static std::string ws1_force_string("loaded");

int main()
{
    (void)ws1_force_iostream_init;
    if (ws1_force_string.size() == 12345)
        write(1, "?\n", 2);
    write(1, "A11 libs loaded\n", 16);
    _exit(0);
    return 0;
}
