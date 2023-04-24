api_addr  = "http://127.0.0.1:8209"

listener "tcp" {
  address     = "0.0.0.0:8209"
  tls_disable = "true"
}

storage "file" {
  path = "/vault/data"
}

telemetry {
  disable_hostname = true
  prometheus_retention_time = "12h"
}