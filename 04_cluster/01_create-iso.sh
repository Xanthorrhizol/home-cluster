#!/bin/bash
function usage() {
  echo "Usage: $0 <machine architecture> <talos-linux version> <output file> {machineconfig providing server ip}"
  echo "Example: $0 amd64 v1.11.5 talos.iso"
  echo "         $0 arm64 v1.11.5 talos.iso"
}

function validate() {
  ARCH=$1
  TALOS_LINUX_VERSION=$2
  OUTPUT=$3
  CONFIG_SERVER_IP=$4

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

  if [ -f $OUTPUT ]; then
    echo "$OUTPUT already exists"
    read -p "Do you want to overwrite $OUTPUT? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi

  if [ ! -z $CONFIG_SERVER_IP ] && [ $(echo $CONFIG_SERVER_IP | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | wc -l) -ne 1 ]; then
    echo "$CONFIG_SERVER_IP is not a valid ip"
    usage
    exit 1
  fi
}

if [ "$#" -lt 3 ]; then
  usage
  exit 1
fi

cd $(dirname "$(readlink -f "$0")")
ARCH=$1
TALOS_LINUX_VERSION=$2
OUTPUT=$3
CONFIG_SERVER_IP=$4
if [ -z $CONFIG_SERVER_IP ]; then
  CONFIG_SERVER_IP=$(ip route get 8.8.8.8 | awk '{print $7}')
fi

cat << EOF > customization.yaml
customization:
    extraKernelArgs:
        - console=ttyS0,115200
        - talos.config=http://$CONFIG_SERVER_IP:8000/machineconfig.yaml
    systemExtensions:
        officialExtensions:
            - siderolabs/amd-ucode
            - siderolabs/iscsi-tools
            - siderolabs/nfs-utils
            - siderolabs/nvidia-container-toolkit-lts
            - siderolabs/nvidia-open-gpu-kernel-modules-lts
EOF

SCHEMATIC_ID=$(curl -XPOST https://factory.talos.dev/schematics \
  -H "Content-Type: application/json; charset=utf-8" \
  -H "Accept: application/json" \
  -d $"$(cat customization.yaml | yq)" 2>/dev/null | jq '.id' | tr -d '"')

FIND_RESULT=$(curl -XGET https://factory.talos.dev/image/$SCHEMATIC_ID/$TALOS_LINUX_VERSION/metal-$ARCH.iso)

if [ $(echo $FIND_RESULT | htmlq -t) == "Found." ]; then
  DOWNLOAD_URL=$(echo $FIND_RESULT | htmlq a -a href)
  echo "SCHEMATIC_ID=$SCHEMATIC_ID"
  echo "INSTALLER_IMAGE=factory.talos.dev/installer/$SCHEMATIC_ID:$TALOS_LINUX_VERSION"
  read -p "Download iso image with schematic_id=$SCHEMATIC_ID. Press enter to continue" -n 1 -r
  curl $DOWNLOAD_URL -o $OUTPUT
else
  echo "Failed to download iso image with schematic_id=$SCHEMATIC_ID"
  echo $FIND_RESULT
  exit 1
fi
