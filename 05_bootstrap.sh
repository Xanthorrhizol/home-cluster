#!/bin/bash
function usage() {
  echo "Usage: $0 <generated talosconfig path> <first controlplane ip>"
}

if [ "$#" -ne 2 ]; then
  usage
  exit 1
fi

if [ ! -f "$1" ]; then
  echo "Talosconfig file not found: $1"
  usage
  exit 1
fi

TALOSCONFIG_PATH=$1
FIRST_CONTROL_PLANE_IP=$2

talosctl bootstrap --talosconfig $TALOSCONFIG_PATH --endpoints $FIRST_CONTROL_PLANE_IP --nodes $FIRST_CONTROL_PLANE_IP
