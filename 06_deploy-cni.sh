#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
