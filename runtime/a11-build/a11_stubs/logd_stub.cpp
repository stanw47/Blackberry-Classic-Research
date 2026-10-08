/* logd_stub.cpp — liblog's logd_writer.cpp is excluded from the QNX build, but
 * logger_write.cpp still references LogdWrite.  Provide a no-op with the exact
 * signature (mangled _Z9LogdWrite6log_idP8timespecP5iovecj). */
#include <android/log.h>
#include <time.h>
#include <sys/uio.h>
#include <stddef.h>

int LogdWrite(log_id_t logId, struct timespec* ts, struct iovec* vec, size_t nr)
{
    (void)logId; (void)ts; (void)vec; (void)nr;
    return 0;
}

int PmsgWrite(log_id_t logId, struct timespec* ts, struct iovec* vec, size_t nr)
{
    (void)logId; (void)ts; (void)vec; (void)nr;
    return 0;
}
