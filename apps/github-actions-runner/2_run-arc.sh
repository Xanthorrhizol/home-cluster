#!/bin/bash
NAMESPACE="arc-runners"
helm install arc \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    --set githubConfigSecret="pre-defined-secret" \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller
