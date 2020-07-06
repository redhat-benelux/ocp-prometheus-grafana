#!/usr/bin/env bash

source ./project.env

oc new-app amq-broker-76-basic -p AMQ_ENABLE_METRICS_PLUGIN=true -n ${APP_PROJECT_B}

oc patch svc broker-amq-jolokia -p '{"metadata":{"annotations":{"${ANNOTATION_SCRAPE}":"true"}}}' -n ${APP_PROJECT_B}


