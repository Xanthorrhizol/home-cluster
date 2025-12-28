#!/bin/bash
source ./env

if [ ! -d pki ]; then
  mkdir pki
fi
# Root CA private key
openssl genrsa -out pki/rootCA.key 4096
chmod 600 pki/rootCA.key

# Root CA certificate (10년)
openssl req -x509 -new -nodes -key pki/rootCA.key -sha256 -days 3650 \
  -subj "/C=KR/O=HomeCluster/OU=PKI/CN=HomeCluster Root CA" \
  -out pki/rootCA.crt

# Server private key
openssl genrsa -out pki/haproxy.key 2048
chmod 600 pki/haproxy.key

# CSR
openssl req -new -key pki/haproxy.key \
  -subj "/C=KR/O=HomeCluster/OU=Edge/CN=$DOMAIN" \
  -out pki/haproxy.csr

cat << EOF > pki/haproxy-san.ext 
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage=digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName=@alt_names

[alt_names]
DNS.1=*.$DOMAIN
IP.1=10.1.0.1
EOF

openssl x509 -req -in pki/haproxy.csr \
  -CA pki/rootCA.crt -CAkey pki/rootCA.key -CAcreateserial \
  -out pki/haproxy.crt -days 825 -sha256 \
  -extfile pki/haproxy-san.ext

cat pki/haproxy.crt pki/rootCA.crt pki/haproxy.key > pki/$DOMAIN.pem
chmod 600 pki/$DOMAIN.pem
