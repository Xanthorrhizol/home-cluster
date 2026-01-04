#!/bin/bash
if [ $(helm repo list | grep nvidia | wc -l) -eq 0 ]; then
  helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
  kubectl create ns gpu-operator
  kubectl label --overwrite ns gpu-operator pod-security.kubernetes.io/enforce=privileged
fi
helm repo update
if [ $(helm list | grep gpu-operator | wc -l) -eq 0 ]; then
  helm install --create-namespace -n gpu-operator gpu-operator nvidia/gpu-operator --set toolkit.enabled=true
else
  helm upgrade -n gpu-operator gpu-operator nvidia/gpu-operator --set toolkit.enabled=false
fi
