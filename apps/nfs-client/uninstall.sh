#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
if [ $# -ne 1 ]; then 
  echo "Usage: $0 <storageClass-name>"
  exit 1
fi
helm uninstall -n kube-system $1
