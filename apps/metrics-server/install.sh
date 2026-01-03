#!/bin/bash
kubectl apply -n kube-system -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
