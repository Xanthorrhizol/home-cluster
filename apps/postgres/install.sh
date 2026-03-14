#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg cnpg/cloudnative-pg \
  -n database \
  --create-namespace

kubectl create secret generic db-credentials \
  -n database \
  --from-literal=username=admin \
  --from-literal=password='postgres' # Change these

sleep 30

kubectl apply -f pvc.yaml
kubectl apply -f cluster.yaml
kubectl label ns database gateway-access=true
kubectl apply -f tcp-route.yaml
