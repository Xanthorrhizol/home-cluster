#!/bin/bash
function usage() {
  echo "Usage: $0 <generated talosconfig-path> <virtual ip(vip)> <first controlplane ip>"
}

if [ "$#" -ne 3 ]; then
  usage
  exit 1
fi

if [ ! -f "$1" ]; then
  echo "Talosconfig file not found: $1"
  usage
  exit 1
fi

TALOSCONFIG_PATH=$1
VIP=$2
FIRST_CONTROL_PLANE_IP=$3
talosctl --talosconfig $TALOSCONFIG_PATH kubeconfig --endpoints=$FIRST_CONTROL_PLANE_IP --nodes=$FIRST_CONTROL_PLANE_IP  .

sed -i "s/$FIRST_CONTROL_PLANE_IP/$VIP/g" kubeconfig
