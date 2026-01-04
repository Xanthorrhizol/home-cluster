#!/bin/bash
function usage() {
  echo "Usage: $0 <generated talosconfig-path>"
}

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

if [ ! -f "$1" ]; then
  echo "Talosconfig file not found: $1"
  usage
  exit 1
fi

cd $(dirname "$(readlink -f "$0")")
source ../env

TALOSCONFIG_PATH=$1
talosctl --talosconfig $TALOSCONFIG_PATH kubeconfig --endpoints=${CONTROLPLANE_IPS[0]} --nodes=${CONTROLPLANE_IPS[0]}  .

sed -i "s/${CONTROLPLANE_IPS[0]}/$VIRTUAL_IP/g" kubeconfig
