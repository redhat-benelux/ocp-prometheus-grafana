#!/usr/bin/env bash

curl --insecure -H "Content-Type: application/json" -u admin -p "https://grafana-prometheus-standalone.192.168.99.110.nip.io/api/datasources" -X POST -d "@test-oauth.json"

