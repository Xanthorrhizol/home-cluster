#!/bin/bash
set -e
cd "$(dirname "$(readlink -f "$0")")"

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --values values.yaml \
  --wait

sleep 10

kubectl apply -f httproute.yaml

kubectl label ns argocd gateway-access=true
