#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
TAINT=$(kubectl get nodes -o jsonpath='{.items[0].spec.taints[0].key}')
if [ "$TAINT" == "node-role.kubernetes.io/control-plane" ]; then
  kubectl taint nodes --all node-role.kubernetes.io/control-plane-
fi
helm repo add nfs-subdir-external-provisioner	https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
helm repo update
helm install -n kube-system nfs-client nfs-subdir-external-provisioner/nfs-subdir-external-provisioner
