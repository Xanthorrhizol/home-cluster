#!/bin/bash
function usage() {
  echo "Usage: $0 <schematic-id> <talos-linux version>"
}

cd $(dirname "$(readlink -f "$0")")
source ../env

SCHMATIC_ID=$1

if [ -z $SCHMATIC_ID ]; then
  echo "Semantic ID is required"
  usage
  exit 1
fi

RUN_DT=$(date +%Y%m%d%H%M%S)
mkdir config-$RUN_DT
cd config-$RUN_DT 
CURRENT_DIR=$(pwd)

CLUSTER_NAME=k8s-cluster

# create talos secrets
INITIAL_CONTROL_PLANE_IP=${CONTROLPLANE_IPS[0]}
talosctl gen secrets -o secrets.yaml
talosctl gen config --with-secrets $CURRENT_DIR/secrets.yaml $CLUSTER_NAME https://$INITIAL_CONTROL_PLANE_IP:6443 --install-image factory.talos.dev/installer/$SCHEMATIC_ID:$TALOS_LINUX_VERSION
sed -i '/grubUseUKICmdline/d' controlplane.yaml
sed -i '/grubUseUKICmdline/d' worker.yaml

# create controlplane configs
I=0
for NODE in ${CONTROLPLANE_NODES[@]}; do
  TARGET_DIR=$CURRENT_DIR/controlplane-$(($I + 1))
  NODE_IP=${CONTROLPLANE_IPS[$I]}
  NAS_NET_IP=${CONTROLPLANE_NAS_NET_IPS[$I]}
  PATCH_FILENAME=controlplane-patch-$(($I + 1)).yaml
  cat << EOF > $PATCH_FILENAME
machine:
  install:
    image: factory.talos.dev/installer/$SCHMATIC_ID:$TALOS_LINUX_VERSION
  network:
    interfaces:
      - interface: $TALOS_NIC
        dhcp: false
        addresses:
          - $NODE_IP/$CLUSTER_NET_SUBNET_BITS
        routes:
          - network: 0.0.0.0/0
            gateway: $GW_IP
        mtu: 1500
        vip:
          ip: $VIRTUAL_IP
      - interface: $TALOS_NIC_FOR_NAS
        dhcp: false
        addresses:
          - $NAS_NET_IP/$NAS_NET_SUBNET_BITS
    nameservers:
      - $GW_IP
cluster:
  apiServer:
    certSANs:
      - $VIRTUAL_IP
      - $CONTROLPLANE_ADDRESS
  network:
    cni:
      name: canal
      urls:
        - https://raw.githubusercontent.com/projectcalico/calico/v3.31.3/manifests/canal.yaml
    podSubnets:
      - 10.244.0.0/16
---
apiVersion: v1alpha1
kind: HostnameConfig
auto: "off"
hostname: $NODE.server.$DOMAIN
EOF
  mkdir -p $TARGET_DIR
  talosctl machineconfig patch controlplane.yaml --patch @controlplane-patch-$(($I + 1)).yaml --output $TARGET_DIR/machineconfig.yaml
  rm $PATCH_FILENAME
  I=$(($I + 1))
done

# create worker configs
I=0
for NODE in ${WORKER_NODES[@]}; do
  TARGET_DIR=$CURRENT_DIR/worker-$(($I + 1))
  NODE_IP=${WORKER_IPS[$I]}
  NAS_NET_IP=${WORKER_NAS_NET_IPS[$I]}
  PATCH_FILENAME=worker-patch-$(($I + 1)).yaml
  cat << EOF > $PATCH_FILENAME
machine:
  install:
    image: factory.talos.dev/installer/$SCHMATIC_ID:$TALOS_LINUX_VERSION
  network:
    interfaces:
      - interface: $TALOS_NIC  # From control plane node
        dhcp: false
        addresses:
          - $NODE_IP/$CLUSTER_NET_SUBNET_BITS
        routes:
          - network: 0.0.0.0/0
            gateway: $GW_IP
        mtu: 1500
      - interface: $TALOS_NIC_FOR_NAS
        dhcp: false
        addresses:
          - $NAS_NET_IP/$NAS_NET_SUBNET_BITS
    nameservers:
      - $GW_IP
  kernel:
    modules:
      - name: nvidia
      - name: nvidia_uvm
      - name: nvidia_drm
      - name: nvidia_modeset
  sysctls:
    net.core.bpf_jit_harden: 1
cluster:
  network:
    cni:
      name: canal
      urls:
        - https://raw.githubusercontent.com/projectcalico/calico/v3.31.3/manifests/canal.yaml
    podSubnets:
      - 10.244.0.0/16
---
apiVersion: v1alpha1
kind: HostnameConfig
auto: "off"
hostname: $NODE.server.$DOMAIN
EOF
  mkdir -p $TARGET_DIR
  talosctl machineconfig patch worker.yaml --patch @worker-patch-$(($I + 1)).yaml --output $TARGET_DIR/machineconfig.yaml
  rm $PATCH_FILENAME
  I=$(($I + 1))
done
