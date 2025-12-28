#!/bin/bash
source ./env

cat << EOF > ssh-config
Host proxy
  HostName $PROXY_IP
  User root
  IdentityFile ~/.ssh/cluster_ed25519

$(i=0; for NODE in ${CONTROLPLANE_NODES[@]}; do echo "Host $NODE"; echo "  HostName ${CONTROLPLANE_IPS[i]}"; echo "  User root"; echo "  IdentityFile ~/.ssh/cluster_ed25519"; echo ""; ((i++)); done)

$(i=0; for NODE in ${WORKER_NODES[@]}; do echo "Host $NODE"; echo "  HostName ${WORKER_IPS[i]}"; echo "  User root"; echo "  IdentityFile ~/.ssh/cluster_ed25519"; echo ""; ((i++)); done)
EOF
