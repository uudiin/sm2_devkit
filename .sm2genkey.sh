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


# Generate a self signed root certificate

openssl ecparam -genkey -name SM2 -text -out ca.key

openssl req -verbose -new -days 10000 -x509 \
    -sm3 \
    -sigopt "distid:1234567812345678" \
    -config .genkey.conf \
    -key ca.key \
    -out ca.crt

# Generate a certificate request from private key and verify it

openssl ecparam -genkey -name SM2 -text -out private.pem

openssl req -verbose -new \
    -sm3 \
    -sigopt "distid:1234567812345678" \
    -config .genkey.conf \
    -key private.pem \
    -out csr.pem

openssl req -verbose -verify \
    -vfyopt "distid:1234567812345678" \
    -config .genkey.conf \
    -noout -text \
    -in csr.pem

# Sign a SM2 certificate request using the CA certificate

openssl x509 -req -days 10000 \
    -sm3 \
    -sigopt "distid:1234567812345678" \
    -vfyopt "distid:1234567812345678" \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -extfile .genkey.conf -extensions v3_ca \
    -in csr.pem \
    -out cert.pem

openssl x509 -in cert.pem -outform DER -out cert.der


# yet another way

if [ ! -e sm2.cert ]; then
    # for OpenSSL 1.1.1
    openssl req -verbose -new -days 10000 -x509 \
        -nodes -utf8 -batch \
        -sm3 \
        -sigopt "distid:1234567812345678" \
        -config .genkey.conf \
        -newkey ec:private.pem \
        -out sm2.cert \
        -keyout sm2.key

    # for OpenSSL 3.0
    #openssl req -verbose -new -nodes -utf8 -days 10000 -batch -x509 \
    #    -sm3 -sigopt "distid:1234567812345678" \
    #    -config .genkey.conf \
    #    -copy_extensions copyall \
    #    -newkey sm2 \
    #    -out sm2.cert \
    #    -keyout sm2.key

    openssl pkey -in sm2.key -out sm2.pub -pubout
fi
