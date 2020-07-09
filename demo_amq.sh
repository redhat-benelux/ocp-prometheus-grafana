#!/usr/bin/env bash

source ./project.env


oc create sa amq-service-account

mkdir certs
cd certs

echo "for the keystores use as password only 'password'."


keytool -genkey -alias broker -keyalg RSA -keystore broker.ks
# CN=broker, OU=infra, O=company, L=Utrecht, ST=Utrecht, C=NL

keytool -export -alias broker -keystore broker.ks -file broker_cert

keytool -genkey -alias client -keyalg RSA -keystore client.ks
# CN=client, OU=staff, O=company, L=Utrecht, ST=Utrecht, C=NL

keytool -import -alias broker -keystore client.ts -file broker_cert


oc create secret generic amq-app-secret --from-file=certs/broker.ks -n ${APP_PROJECT_B}
oc secrets link sa/amq-service-account secret/amq-app-secret -n ${APP_PROJECT_B}


oc process -f amq-broker-77-persistence-ssl.yaml -p AMQ_ENABLE_METRICS_PLUGIN=true -p AMQ_TRUSTSTORE_PASSWORD=password -p AMQ_KEYSTORE_PASSWORD=password | oc apply -f - -n ${APP_PROJECT_B}

oc patch svc broker-amq-jolokia -p '{"metadata":{"annotations":{"${ANNOTATION_SCRAPE}":"true"}}}' -n ${APP_PROJECT_B}


