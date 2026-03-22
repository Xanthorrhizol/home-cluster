#!/bin/bash
NAMESPACE="arc-runners"
INSTALLATION_NAME="arc-runner-set"
GITHUB_CONFIG_URL="https://github.com/<org>/<repo>"
helm install "${INSTALLATION_NAME}" \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    --set githubConfigUrl="${GITHUB_CONFIG_URL}" \
    --set githubConfigSecret="pre-defined-secret" \
    --set containerMode.type="dind" \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

