#!/bin/bash
set -e
cd "$(dirname "$(readlink -f "$0")")"

kubectl delete -f httproute.yaml --ignore-not-found

helm uninstall argocd --namespace argocd

kubectl delete namespace argocd --ignore-not-found
kubectl label ns argocd gateway-access-
