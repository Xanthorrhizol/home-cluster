#!/bin/bash
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.1/standard-install.yaml
kubectl apply -f https://github.com/envoyproxy/gateway/releases/download/v1.6.1/install.yaml
