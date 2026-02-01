#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
helm install eg oci://docker.io/envoyproxy/gateway-helm --version v1.6.3 -n envoy-gateway-system --create-namespace
kubectl wait --timeout=5m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available

kubectl apply -f gateway-class.yaml
kubectl apply -f gateway.yaml
