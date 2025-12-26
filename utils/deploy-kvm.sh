#!/bin/bash
function usage_msg() {
  echo "Usage: deploy-kvm.sh <vm_name> <image_path> <os_variant> <vcpus> <memory> <disk_size> {iso_path}"
}

function check_user() {
  if [ "$EUID" -ne 0 ] && [ $(groups | grep libvirt-qemu | wc -l) -ne 1 ]; then
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

OVMF_CODE=/usr/share/OVMF/x64/OVMF_CODE.4m.fd
OVMF_VARS_TEMPLATE=/usr/share/OVMF/x64/OVMF_VARS.4m.fd

BOOTLOADER_PARAMS="loader=\"$OVMF_CODE\",loader.readonly=yes,loader.type=pflash,nvram_template=\"$OVMF_VARS_TEMPLATE\""

if [ $CPUS -gt 4 ]; then
  QUEUES=4
else
  QUEUES=1
fi
NETWORK_PARAMS="bridge=cluster-br0,model=virtio,driver_name=vhost,driver.queues=$QUEUES"
if [ ! -z $ISO ]; then
  virt-install \
    --name $NAME \
    --machine q35 \
    --ram $MEM \
    --vcpus $CPUS \
    --cpu host-passthrough \
    --boot $BOOTLOADER_PARAMS \
    --cdrom $ISO \
    --disk path=$IMAGE,size=$DISK \
    --graphics=none \
    --os-variant=$OS_VARIANT \
    --console pty,target_type=serial \
    --video none \
    --network $NETWORK_PARAMS
else
  virt-install \
    --name $NAME \
    --import \
    --machine q35 \
    --ram $MEM \
    --vcpus $CPUS \
    --cpu host-passthrough \
    --boot $BOOTLOADER_PARAMS \
    --disk path=$IMAGE,size=$DISK \
    --import \
    --graphics=none \
    --os-variant=$OS_VARIANT \
    --console pty,target_type=serial \
    --video none \
    --network $NETWORK_PARAMS
fi
