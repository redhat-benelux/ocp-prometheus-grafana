#!/usr/bin/env bash

#oc apply -k .

kustomize build | oc apply -f -