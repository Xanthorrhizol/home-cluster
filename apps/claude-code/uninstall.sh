#!/bin/bash
cd "$(dirname "$(readlink -f "$0")")"

function usage() {
  echo "Usage: $0 --env <keep|delete>"
  echo ""
  echo "  --env keep    Keep PVC and namespace so the next install reuses the same environment."
  echo "  --env delete  Also delete PVC and namespace (full cleanup)."
}

ENV_ACTION=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --env) ENV_ACTION=$2; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1"; usage; exit 1 ;;
  esac
done

if [[ "$ENV_ACTION" != "keep" && "$ENV_ACTION" != "delete" ]]; then
  usage
  exit 1
fi

kubectl delete -f manifests/httproute.yaml --ignore-not-found
kubectl delete -f manifests/service.yaml --ignore-not-found
kubectl delete -f manifests/deployment.yaml --ignore-not-found
kubectl delete secret claude-code-secret ghcr-secret -n claude-code --ignore-not-found

if [ "$ENV_ACTION" = "delete" ]; then
  kubectl delete -f manifests/pvc.yaml --ignore-not-found
  kubectl delete -f manifests/namespace.yaml --ignore-not-found
fi
