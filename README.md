# Overview

A guide to teach how to monitor HashiCorp Vault with Prometheus, Loki, and Grafana.

Run the startup script:

```bash
./startup_script.sh
```

## Testing

To test logs and rotation, you can generate some secrets:

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