#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
if [ $# -ne 4 ]; then 
  echo "Usage: $0 <nfs-server-ip> <nfs-dir> <reclaimPolicy> <storageClass-name>"
  exit 1
fi

#TAINT=$(kubectl get nodes -o jsonpath='{.items[0].spec.taints[0].key}')
#if [ "$TAINT" == "node-role.kubernetes.io/control-plane" ]; then
#  kubectl taint nodes --all node-role.kubernetes.io/control-plane-
#fia

helm repo add nfs-subdir-external-provisioner	https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
helm repo update
helm install -n kube-system $4 nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=$1 --set nfs.path=$2 --set nfs.reclaimPolicy=$3 --set storageClass.name=$4
