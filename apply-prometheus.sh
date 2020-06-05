#!/usr/bin/env bash

set -x

NAMESPACE=prommie

DEV_NAMESPACE=fuse7

oc create cm prom-config  --from-file=prometheus.yml=prometheus-config.yml

oc create cm alert-config  --from-file=alertmanager.yml=alertmanager-config.yml

oc adm policy add-role-to-user view system:serviceaccount:${NAMESPACE}:prom -n ${DEV_NAMESPACE}


oc process -f prometheus-standalone.yaml | oc apply -n ${NAMESPACE} -f -


