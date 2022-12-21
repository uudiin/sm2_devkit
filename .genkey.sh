#!/bin/bash

export LD_LIBRARY_PATH=`pwd`
export DYLD_LIBRARY_PATH=`pwd`

export PATH=`pwd`/apps:$PATH

if [ ! -e .genkey.conf ]; then
cat > .genkey.conf <<- EOF
	[ req ]
	distinguished_name = req_distinguished_name
	prompt = no
	string_mask = utf8only
	x509_extensions = v3_ca

	[ req_distinguished_name ]
	O = rfc8998-CA
	CN = RFC8998 certificate signing key
	emailAddress = ca@rfc8998-ca

	[ v3_ca ]
	basicConstraints=CA:TRUE
	subjectKeyIdentifier=hash
	authorityKeyIdentifier=keyid:always,issuer

	[ skid ]
	basicConstraints=CA:TRUE
	subjectKeyIdentifier=12345678
	authorityKeyIdentifier=keyid:always,issuer
EOF
fi

if [ ! -e sm2.key ]; then
    # for OpenSSL 1.1.1
    echo '----------------- 1.1.1 command -----------------'
    openssl req -verbose -new -nodes -utf8 -days 10000 -batch -x509 \
        -sm3 -sigopt "distid:1234567812345678" \
        -config .genkey.conf \
        -newkey sm2 \
        -out sm2.cert \
        -keyout sm2.key

    # for OpenSSL 3.0
    #echo '----------------- 3.0.0 command -----------------'
    #openssl req -verbose -new -nodes -utf8 -days 10000 -batch -x509 \
    #    -sm3 -sigopt "distid:1234567812345678" \
    #    -config .genkey.conf \
    #    -copy_extensions copyall \
    #    -newkey sm2 \
    #    -out sm2.cert \
    #    -keyout sm2.key

    openssl pkey -in sm2.key -out sm2.pub -pubout
fi

if [ ! -e rsa.key ]; then
    echo '------------------------------- RSA -------------------------------'
    openssl req -verbose -new -nodes -utf8 -days 10000 -batch -x509 \
        -sha256 \
        -config .genkey.conf \
        -newkey rsa:2048 \
        -out rsa.cert \
        -keyout rsa.key

    openssl pkey -in rsa.key -out rsa.pub -pubout
fi
