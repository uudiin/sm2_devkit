#include <linux/mpi.h>

#define pr_debug(fmt, ...) __log_info(fmt, ##__VA_ARGS__)
#define pr_devel(fmt, ...) __log_info(fmt, ##__VA_ARGS__)
#define pr_warn(fmt, ...) __log_info(fmt, ##__VA_ARGS__)
#define pr_err(fmt, ...) __log_info(fmt, ##__VA_ARGS__)

static void ___hexdump(const char *prefix, unsigned char *buf, unsigned int len)
{
    if (!prefix)
        prefix = "";
    print_hex_dump(KERN_CONT, prefix, DUMP_PREFIX_NONE,
            32, 1,
            buf, len, false);
}

#define __hexdump(prefix, buf, sz) ___hexdump(prefix, (unsigned char *)buf, sz)

static void buffer_dump(const char *prefix, unsigned char *buf, unsigned int len)
{
    char buffer[256];
    int i = 0;

    for ( ; len > 0; len--) {
        sprintf(&buffer[i * 2], "%02x", *buf++);
        i += 1;
        if (i == 32) {
            buffer[i * 2] = '\0';
            pr_info("%s%s\n", prefix, buffer);
            i = 0;
        }
    }
    if (i > 0) {
        buffer[i * 2] = '\0';
        pr_info("%s%s\n", prefix, buffer);
    }
}

static void log_printmpi(const char *text, MPI mpi)
{
    char buffer[256];
    size_t text_len;
    size_t n = 0;
    int rc;

    text_len = strlen(text);
    if (text_len < sizeof(buffer) - 64) {
        strcpy(buffer, text);
        rc = mpi_print(GCRYMPI_FMT_HEX, buffer + text_len,
                        sizeof(buffer) - text_len, &n, mpi);
        if (!rc) {
            pr_info("%s\n", buffer);
            return;
        }
    }

    pr_info("%s", text);
    rc = mpi_print(GCRYMPI_FMT_HEX, buffer, sizeof(buffer), &n, mpi);
    if (!rc) {
        pr_info("%s\n", buffer);
    } else {
        pr_info(" [out of core]\n");
    }
}
