
#include "sm2_debug.h"
#include "data_ca.c"
#include "data_cert.c"

/*
 * Module stuff
 */
static int __init x509_cert_test_init(void)
{
    struct x509_certificate *cert;
    struct x509_certificate *cert_ca;
    int ret;

    __log_info("---------------------------------------- sm2\n");

    cert = x509_cert_parse(cert_der, cert_der_len);
    if (IS_ERR(cert))
        __log_error("cert, err = %ld\n", PTR_ERR(cert));

    __log_info("---------------------------------------- ca\n");

    cert_ca = x509_cert_parse(ca_der, ca_der_len);
    if (IS_ERR(cert_ca))
        __log_error("ca cert, err = %ld\n", PTR_ERR(cert_ca));

    __log_info("---------------------------------------- verify\n");

    if (!IS_ERR(cert) && !IS_ERR(cert_ca)) {
        __log_info("ca pkey_algo: %s\n", cert_ca->pub->pkey_algo);
        __log_info("pkey_algo: %s\n", cert->sig->pkey_algo);
        __log_info("hash_algo: %s\n", cert->sig->hash_algo);
        __log_info("encoding: %s\n", cert->sig->encoding);

        ret = public_key_verify_signature(cert_ca->pub, cert->sig);
        __log_info("verify: %d\n", ret);
    }

    __log_info("----------------------------------------------\n");

    return 0;
}

static void __exit x509_cert_test_exit(void)
{
}

module_init(x509_cert_test_init);
module_exit(x509_cert_test_exit);
