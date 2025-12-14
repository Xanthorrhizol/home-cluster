#!/bin/bash
function usage_msg() {
  echo "Usage: deploy-kvm.sh <vm_name> <image_path> <os_variant> <vcpus> <memory> <disk_size> {iso_path}"
}

function check_user() {
  if [ "$EUID" -ne 0 ] && [ $(groups | grep libvirt | wc -l) -ne 1 ]; then
    echo "Please run as root"
    exit 1
  fi
}

function validate() {
  NAME=$1
  IMAGE=$2
  OS_VARIANT=$3
  CPUS=$4
  MEM=$5
  DISK=$6
  if [ $# -eq 7 ]; then
    ISO=$7
  fi

  if [[ $ISO == "" ]] && [ ! -f $IMAGE ]; then
    echo "$IMAGE does not exist"
    usage_msg
    exit 1
  fi

  if [ $(echo $CPUS | grep -Eo '^[0-9]+$' | wc -l) -ne 1 ]; then
    echo "$CPUS is not a number"
    usage_msg
    exit 1
  fi

  if [ $(echo $MEM | grep -E '^[0-9]+$' | wc -l) -ne 1 ]; then
    echo "$MEM is not a number"
    usage_msg
    exit 1
  fi

  if [ $(echo $DISK | grep -E '^[0-9]+$' | wc -l) -ne 1 ]; then
    echo "$DISK is not a number"
    usage_msg
    exit 1
  fi

  if [ ! -z $ISO ] && [ ! -f $ISO ]; then
    echo "$ISO does not exist"
    usage_msg
    exit 1
  fi
}

if [ $# -lt 6 ]; then
  usage_msg
  exit 1
fi

set -euo pipefail
check_user

NAME=$1
IMAGE=$2
OS_VARIANT=$3
CPUS=$4
MEM=$5
DISK=$6
ISO=""
if [ $# -eq 7 ]; then
  ISO=$7
fi

validate $NAME $IMAGE $OS_VARIANT $CPUS $MEM $DISK $ISO

if [ ! -z $ISO ]; then
  virt-install \
    --name $NAME \
    --ram $MEM \
    --vcpus $CPUS \
    --cpu host-passthrough \
    --cdrom $ISO \
    --disk path=$IMAGE,size=$DISK \
    --graphics=vnc,password=1234 \
    --os-variant=$OS_VARIANT \
    --console pty,target_type=serial \
    --network bridge=cluster-br0,model=virtio,driver_name=vhost,driver.queues=4
else
  virt-install \
    --name $NAME \
    --ram $MEM \
    --vcpus $CPUS \
    --cpu host-passthrough \
    --disk path=$IMAGE,size=$DISK \
    --import \
    --graphics=none \
    --os-variant=$OS_VARIANT \
    --console pty,target_type=serial \
    --network bridge=cluster-br0,model=virtio,driver_name=vhost,driver.queues=4
fi
