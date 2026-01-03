#!/bin/bash
cd $(dirname "$(readlink -f "$0")")

source ./env
NODES=(${CONTROLPLANE_NODES[@]} ${WORKER_NODES[@]})
for NODE in ${NODES[@]}; do
  ssh $NODE -C $" \
    mount --make-shared /sys && \
    mount --make-shared /run"
done

kubectl apply -f  https://raw.githubusercontent.com/projectcalico/calico/v3.31.3/manifests/canal.yaml
