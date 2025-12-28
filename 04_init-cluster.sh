#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
source ./env

# prepare config files
cat <<EOF > k8s.conf
overlay
br_netfilter
EOF
cat <<EOF > 99-kubernetes.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# install dependencies
NODES=(${CONTROLPLANE_NODES[@]} ${WORKER_NODES[@]})
for NODE in ${NODES[@]}; do
  scp k8s.conf $NODE:/etc/modules-load.d/k8s.conf
  scp 99-kubernetes.conf $NODE:/etc/sysctl.d/99-kubernetes.conf
  ssh $NODE -C $" \
    apk update && apk add \
      containerd \
      iptables \
      ip6tables \
      ethtool \
      socat \
      conntrack-tools \
      ebtables \
      curl \
      ca-certificates \
      bash \
      util-linux \
      kubeadm \
      kubelet \
      cni-plugins \
      openrc"
  ssh $NODE -C $" \
    modprobe overlay
    modprobe br_netfilter
    sysctl -p /etc/sysctl.d/99-kubernetes.conf"
  ssh $NODE -C $" \
    swapoff -a && \
    sed -i '/ swap / s/^/#/' /etc/fstab && \
    rc-service containerd restart && \
    rc-update add containerd default && \
    rc-service kubelet restart && \
    rc-update add kubelet default && \
    containerd config default | sed 's/SystemdCgroup = true/SystemdCgroup = false/g' > /etc/containerd/config.toml && \
    rc-service containerd restart"
done

rm k8s.conf 99-kubernetes.conf

# init first controlplane node
FIRST_CONTROLPLANE_NODE=${CONTROLPLANE_NODES[0]}
ssh $FIRST_CONTROLPLANE_NODE -C $" \
  kubeadm init \
  --control-plane-endpoint=${CONTROLPLANE_ADDRESS}:6443 \
  --pod-network-cidr=10.244.0.0/16 \
  --service-cidr=10.245.0.0/16 \
  --cri-socket=unix:///run/containerd/containerd.sock \
  --apiserver-advertise-address=${CONTROLPLANE_IPS[0]} \
  --apiserver-bind-port=6443 \
  --apiserver-cert-extra-sans=${CONTROLPLANE_ADDRESS},${PROXY_IP},$(echo ${CONTROLPLANE_IPS[@]:1} | sed 's/ /,/g')"

# copy kubeconfig
scp $FIRST_CONTROLPLANE_NODE:/etc/kubernetes/admin.conf kubeconfig

# copy token
JOIN_COMMAND=$(ssh $FIRST_CONTROLPLANE_NODE -C "kubeadm token create --print-join-command")

# upload certs
CERT=$(ssh $FIRST_CONTROLPLANE_NODE -C "kubeadm init phase upload-certs --upload-certs | tail -1")

# init other controlplane nodes
# master
for NODE in ${CONTROLPLANE_NODES[@]:1}; do
  ssh $NODE -C $" \
    $JOIN_COMMAND \
    --control-plane \
    --certificate-key $CERT \
    --cri-socket=unix:///run/containerd/containerd.sock"
done

# init worker nodes
# worker
for NODE in ${WORKER_NODES[@]}; do
  ssh $NODE -C $" \
    $JOIN_COMMAND \
    --cri-socket=unix:///run/containerd/containerd.sock"
done
