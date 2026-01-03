#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
source ../../env

ssh $GPU_NODE -C $" \
  mount --make-shared / && \
  mount --make-shared /run"

if [ $(helm repo list | grep nvidia | wc -l) -eq 0 ]; then
  helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
  kubectl create ns gpu-operator
  kubectl label --overwrite ns gpu-operator pod-security.kubernetes.io/enforce=privileged
fi
helm repo update
if [ $(helm list | grep gpu-operator | wc -l) -eq 0 ]; then
  helm install --create-namespace -n gpu-operator gpu-operator nvidia/gpu-operator
else
  helm upgrade -n gpu-operator gpu-operator nvidia/gpu-operator
fi
