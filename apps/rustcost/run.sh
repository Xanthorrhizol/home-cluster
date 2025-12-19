#!/bin/bash
if [ $(helm repo list | grep rustcost | wc -l) -gt 0 ]; then
  helm repo add rustcost https://rustcost.github.io/rustcost-helmchart
fi
helm repo update
if [ $(kubectl get ns rustcosta | grep rustcost | wc -l) -lt 1 ]; then
  kubectl create ns rustcost
fi
helm install -n rustcost rustcost rustcost/rustcost
