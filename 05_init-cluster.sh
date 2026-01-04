#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
source ./env

# prepare config files
cat <<EOF > k8s.conf
overlay
nf_conntrack
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
    apt update && \
    apt install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg \
      lsb-release \
      conntrack \
      iptables \
      ethtool \
      socat \
      ebtables \
      containerd && \
    mkdir -p /etc/containerd && \
    systemctl restart containerd && \
    systemctl enable containerd"
  ssh $NODE -C $" \
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | gpg --no-tty --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubelet kubeadm && \
    apt-mark hold kubelet kubeadm && \
    systemctl disable --now systemd-resolved && \
    unlink /etc/resolv.conf || true && \
    echo \"nameserver ${GW_IP}\" > /etc/resolv.conf && \
    systemctl enable --now kubelet"
  ssh $NODE -C $" \
    modprobe overlay
    modprobe br_netfilter
    modprobe nf_conntrack
    sysctl -p /etc/sysctl.d/99-kubernetes.conf"
  ssh $NODE -C $" \
    swapoff -a && \
    sed -i '/ swap / s/^/#/' /etc/fstab"
done

rm k8s.conf 99-kubernetes.conf
# init first controlplane node
FIRST_CONTROLPLANE_NODE=${CONTROLPLANE_NODES[0]}
ssh $FIRST_CONTROLPLANE_NODE -C $" \
  kubeadm init \
  --control-plane-endpoint=${CONTROLPLANE_ADDRESS}:6443 \
  --pod-network-cidr=10.244.0.0/16 \
  --service-cidr=10.245.0.0/16 \
  --apiserver-advertise-address=${CONTROLPLANE_IPS[0]} \
  --apiserver-bind-port=6443 \
  --apiserver-cert-extra-sans=${CONTROLPLANE_ADDRESS},${GW_IP},$(for N in ${CONTROLPLANE_NODES[@]}; do printf $N.server.$DOMAIN,; done)$(echo ${CONTROLPLANE_IPS[@]:1} | sed 's/ /,/g')"

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
    --certificate-key $CERT"
done

# init worker nodes
# worker
for NODE in ${WORKER_NODES[@]}; do
  ssh $NODE -C "$JOIN_COMMAND"
done
