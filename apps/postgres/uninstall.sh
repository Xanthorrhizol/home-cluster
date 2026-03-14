#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
kubectl delete -f cluster.yaml
kubectl delete -f pvc.yaml
kubectl delete -f tcp-route.yaml
kubectl delete secret -n database db-credentials
helm uninstall cnpg -n database
kubectl label ns database gateway-access-
