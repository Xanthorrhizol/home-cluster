#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
source ./env

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

FIRST_CONTROLPLANE_NODE=${CONTROLPLANE_NODES[0]}
echo "This is first controlplane node: ${FIRST_CONTROLPLANE_NODE}"
echo "Setup first controlplane node"
echo "The node will be copied to other controlplane nodes"
read -p "Press enter to continue"
utils/deploy-kvm.sh ${FIRST_CONTROLPLANE_NODE} \
  /var/lib/libvirt/images/${FIRST_CONTROLPLANE_NODE}.qcow2 \
  generic \
  ${CONTROLPLANE_CPUS} \
  ${CONTROLPLANE_MEM} \
  ${CONTROLPLANE_DISK} \
  ${OS_BOOT_ISO}

virsh destroy ${FIRST_CONTROLPLANE_NODE}

# from second, deploy kvms with created
for NODE in ${CONTROLPLANE_NODES[@]:1}; do
  echo "This is controlplane node: ${NODE}"
  echo "Change the hostname and network interface ip address"
  read -p "Press enter to continue"
  cp /var/lib/libvirt/images/${FIRST_CONTROLPLANE_NODE}.qcow2 /var/lib/libvirt/images/${NODE}.qcow2
  utils/deploy-kvm.sh ${NODE} \
    /var/lib/libvirt/images/${NODE}.qcow2 \
    generic \
    ${CONTROLPLANE_CPUS} \
    ${CONTROLPLANE_MEM} \
    ${CONTROLPLANE_DISK}

  virsh destroy ${NODE}
done

echo "This is first worker node: ${FIRST_WORKER_NODE}"
echo "Setup first worker node"
echo "The node will be copied to other worker nodes"
read -p "Press enter to continue"
FIRST_WORKER_NODE=${WORKER_NODES[0]}
utils/deploy-kvm.sh ${FIRST_WORKER_NODE} \
  /var/lib/libvirt/images/${FIRST_WORKER_NODE}.qcow2 \
  generic \
  ${WORKER_CPUS} \
  ${WORKER_MEM} \
  ${WORKER_DISK} \
  ${OS_BOOT_ISO}

virsh destroy ${FIRST_WORKER_NODE}

# from second, deploy kvms with created
for NODE in ${WORKER_NODES[@]:1}; do
  echo "This is worker node: ${NODE}"
  echo "Change the hostname and network interface ip address"
  read -p "Press enter to continue"
  cp /var/lib/libvirt/images/${FIRST_WORKER_NODE}.qcow2 /var/lib/libvirt/images/${NODE}.qcow2
  utils/deploy-kvm.sh ${NODE} \
    /var/lib/libvirt/images/${NODE}.qcow2 \
    generic \
    ${WORKER_CPUS} \
    ${WORKER_MEM} \
    ${WORKER_DISK}

  virsh destroy ${NODE}
done

for NODE in ${CONTROLPLANE_NODES[@]}; do
  virsh start ${NODE}
done

for NODE in ${WORKER_NODES[@]}; do
  virsh start ${NODE}
done
