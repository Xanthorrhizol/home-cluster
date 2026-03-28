#!/bin/bash
set -e
cd "$(dirname "$(readlink -f "$0")")"

function usage() {
  echo "Usage: $0 <GHCR_USER> <GHCR_TOKEN> <DOMAIN> <IMAGE> [TTYD_USER] [TTYD_PASS]"
  echo ""
  echo "  GHCR_USER   Required. GitHub username"
  echo "  GHCR_TOKEN  Required. GitHub PAT with read:packages scope."
  echo "  DOMAIN      Required. Domain for HTTPRoute (e.g. xanthorrhizol.local → claude.xanthorrhizol.local)"
  echo "  IMAGE       Required. Container image to deploy (e.g. ghcr.io/xanthorrhizol/claude-code:latest)"
  echo "  TTYD_USER   Optional. ttyd login user (default: claude)"
  echo "  TTYD_PASS   Optional. ttyd login password (auto-generated if omitted)"
}

if [ $# -lt 4 ]; then
  usage
  exit 1
fi

GHCR_USER=$1
GHCR_TOKEN=$2
DOMAIN=$3
IMAGE=$4
TTYD_USER=${5:-claude}
TTYD_PASS=${6:-$(openssl rand -base64 16 | tr -d '=+/' | head -c 20)}

kubectl apply -f manifests/namespace.yaml

kubectl create secret generic claude-code-secret \
  --from-literal=ttyd-user="$TTYD_USER" \
  --from-literal=ttyd-pass="$TTYD_PASS" \
  -n claude-code \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=xanthorrhizol \
  --docker-password="$GHCR_TOKEN" \
  -n claude-code \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f manifests/pvc.yaml
sed "s|image:.*|image: ${IMAGE}|" manifests/deployment.yaml | kubectl apply -f -
kubectl apply -f manifests/service.yaml
sed "s|claude.DOMAIN|claude.${DOMAIN}|" manifests/httproute.yaml | kubectl apply -f -

echo ""
echo "Deployed! Access at: http://claude.${DOMAIN}"
echo "  User: $TTYD_USER"
echo "  Pass: $TTYD_PASS"
