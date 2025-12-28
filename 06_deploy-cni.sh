#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
source ./env

NODES=(${CONTROLPLANE_NODES[@]} ${WORKER_NODES[@]})

for NODE in ${NODES[@]}; do
  sleep 10
  ssh $NODE -C $" \
    mount --make-rshared /run/cilium/cgroupv2 && \
    mount --make-rshared /sys/fs/bpf && \
    mount --make-rslave /run && \
    rc-service containerd restart && \
    rc-service kubelet restart"
done

cilium-cli install --kubeconfig kubeconfig
