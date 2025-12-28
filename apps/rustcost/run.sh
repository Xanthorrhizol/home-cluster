#!/bin/bash
cd $(dirname '$(readlink -f "$0")')
if [ $(helm repo list | grep rustcost | wc -l) -eq 0 ]; then
  helm repo add rustcost https://rustcost.github.io/rustcost-helmchart
fi
helm repo update
if [ $(kubectl get ns rustcost | grep rustcost | wc -l) -lt 1 ]; then
  kubectl create ns rustcost
fi
if [ $(helm list -n rustcost | grep rustcost | wc -l) -lt 1 ]; then
  helm upgrade --install -n rustcost rustcost rustcost/rustcost -f values.yaml
else 
  helm install -n rustcost rustcost rustcost/rustcost -f values.yaml
fi
