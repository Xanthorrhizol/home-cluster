#!/bin/bash
function usage() {
  echo "Usage: $0 <generated talosconfig path>"
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

talosctl bootstrap \
  --talosconfig $TALOSCONFIG_PATH \
  --nodes ${CONTROLPLANE_NODES[0]} \
  --endpoints $(echo ${CONTROLPLANE_IPS[@]} | tr ' ' ',')
