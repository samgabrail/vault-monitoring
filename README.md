# Overview

A guide to teach how to monitor HashiCorp Vault with Prometheus, Loki, and Grafana.

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

