#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
kubectl delete -f gateway.yaml
kubectl delete -f gateway-class.yaml

helm uninstall eg
