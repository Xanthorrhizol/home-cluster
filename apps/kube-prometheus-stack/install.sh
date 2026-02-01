#!/bin/bash
helm repo add kube-prometheus-stack https://prometheus-community.github.io/helm-charts
helm upgrade --create-namespace --install -n monitoring kube-prometheus-stack kube-prometheus-stack/kube-prometheus-stack -f values.yaml
