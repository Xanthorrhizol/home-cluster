#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
source ../env

kubectl label --overwrite node $GPU_NODE nvidia.com/gpu.present=true
kubectl apply -f runtimeclass-nvidia.yaml

if [ $(helm repo list | grep nvdp | wc -l) -eq 0 ]; then
  helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
fi
helm repo update
if [ $(helm list | grep nvidia-device-plugin | wc -l) -eq 0 ]; then
  helm install \
    -n kube-system nvidia-device-plugin nvdp/nvidia-device-plugin \
    --set runtimeClassName=nvidia \
    --set strategy=nvml
else
  helm upgrade \
    -n kube-system nvidia-device-plugin nvdp/nvidia-device-plugin \
    --set runtimeClassName=nvidia \
    --set strategy=nvml
fi

