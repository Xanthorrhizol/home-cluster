#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.1/standard-install.yaml
kubectl apply --server-side -f https://github.com/envoyproxy/gateway/releases/download/v1.6.1/install.yaml
kubectl apply -f gateway-class.yaml
kubectl apply -f gateway.yaml
