#!/bin/bash
kubectl delete -n kube-system -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
