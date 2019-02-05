#!/bin/bash

set -euf
set -o pipefail

apt-get install unzip

CONSUL_VERSION=1.4.1
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

echo "Configuring Consul DNS services..."
cat > /etc/systemd/resolved.conf <<EOF
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.
#
# Entries in this file show the compile time defaults.
# You can change settings by editing this file.
# Defaults can be restored by simply deleting this file.
#
# See resolved.conf(5) for details

[Resolve]
DNS=127.0.0.1
#FallbackDNS=
Domains=~consul
#LLMNR=no
#MulticastDNS=no
#DNSSEC=no
#Cache=yes
#DNSStubListener=yes
EOF

# As per Consul documentation:
# https://www.consul.io/docs/guides/forwarding.html#systemd-resolved-setup
iptables -t nat -A OUTPUT -d localhost -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
iptables -t nat -A OUTPUT -d localhost -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600

# Persist those rules across reboots.
iptables-save | tee /etc/iptables.conf
cat > /etc/systemd/system/iptables-restore.service << EOF
[Unit]
Description=Restore iptables rules

[Service]
ExecStart=/sbin/iptables-restore < /etc/iptables.conf

[Install]
WantedBy=multi-user.target
EOF
systemctl enable iptables-restore.service

systemctl restart systemd-resolved.service

echo "Consul is now providing DNS for the 'consul.' domain."
echo
