#!/bin/bash

set -euf
set -o pipefail

apt-get install unzip

VAULT_VERSION=1.0.2
VAULT_LINK=https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip

echo "Downloading Vault..."
wget ${VAULT_LINK} -O /tmp/vault.zip --quiet
echo "Finished download."
echo

echo "Unzipping Vault binary..."
unzip /tmp/vault.zip -d /tmp
chmod +x /tmp/vault
mv /tmp/vault /usr/local/bin
echo "Extracted Vault binary to '/usr/local/bin/vault'."
echo
