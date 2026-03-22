#!/bin/bash
kubectl create secret generic pre-defined-secret \
   --namespace=arc-runners \
   --from-literal=github_app_id=123456 \
   --from-literal=github_app_installation_id=123456 \
   --from-literal=github_app_private_key='-----BEGIN RSA PRIVATE KEY-----*****'
