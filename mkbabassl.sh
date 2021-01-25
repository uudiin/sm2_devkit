#!/bin/bash

# for babassl

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


# Create an SM2 private key

openssl ecparam -genkey -name SM2 -out private.pem


# Generate a certificate request from key

openssl req -new \
    -key private.pem \
    -out csr.pem \
    -sm3 -sigopt "sm2_id:1234567812345678" \
    -subj "/C=CN/ST=Zhejiang/L=Hangzhou/O=Alibaba/OU=OS/CN=test/emailAddress=test@foo.com"


# Generate a self signed root certificate:

openssl ecparam -genkey -name SM2 -text -out ca.key
openssl req -new \
    -x509 -days 3650 \
    -key ca.key \
    -out ca.crt \
    -sm3 -sigopt "sm2_id:1234567812345678" \
    -subj "/C=CN/ST=Zhejiang/L=Hangzhou/O=Alibaba/OU=OS/CN=CA/emailAddress=ca@foo.com"


# Sign a SM2 certificate request using the CA certificate
# and add user certificate extensions

openssl x509 \
    -req -days 3650 \
    -in csr.pem \
    -out cert.pem \
    -sm3 \
    -sigopt "sm2_id:1234567812345678" \
	-sm2-id "1234567812345678" \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -extfile openssl.cnf -extensions v3_req


# PEM format to DER
openssl x509 -in ca.crt -outform DER -out ca.der
openssl x509 -in cert.pem -outform DER -out cert.der
