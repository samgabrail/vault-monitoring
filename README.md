# Overview

A guide to teach how to monitor HashiCorp Vault with Prometheus, Loki, and Grafana.

## Configure Vault

```bash
export VAULT_ADDR=http://127.0.0.1:8200
export LEARN_VAULT=/tmp/learn-vault-monitoring
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

