/* a11binder — exercise the A11 binder IPC core on QNX.
 *
 * Calls ProcessState::self() (opens the binder driver) and
 * IPCThreadState::self() — the heart of Android's IPC — to see how far binder
 * initialization gets outside/inside the runtime container. */
#include <unistd.h>
#include <binder/ProcessState.h>
#include <binder/IPCThreadState.h>

using namespace android;

#define SAY(s) write(1, (s), sizeof(s) - 1)

extern "C" int main(int argc, char **argv)
{
    (void)argc; (void)argv;

    sp<ProcessState> ps = ProcessState::self();
    SAY(ps != nullptr ? "PS-OK " : "PS-NULL ");

    IPCThreadState *its = IPCThreadState::self();
    SAY(its != nullptr ? "ITS-OK" : "ITS-NULL");
    SAY("\n");
    return 0;
}
