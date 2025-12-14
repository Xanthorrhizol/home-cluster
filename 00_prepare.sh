#!/bin/bash
function usage() {
  echo "Usage: $0 <kvm network xml path>"
}

function validate() {
  if [ ! -f $1 ]; then
    echo "$1 does not exist"
    usage
    exit 1
  fi
}

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

KVM_NETWORK_XML_PATH=$1

pacman -S --noconfirm virt-install libvirt virt-viewer dnsmasq
pacman -S --noconfirm talosctl kubectl kubectx

systemctl enable --now libvirtd

virsh net-define $KVM_NETWORK_XML_PATH
NET_NAME=$(cat $KVM_NETWORK_XML_PATH | grep '<name>' | cut -d '>' -f 2 | cut -d '<' -f 1)
virsh net-start $NET_NAME
virsh net-autostart $NET_NAME
