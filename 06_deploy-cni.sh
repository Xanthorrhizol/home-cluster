#!/bin/bash
cd $(dirname "$(readlink -f "$0")")

source ./env
NODES=(${CONTROLPLANE_NODES[@]} ${WORKER_NODES[@]})
for NODE in ${NODES[@]}; do
  ssh $NODE -C $" \
    mount --make-shared /sys && \
    mount --make-shared /run"
  if [ $NODE == $GPU_NODE ]; then
    ssh $NODE -C $" \
      update-alternatives --set iptables /usr/sbin/iptables-legacy; \
      update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy; \
      update-alternatives --set arptables /usr/sbin/arptables-legacy || true; \
      update-alternatives --set ebtables /usr/sbin/ebtables-legacy || true"
  fi
done

kubectl apply -f  https://raw.githubusercontent.com/projectcalico/calico/v3.31.3/manifests/canal.yaml
