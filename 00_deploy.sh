#!/usr/bin/env bash

set -Eeuxo pipefail

trap "echo ERR trap fired!" ERR


source ./project.env

oc new-project ${MONITOR_PROJECT}
oc new-project ${APP_PROJECT_A}
oc new-project ${APP_PROJECT_B}

oc project ${MONITOR_PROJECT}

oc create configmap prom-config --from-file=prometheus-config.yml  -n ${MONITOR_PROJECT}

oc create configmap alert-config --from-file=alertmanager-config.yml  -n ${MONITOR_PROJECT}

oc process -f prometheus-standalone.yaml | oc apply -f - -n ${MONITOR_PROJECT}

oc apply -f rbac.yml -n ${APP_PROJECT_A}
oc apply -f rbac.yml -n ${APP_PROJECT_B}
oc apply -f rbac.yml -n ${MONITOR_PROJECT}



PROM_URL=$(oc get route prom -n ${MONITOR_PROJECT} -o 'jsonpath={"https://"}{.status.ingress[0].host}')

oc process -f grafana.yaml -p NAMESPACE="${MONITOR_PROJECT}" | oc apply -f - -n ${MONITOR_PROJECT}

GRAFANA_URL=$(oc get route grafana -n ${MONITOR_PROJECT} -o 'jsonpath={"https://"}{.status.ingress[0].host}')

echo "Prometheus : https://${PROM_URL}"

echo "Grafana : https://${GRAFANA_URL}"

sleep 60 

oc exec $(oc get po -n ${MONITOR_PROJECT} -l app=grafana -o name) -c oauth-proxy -- curl -k -H 'Accept: application/json' -H 'Content-Type: application/json' \
-d '{"name":"Prometheus","type":"prometheus","url":"https://prometheus.'${MONITOR_PROJECT}'.svc.cluster.local:9090","access":"proxy","basicAuth":false}' \
-X POST "https://grafana.${MONITOR_PROJECT}.svc.cluster.local/api/datasources"


