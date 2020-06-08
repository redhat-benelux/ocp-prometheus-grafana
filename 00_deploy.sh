export PrometheusNamespace=prometheus-standalone

cat <<EOF >prometheus.yml
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
          - ${PrometheusNamespace}
          - app-project1
          - app-project2

    - job_name: 'services'
      honor_labels: false
      kubernetes_sd_configs:
      - role: service
        namespaces:
          names:
          - app-project2

      relabel_configs:
      - source_labels: [__meta_kubernetes_service_annotation_example_io_should_be_scraped]
        action: keep
        regex: true

EOF



cat <<EOF >alertmanager.yml
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
EOF

cat <<EOF >rbac.yml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: prometheus-sd-role
rules:
  - apiGroups: [ "" ]
    resources: [ "services","endpoints","pods" ]
    verbs: [ "list","get", "watch" ]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: prometheus-sd-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: prometheus-sd-role
subjects:
- kind: ServiceAccount
  name: prom
  namespace: ${PrometheusNamespace}
EOF


oc new-project ${PrometheusNamespace}
oc new-project app-project1
oc new-project app-project2

oc project ${PrometheusNamespace}

oc create configmap prom-config --from-file=prometheus.yml -n ${PrometheusNamespace}

oc create configmap alert-config --from-file=alertmanager.yml -n ${PrometheusNamespace}

oc process -f prometheus-standalone.yaml | oc apply -f - -n ${PrometheusNamespace}

oc apply -f rbac.yml -n app-project1
oc apply -f rbac.yml -n app-project2
oc apply -f rbac.yml -n ${PrometheusNamespace}



# note this is for v4, please change it for v3, not need to change, also works under v3
export PROM_URL=$(oc get route prom -n ${PrometheusNamespace} -o 'jsonpath={.status.ingress[0].host}')

PROM_URL="https://${PROM_URL}"


oc process -f grafana.yaml -p NAMESPACE="${PrometheusNamespace}" | oc apply -f - -n ${PrometheusNamespace}


export GRAFANA_URL=$(oc get route grafana -n ${PrometheusNamespace} -o 'jsonpath={.status.ingress[0].host}')

GRAFANA_URL="https://${GRAFANA_URL}"

echo "Prometheus : ${PROM_URL}"

echo "Grafana : ${GRAFANA_URL}"

sleep 60 

oc exec $(oc get po -n ${PrometheusNamespace} -l app=grafana -o name) -c oauth-proxy -- curl -k -H 'Accept: application/json' -H 'Content-Type: application/json' \
-d '{"name":"Prometheus","type":"prometheus","url":"http://prometheus.'${PrometheusNamespace}'.svc.cluster.local:9090","access":"proxy","basicAuth":false}' \
-X POST "https://grafana.${PrometheusNamespace}.svc.cluster.local/api/datasources"

exit;
