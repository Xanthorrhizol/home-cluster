#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
function usage() {
  echo "Usage: $0 <talosconfig path> <kubectl config path>"
}

if [ "$#" -ne 2 ]; then
  usage
  exit 1
fi

if [ ! -f "$1" ]; then
  echo "$1 does not exist"
  usage
  exit 1
fi

if [ ! -f "$2" ]; then
  echo "$2 does not exist"
  usage
  exit 1
fi

talosctl config merge config-20260104212706/talosconfig
KUBECONFIG=~/.kube/config:$2 kubectl config view --merge --flatten > ~/.kube/config
