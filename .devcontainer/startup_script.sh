#!/usr/bin/env bash
mkdir -p /workspaces/vault-monitoring/vault/logs/
touch /workspaces/vault-monitoring/vault/logs/vault.log
vault server -config=/workspaces/vault-monitoring/vault/config/server.hcl > /workspaces/vault-monitoring/vault/logs/vault.log 2>&1 &
export VAULT_ADDR=http://127.0.0.1:8200
export LEARN_VAULT=/tmp/learn-vault-monitoring
mkdir -p /tmp/learn-vault-monitoring
sleep 5
vault operator init -key-shares=1 -key-threshold=1 | head -n3 | cat > $LEARN_VAULT/.vault-init
sleep 10
vault operator unseal $(grep 'Unseal Key 1' $LEARN_VAULT/.vault-init | awk '{print $NF}')
sleep 5
vault login -no-print $(grep 'Initial Root Token' $LEARN_VAULT/.vault-init | awk '{print $NF}')

### Create a Vault Policy for Prometheus

vault policy write prometheus-metrics - << EOF
path "/sys/metrics" {
  capabilities = ["read"]
}
EOF

### Create a Vault Token For Prometheus

vault token create \
  -field=token \
  -policy prometheus-metrics \
  > /workspaces/vault-monitoring/prometheus/prometheus-token

### Enable Audit Logs
sleep 5
vault audit enable file file_path=/workspaces/vault-monitoring/vault/logs/vault-audit.log

### Start the Monitoring stack

docker compose up -d