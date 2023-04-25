# Overview

A guide to teach how to monitor HashiCorp Vault with Prometheus, Loki, and Grafana.

Run the startup script:

```bash
./startup_script.sh
```

Once the script is done, run the following:
```bash
export VAULT_ADDR=http://127.0.0.1:8200
export LEARN_VAULT=/workspaces/vault-monitoring/vault/
vault login -no-print $(grep 'Initial Root Token' $LEARN_VAULT/.vault-init | awk '{print $NF}')
```

## Grafana Dashboards

Import the `vault.json` dashboard located in the folder `grafana/provisioning/dashboards` into Grafana.

Create a couple of panels for logs. One for System logs and the other for Audit logs.

## Testing

To test logs run the following

```bash
vault secrets enable kv
for i in {1..50}
  do
    printf "."
    vault kv put kv/$i-secret-50 id="${i+10}" >/dev/null 2>&1
done
```

Create some tokens:

```bash
for i in {1..50}
  do
    printf "."
    vault token create -policy=default >/dev/null 2>&1
done
```

Attempt to login multiple times with errors:

```bash
for i in {1..50}
  do
    printf "."
    vault login \
      -method=userpass \
      username=learner \
      password=vtl-password >/dev/null 2>&1
done
```