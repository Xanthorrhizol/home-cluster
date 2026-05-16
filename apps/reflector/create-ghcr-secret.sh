#!/bin/bash
set -e

# Usage: ./create-ghcr-secret.sh <GITHUB_USERNAME> <GITHUB_PAT>
if [ $# -lt 2 ]; then
  echo "Usage: $0 <GITHUB_USERNAME> <GITHUB_PAT>"
  exit 1
fi

GITHUB_USERNAME=$1
GITHUB_PAT=$2

AUTH=$(echo -n "${GITHUB_USERNAME}:${GITHUB_PAT}" | base64 -w 0)
DOCKERCONFIG=$(echo -n "{\"auths\":{\"ghcr.io\":{\"auth\":\"${AUTH}\"}}}" | base64 -w 0)

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ghcr-secret
  namespace: argocd
  labels:
    ghcr-secret: "true"
  annotations:
    reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
    reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: ""
    reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
    reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: ""
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: ${DOCKERCONFIG}
EOF
