#!/bin/bash
curl -sL https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml \
  | sed '/- --metric-resolution/a\        - --kubelet-insecure-tls' \
  | kubectl apply -n kube-system -f -
