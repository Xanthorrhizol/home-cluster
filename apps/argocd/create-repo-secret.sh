#!/bin/bash
set -e

# Usage: ./create-repo-secret.sh <GITHUB REPO URL> <GITHUB_USERNAME> <GITHUB_PAT>
if [ $# -lt 2 ]; then
  echo "Usage: $0 <GITHUB REPO URL> <GITHUB_USERNAME> <GITHUB_PAT>"
  exit 1
fi

GITHUB_REPO_URL=$1
GITHUB_USERNAME=$2
GITHUB_PAT=$3

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: home-argocd-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: ${GITHUB_REPO_URL}
  username: ${GITHUB_USERNAME}
  password: ${GITHUB_PAT}
EOF
