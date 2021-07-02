#!/bin/bash

rm -f test-ca.conf

cat > test-ca.conf <<- EOF
	[ req ]
	distinguished_name = req_distinguished_name
	prompt = no
	string_mask = utf8only
	x509_extensions = v3_ca

	[ req_distinguished_name ]
	O = IMA-CA
	CN = IMA/EVM certificate signing key
	emailAddress = ca@ima-ca

	[ v3_ca ]
	basicConstraints=CA:TRUE
	subjectKeyIdentifier=hash
	authorityKeyIdentifier=keyid:always,issuer
EOF

## OK
#openssl req -verbose -new -nodes -utf8 -sha1 -days 10000 -batch -x509 \
#    -config test-ca.conf \
#    -copy_extensions copyall \
#    -newkey ec \
#    -pkeyopt ec_paramgen_curve:prime256v1 \
#    -out prime256v1.cer -outform DER \
#    -keyout prime256v1.key

## FIXME
#openssl req -verbose -new -nodes -utf8 -days 10000 -batch -x509 \
#    -sm3 -sigopt "distid:1234567812345678" \
#    -config test-ca.conf \
#    -newkey ec \
#    -pkeyopt ec_paramgen_curve:sm2 \
#    -out test-sm2.cer -outform DER \
#    -keyout test-sm2.key

openssl req -verbose -new -nodes -utf8 -days 10000 -batch -x509 \
    -sm3 -sigopt "distid:1234567812345678" \
    -config test-ca.conf \
    -copy_extensions copyall \
    -newkey sm2 \
    -out test-sm2.cer -outform DER \
    -keyout test-sm2.key

openssl ec -in test-sm2.key -noout -text
openssl x509 -in test-sm2.cer -inform DER -noout -text

#### sign
openssl dgst -sm3 sm3.txt
openssl dgst -sm3 -sign test-sm2.key -hex sm3.txt


#### TODO
openssl ecparam -genkey -name SM2 -out sm2.key
openssl ec -in sm2.key -noout -text
openssl req -new -key sm2.key -out sm2.csr -sm3 -sigopt "distid:1234567812345678"


#### IMA
touch sm3.txt
openssl dgst -sm3 sm3.txt
openssl dgst -sm3 -sign test-sm2.key -hex sm3.txt
evmctl ima_sign --sigfile --hashalgo sm3 --key test-sm2.key --xattr-user sm3.txt
openssl dgst -sm3 -verify test-sm2.pub -signature sm3.txt.sig sm3.txt
evmctl ima_verify --sigfile --key test-sm2.pub sm3.txt


