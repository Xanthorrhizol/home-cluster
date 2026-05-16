#!/bin/bash
set -e
cd "$(dirname "$(readlink -f "$0")")"

helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update

helm upgrade --install reflector emberstack/reflector \
  --namespace kube-system \
  --wait
