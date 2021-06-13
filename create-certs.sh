#!/usr/bin/bash

set -o nounset \
    -o errexit \
    -o verbose \
    -o xtrace

if [ ! -d certs ]; then
  mkdir certs
fi

pushd certs

  echo "Creating server certificates"
  if [ ! -e server-key.pem ]; then
    openssl req -new -x509 -days 3650 -nodes -text -out server.crt \
      -keyout server-key.pem -subj "/CN=localhost"
    chmod og-rwx server-key.pem
  fi

  if [ ! -e root.csr & ! -e root-key.pem ]; then
    echo "Creating root key and signing request and root certificate"
    openssl req -new -nodes -text -out root.csr \
      -keyout root-key.pem -subj "/CN=localhost"
    chmod og-rwx root-key.pem
  fi

  if [ ! -e root.crt ]; then
    openssl x509 -req -in root.csr -text -days 3650 \
    -extfile /etc/ssl/openssl.cnf -extensions v3_ca \
    -signkey root-key.pem -out root.crt
  fi

  if [ ! -e server-key-signed.pem ]; then
    echo "Signing server key and certificate with CA"
    openssl req -new -nodes -text -out server.csr \
      -keyout server-key-signed.pem -subj "/CN=localhost"
    chmod og-rwx server-key-signed.pem
  fi

  if [ ! -e server-signed.crt ]; then
    openssl x509 -req -in server.csr -text -days 3650 \
      -CA root.crt -CAkey root-key.pem -CAcreateserial \
      -out server-signed.crt
  fi

popd
