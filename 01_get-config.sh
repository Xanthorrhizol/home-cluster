#!/bin/bash
RUN_DT=$(date +%Y%m%d%H%M%S)
mkdir config-$RUN_DT
cd config-$RUN_DT 
CURRENT_DIR=$(pwd)

CONTROL_PLANE_IP=("10.0.2.1/18" "10.0.2.2/18" "10.0.2.3/18")
WORKER_IP=("10.0.3.1/18" "10.0.3.2/18")
CLUSTER_NAME=k8s-cluster
NODE_PREFIX="k8s"
ENDPOINT="10.0.2.0/18" # Virtual IP of the cluster
GW_IP="10.0.0.1"
NAMESERVER_IP="10.0.1.1"

# create talos secrets
INITIAL_CONTROL_PLANE_IP=$(echo ${CONTROL_PLANE_IP[0]} | cut -d '/' -f 1)
talosctl gen secrets -o secrets.yaml
talosctl gen config --with-secrets $CURRENT_DIR/secrets.yaml $CLUSTER_NAME https://$INITIAL_CONTROL_PLANE_IP:6443

# create controlplane configs
for I in $(seq 1 ${#CONTROL_PLANE_IP[@]}); do
    TARGET_DIR=$CURRENT_DIR/controlplane-$I
    IP=${CONTROL_PLANE_IP[$(($I - 1))]}
    PATCH_FILENAME=controlplane-patch-$I.yaml
        cat << EOF > $PATCH_FILENAME
# controlplane-patch-$I file
machine:
  network:
    hostname: $NODE_PREFIX-cp-$I.server.xanthorrhizol.local
    interfaces:
      - interface: ens2  # From control plane node
        dhcp: false
        addresses:
          - $IP
        routes:
          - network: 0.0.0.0/0
            gateway: $GW_IP
        mtu: 1500
        vip:
          ip: $ENDPOINT
    nameservers:
      - ${NAMESERVER_IP}
EOF
    mkdir -p $TARGET_DIR
    talosctl machineconfig patch controlplane.yaml --patch @controlplane-patch-$I.yaml --output $TARGET_DIR/machineconfig.yaml
    rm $PATCH_FILENAME
done

# create worker configs
for I in $(seq 1 ${#WORKER_IP[@]}); do
    TARGET_DIR=$CURRENT_DIR/worker-$I
    IP=${WORKER_IP[$(($I - 1))]}
    PATCH_FILENAME=worker-patch-$I.yaml
        cat << EOF > $PATCH_FILENAME
# worker-patch-$I file
machine:
  network:
    hostname: $NODE_PREFIX-w-$I.server.xanthorrhizol.local
    interfaces:
      - interface: ens2  # From control plane node
        dhcp: false
        addresses:
          - $IP
        routes:
          - network: 0.0.0.0/0
            gateway: $GW_IP
        mtu: 1500
    nameservers:
      - ${NAMESERVER_IP}
EOF
    mkdir -p $TARGET_DIR
    talosctl machineconfig patch worker.yaml --patch @worker-patch-$I.yaml --output $TARGET_DIR/machineconfig.yaml
    rm $PATCH_FILENAME
done
