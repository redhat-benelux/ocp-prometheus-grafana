#!/usr/bin/env bash

set -x

MGMT_NAMESPACE=fuse-mgmt

DEV_NAMESPACE=fuse7

oc create cm prom-config --from-file=prometheus.yml=prometheus-config.yml -n ${MGMT_NAMESPACE}

oc create cm alert-config  --from-file=alertmanager.yml=alertmanager-config.yml -n ${MGMT_NAMESPACE}

oc adm policy add-role-to-user view system:serviceaccount:${MGMT_NAMESPACE}:prom -n ${DEV_NAMESPACE}


oc process -f prometheus-standalone.yaml | oc apply -n ${MGMT_NAMESPACE} -f -


