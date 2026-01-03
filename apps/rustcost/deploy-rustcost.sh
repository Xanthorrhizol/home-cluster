#!/bin/bash
cd $(dirname '$(readlink -f "$0")')
if [ $# -lt 1 ]; then
  echo "Usage: $0 <gpuExporter.enabled> {persistence.storageClass | null}"
  exit 1
fi
GPU_EXPORTER_ENABLED=$1
STORAGE_CLASS=$2

if [ "$STORAGE_CLASS" == "null" ]; then
  STORAGE_CLASS=""
else
  STORAGE_CLASS="--set persistence.storageClass=$STORAGE_CLASS"
fi

if [ $(helm repo list | grep rustcost | wc -l) -eq 0 ]; then
  helm repo add rustcost https://rustcost.github.io/rustcost-helmchart
fi
helm repo update
if [ $(kubectl get ns rustcost | grep rustcost | wc -l) -lt 1 ]; then
  kubectl create ns rustcost
fi
if [ $(helm list -n rustcost | grep rustcost | wc -l) -lt 1 ]; then
  helm upgrade --install -n rustcost rustcost rustcost/rustcost --set gpuExporter.enabled=$GPU_EXPORTER_ENABLED $STORAGE_CLASS
else 
  helm install -n rustcost rustcost rustcost/rustcost --set gpuExporter.enabled=$GPU_EXPORTER_ENABLED $STORAGE_CLASS
fi
