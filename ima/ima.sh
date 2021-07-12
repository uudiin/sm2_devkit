#!/bin/bash

rm -f ca-sm2.conf

cat > ca-sm2.conf <<- EOF
	[ req ]
	distinguished_name = req_distinguished_name
	prompt = no
	string_mask = utf8only
	x509_extensions = v3_ca

	[ req_distinguished_name ]
	O = CA-SM2
	CN = SM2 certificate signing key
	emailAddress = ca@ca-sm2

	[ v3_ca ]
	basicConstraints=CA:TRUE
	subjectKeyIdentifier=hash
	authorityKeyIdentifier=keyid:always,issuer
EOF

# gen self-signed root certificate
openssl req -verbose -new -nodes -utf8 -days 10000 -batch -x509 \
    -sm3 -sigopt "distid:1234567812345678" \
    -config ca-sm2.conf \
    -copy_extensions copyall \
    -newkey sm2 \
    -out ca-sm2.crt \
    -keyout ca-sm2.key

#openssl ec -in ca-sm2.key -noout -text
#openssl x509 -in ca-sm2.cer -noout -text


# sign IMA certificate with CA SM2 key

openssl ecparam -genkey -name SM2 -out private.pem

openssl req -new \
    -key private.pem \
    -out csr.pem \
    -sm3 -sigopt "distid:1234567812345678" \
    -config ca-sm2.conf \
    -subj "/O=IMA-SM2/CN=IMA SM2 test/emailAddress=ima@ima-sm2"

openssl x509 -req -days 3650 \
    -sm3 \
    -sigopt "distid:1234567812345678" \
    -vfyopt "distid:1234567812345678" \
    -CA ca-sm2.crt -CAkey ca-sm2.key -CAcreateserial \
    -extfile ca-sm2.conf -extensions v3_ca \
    -in csr.pem \
    -out cert.pem

openssl x509 -in cert.pem -outform DER -out cert.der

#openssl ec -in private.pem -noout -text
#openssl x509 -in cert.pem -noout -text


#### IMA
#touch sm3.txt
#openssl dgst -sm3 sm3.txt
#openssl dgst -sm3 -sign test-sm2.key -hex sm3.txt
#evmctl ima_sign --sigfile --hashalgo sm3 --key test-sm2.key --xattr-user sm3.txt
#openssl dgst -sm3 -verify test-sm2.pub -signature sm3.txt.sig sm3.txt
#evmctl ima_verify --sigfile --key test-sm2.pub sm3.txt


