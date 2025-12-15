#!/bin/bash
function usage() {
  echo "Usage: $0 <machine architecture> <talos-linux version> <customization file> <output file>"
  echo "Example: $0 amd64 v1.11.5 customization.yaml talos.iso"
  echo "         $0 arm64 v1.11.5 customization.yaml talos.iso"
}

function validate() {
  ARCH=$1
  TALOS_LINUX_VERSION=$2
  CUSTOMIZATION=$3
  OUTPUT=$4

  case $ARCH in
    amd64|arm64)
      ;;
    *)
      echo "$ARCH is not a valid architecture"
      usage
      exit 1
      ;;
  esac
  
  if [ $(echo $TALOS_LINUX_VERSION | grep -E 'v[0-9]+\.[0-9]+\.[0-9]+$' | wc -l) -ne 1 ]; then
    echo "$TALOS_LINUX_VERSION is not a valid version"
    usage
    exit 1
  fi

  if [ ! -f $CUSTOMIZATION ]; then
    echo "$CUSTOMIZATION does not exist"
    usage
    exit 1
  fi

  if [ -f $OUTPUT ]; then
    echo "$OUTPUT already exists"
    read -p "Do you want to overwrite $OUTPUT? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi
}

if [ "$#" -ne 4 ]; then
  usage
  exit 1
fi

ARCH=$1
TALOS_LINUX_VERSION=$2
CUSTOMIZATION=$3
OUTPUT=$4

talosctl gen iso \
  --output $OUTPUT \
  --arch $ARCH \
  --version $TALOS_LINUX_VERSION \
  --customization $CUSTOMIZATION
