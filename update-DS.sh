#!/usr/bin/env bash

# Huub check the new addition i added to 00_deploy.sh it go through the Pod to create the DS so no need for any API Key.
curl --insecure -H "Content-Type: application/json" -u admin -p "https://grafana-prometheus-standalone.192.168.99.110.nip.io/api/datasources" -X POST -d "@test-oauth.json"

