#!/usr/bin/env bash
export vault_version=1.13.1
# install packages

curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update
apt-get install -y vault=${vault_version}-* awscli jq

echo "Configuring system time"
timedatectl set-timezone UTC

# removing any default installation files from /opt/vault/tls/
rm -rf /opt/vault/tls/*

# /opt/vault/tls should be readable by all users of the system
chmod 0755 /opt/vault/tls

# vault-key.pem should be readable by the vault group only
touch /opt/vault/tls/vault-key.pem
chown root:vault /opt/vault/tls/vault-key.pem
chmod 0640 /opt/vault/tls/vault-key.pem

cat << EOF > /etc/vault.d/vault.hcl
ui = true
disable_mlock = true

storage "raft" {
  path    = "/opt/vault/data"
  node_id = "node1"
}

cluster_addr = "https://127.0.0.1:8201"
api_addr = "https://127.0.0.1:8200"

listener "tcp" {
  address            = "0.0.0.0:8200"
  tls_disable        = true
  telemetry {
    unauthenticated_metrics_access = true
  }
}

telemetry {
  unauthenticated_metrics_access = true
  prometheus_retention_time = "1h"
  disable_hostname = true
}

EOF

# vault.hcl should be readable by the vault group only
chown root:root /etc/vault.d
chown root:vault /etc/vault.d/vault.hcl
chmod 640 /etc/vault.d/vault.hcl

# Add monitoring to a static file for DataDog to pick up
touch /var/log/vault-audit.log
chmod 644 /var/log/vault-audit.log
chown vault:vault /var/log/vault-audit.log
touch /var/log/vault.log
chmod 644 /var/log/vault.log
chown vault:vault /var/log/vault.log

sed -i 's|^ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl$|ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl -log-level="trace"|' /lib/systemd/system/vault.service
sed -i '/^\[Service\]$/a StandardOutput=append:/var/log/vault.log\nStandardError=append:/var/log/vault.log' /lib/systemd/system/vault.service

# Add Log Rotate to rotate log files
apt install logrotate -y

cat << EOF > /etc/logrotate.d/vault-audit.log
/var/log/vault-audit.log {
rotate 7
daily
size 1G
#Do not execute rotate if the log file is empty.
notifempty
missingok
compress
#Set compress on next rotate cycle to prevent entry loss when performing compression.
delaycompress
copytruncate
extension log
dateext
dateformat %Y-%m-%d.
}
EOF

cat << EOF > /etc/logrotate.d/vault.log
/var/log/vault.log {
rotate 7
daily
size 1G
#Do not execute rotate if the log file is empty.
notifempty
missingok
compress
#Set compress on next rotate cycle to prevent entry loss when performing compression.
delaycompress
copytruncate
extension log
dateext
dateformat %Y-%m-%d.
}
EOF

systemctl enable vault
systemctl start vault