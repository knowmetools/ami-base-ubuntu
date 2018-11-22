#!/bin/bash

set -euf
set -o pipefail

apt-get install unzip

CONSUL_VERSION=1.4.0
CONSUL_LINK=https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip

echo "Downloading Consul..."
wget ${CONSUL_LINK} -O /tmp/consul.zip --quiet
echo "Finished download."
echo

echo "Unzipping Consul binary..."
unzip /tmp/consul.zip -d /tmp
chmod +x /tmp/consul
mv /tmp/consul /usr/local/bin
echo "Extracted Consul binary to '/usr/local/bin/consul'."
echo

echo "Creating consul user..."
useradd --shell /bin/false --system --user-group consul
echo "Created user 'consul'."
echo

echo "Creating directory structure..."
mkdir -p /opt/consul/config
mkdir -p /opt/consul/data
chown -R consul:consul /opt/consul
cat <<EOF
Consul Directories:
    Config: /opt/consul/config
    Data: /opt/consul/data

EOF

echo "Creating initial configuration file..."
cat > /opt/consul/config/base.hcl <<EOF
data_dir = "/opt/consul/data"
EOF
echo "Wrote to /opt/consul/config/base.hcl"
echo

echo "Creating systemd unit file..."
cat > /etc/systemd/system/consul.service <<EOF
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=/opt/consul/config
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable consul.service
echo "Wrote and enabled /etc/systemd/system/consul.service"
echo
