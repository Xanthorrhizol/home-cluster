#!/bin/bash
cd $(dirname "$(readlink -f "$0")")

source ./env
NODES=(${CONTROLPLANE_NODES[@]} ${WORKER_NODES[@]})
for NODE in ${NODES[@]}; do
  ssh $NODE -C $" \
    apk add cni-plugins && \
    if [ ! -d /opt/cni/bin ]; then mkdir -p /opt/cni/bin; fi && \
    ln -s /usr/libexec/cni/* /opt/cni/bin/"
done

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
