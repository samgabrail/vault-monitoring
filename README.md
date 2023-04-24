# Overview

A guide to teach how to monitor HashiCorp Vault with Prometheus, Loki, and Grafana.

## Configure Vault

### Initialize and Unseal Vault

```bash
vault server -config=/workspaces/vault-monitoring/vault/config/server.hcl
export VAULT_ADDR=http://127.0.0.1:8200
export LEARN_VAULT=/tmp/learn-vault-monitoring
mkdir -p /tmp/learn-vault-monitoring
vault operator init -key-shares=1 -key-threshold=1 | head -n3 | cat > $LEARN_VAULT/.vault-init
vault operator unseal $(grep 'Unseal Key 1' $LEARN_VAULT/.vault-init | awk '{print $NF}')
vault login -no-print $(grep 'Initial Root Token' $LEARN_VAULT/.vault-init | awk '{print $NF}')
```

### Create a Vault Policy for Prometheus

```bash
vault policy write prometheus-metrics - << EOF
path "/sys/metrics" {
  capabilities = ["read"]
}
EOF
```

### Create a Vault Token For Prometheus

```bash
vault token create \
  -field=token \
  -policy prometheus-metrics \
  > prometheus/prometheus-token
```

### Enable Audit Logs

```bash
vault audit enable file file_path=/var/log/vault-audit.log
```




apk add wget
wget https://github.com/grafana/loki/releases/download/v2.8.0/promtail-linux-amd64.zip

