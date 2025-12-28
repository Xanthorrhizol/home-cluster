#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
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
pacman -S --noconfirm kubectl kubectx helm cilium-cli
pacman -S --noconfirm jq yq htmlq

if [ ! -d ~/.ssh ]; then
  mkdir ~/.ssh
fi

if [ ! -f ~/.ssh/cluster_ed25519 ]; then
  ssh-keygen -t ed25519 -f ~/.ssh/cluster_ed25519 -q -N ""
fi

utils/create-ssh-config.sh
if [ ! -f ~/.ssh/config ]; then
  cp ssh-config ~/.ssh/config
else
  echo "Insert ssh-config's content into your ~/.ssh/config"
  read -p -r "Press enter to continue if you are done"
fi

systemctl enable --now libvirtd

virsh net-define $KVM_NETWORK_XML_PATH
NET_NAME=$(cat $KVM_NETWORK_XML_PATH | grep '<name>' | cut -d '>' -f 2 | cut -d '<' -f 1)
virsh net-start $NET_NAME
virsh net-autostart $NET_NAME
