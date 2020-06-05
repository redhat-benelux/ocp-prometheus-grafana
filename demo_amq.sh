#!/usr/bin/env bash

oc new-app amq-broker-76-basic -p AMQ_ENABLE_METRICS_PLUGIN=true -n app-project2

oc patch svc broker-amq-jolokia -p '{"metadata":{"annotations":{"example.io/should_be_scraped":"true"}}}' -n app-project2


