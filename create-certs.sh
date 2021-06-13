#!/usr/bin/bash

set -o nounset \
    -o errexit \
    -o verbose \
    -o xtrace

openssl req -new -x509 -days 3650 -nodes -text -out server-cert.pem \
  -keyout server-key.pem -subj "/CN=localhost"

chmod og-rwx server-key.pem

openssl req -new -nodes -text -out root.csr \
  -keyout root-key.pem -subj "/CN=localhost"
chmod og-rwx root-key.pem

openssl req -new -nodes -text -out server.csr \
  -keyout server-key-signed.pem -subj "/CN=localhost"
chmod og-rwx server-signed.key

openssl x509 -req -in server.csr -text -days 3650 \
  -CA root-cert.pem -CAkey root-key.pem -CAcreateserial \
  -out server-cert-signed.pem
