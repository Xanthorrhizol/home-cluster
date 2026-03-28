#!/bin/bash
set -e
cd "$(dirname "$(readlink -f "$0")")"

function usage() {
  echo "Usage: $0 <IMAGE>"
  echo ""
  echo "  IMAGE       Required. Image and tag. Recommended registry: ghcr.io (e.g. ghcr.io/xanthorrhizol/claude-code:latest)"
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

IMAGE=$1

docker build -t "$IMAGE" .

echo "Built: $IMAGE"
