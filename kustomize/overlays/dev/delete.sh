#!/usr/bin/env bash

#oc delete -k ./


kustomize build | oc delete -f -
