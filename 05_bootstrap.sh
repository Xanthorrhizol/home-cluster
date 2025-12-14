#!/bin/bash
function usage() {
  echo "Usage: $0 <generated talosconfig path> <virtual ip(vip)> <first controlplane ip>"
}

if [ "$#" -ne 3 ]; then
  usage
  exit 1
fi

TALOSCONFIG_PATH=$1
VIP=$2
FIRST_CONTROL_PLANE_IP=$3

talosctl bootstrap --talosconfig $TALOSCONFIG_PATH --endpoints $VIP --nodes $FIRST_CONTROL_PLANE_IP
