#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.1/standard-install.yaml
kubectl delete -f https://github.com/envoyproxy/gateway/releases/download/v1.6.1/install.yaml
kubectl delete -f gateway-class.yaml
kubectl delete -f gateway.yaml
