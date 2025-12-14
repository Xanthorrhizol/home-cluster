#!/bin/bash
function usage() {
  echo "Usage: $0 <config-path>"
}

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

if [ ! -f "$1" ]; then
  echo "Config file not found: $1"
  usage
  exit 1
fi

CONFIG_PATH=$1
CONFIG_DIR=$(dirname $CONFIG_PATH)

cd $CONFIG_DIR
python3 -m http.server 8000
