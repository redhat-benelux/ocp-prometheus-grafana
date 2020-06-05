#!/usr/bin/env bash

set -x


oc create cm prom-config  --from-file=prometheus.yml=prometheus-config.yml

oc create cm alert-config  --from-file=alertmanager.yml=alertmanager-config.yml


oc process -f prometheus-standalone.yaml | oc apply -f -


