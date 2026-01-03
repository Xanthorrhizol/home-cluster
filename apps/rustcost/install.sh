#!/bin/bash
cd $(dirname '$(readlink -f "$0")')
function usage() {
  echo "Usage: $0 <gpuExporter.enabled(true|false)> <httproute.enabled(true|false)> {persistence.storageClass | null}"
}
if [ $# -lt 1 ]; then
  usage
  exit 1
fi
GPU_EXPORTER_ENABLED=$1
HTTP_ROUTE=$2
STORAGE_CLASS=$3
case "$GPU_EXPORTER_ENABLED" in
  true|false)
    ;;
  *)
    usage
    exit 1
    ;;
esac

case "$HTTP_ROUTE" in
  true|false)
    ;;
  *)
    usage
    exit 1
    ;;
esac

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

if [ "$HTTP_ROUTE" == "true" ]; then
  if [ ! -f http-route.yaml ]; then
    ./create-http-route.sh
  fi
  kubectl apply -f http-route.yaml
fi
