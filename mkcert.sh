#!/bin/bash

if [ ! -f openssl.cnf ]; then
	cat > openssl.cnf << EOF
[ req ]
default_bits = 2048
distinguished_name = req_distinguished_name
prompt = no
string_mask = utf8only
x509_extensions = v3_req

[ req_distinguished_name ]
O = Test
OU = Test
CN = Test key
emailAddress = test@foo.com

[ v3_req ]
basicConstraints=critical,CA:FALSE
keyUsage=digitalSignature
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always
EOF
fi

openssl ecparam -genkey -name SM2 -text -out private.pem

openssl req -new \
	-key private.pem \
	-out csr.pem \
	-sm3 -sigopt "distid:1234567812345678" \
    -subj "/C=CN/ST=GS/L=Gt/O=baba/OU=OS/CN=hello/emailAddress=hello@world.com"

openssl ecparam -genkey -name SM2 -text -out ca.key

openssl req -new \
    -x509 -days 3650 \
    -sm3 -sigopt "distid:1234567812345678" \
    -key ca.key \
    -out ca.crt \
    -subj "/C=CN/ST=GS/L=Gt/O=baba/OU=OS/CN=ca/emailAddress=ca@world.com"

openssl x509 -req -days 3650 \
    -sm3 \
    -sigopt "distid:1234567812345678" \
	-vfyopt "distid:1234567812345678" \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -extfile openssl.cnf -extensions v3_req \
    -in csr.pem \
    -out cert.pem

openssl x509 -in ca.crt -outform DER -out ca.der
openssl x509 -in cert.pem -outform DER -out cert.der

xxd -i ca.der > data_ca.c
xxd -i cert.der > data_cert.c
