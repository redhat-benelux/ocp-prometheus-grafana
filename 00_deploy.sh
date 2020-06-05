export PrometheusNamespace=prometheus-standalone

oc new-project ${PrometheusNamespace}
oc new-project app-project1
oc new-project app-project2

oc project ${PrometheusNamespace}

cat <<EOF >>prometheus.yml
global:
  scrape_interval: 30s
  evaluation_interval: 5s

scrape_configs:
    - job_name: prom-sd
      scrape_interval: 30s
      scrape_timeout: 10s
      metrics_path: /metrics
      scheme: http
      kubernetes_sd_configs:
      - api_server: null
        role: endpoints
        namespaces:
          names:
          - prometheus-project
          - app-project1
          - app-project2
EOF

oc create secret generic prom --from-file=prometheus.yml -n ${PrometheusNamespace}

cat <<EOF >>alertmanager.yml
global:
  resolve_timeout: 5m
  smtp_from: "admin@example.com"
  smtp_smarthost: "smtp.mailtrap.io:2525"
  smtp_auth_username: "b7b84fc3e5d118"
  smtp_auth_password: "445836087a81f3"
  smtp_require_tls: false
route:
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 12h
  receiver: default
  routes:
  - match:
      alertname: Watchdog
    repeat_interval: 5m
    receiver: Watchdog
receivers:
- name: default
- name: Watchdog
- name: email
  email_configs:
    - to: "rahmed@redhat.com"
      # TLS configuration.
      tls_config:
        insecure_skip_verify: True
EOF

oc create secret generic prom-alerts --from-file=alertmanager.yml -n ${PrometheusNamespace}

oc process -f prometheus-standalone.yaml | oc apply -f - -n ${PrometheusNamespace}

