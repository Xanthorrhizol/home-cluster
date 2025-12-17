#!/bin/bash
function usage() {
  echo "Usage: $0 <machine architecture> <talos-linux version> <customization file>"
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

SCHEMATIC_ID=$(curl -XPOST https://factory.talos.dev/schematics \
  -H "Content-Type: application/json; charset=utf-8" \
  -H "Accept: application/json" \
  -d $"$(cat $CUSTOMIZATION | yq)" 2>/dev/null | jq '.id' | tr -d '"')

read -p "Download iso image with schematic_id=$SCHEMATIC_ID. Press enter to continue" -n 1 -r

FIND_RESULT=$(curl -XGET https://factory.talos.dev/image/$SCHEMATIC_ID/$TALOS_LINUX_VERSION/metal-$ARCH.iso)

if [ $(echo $FIND_RESULT | htmlq -t) == "Found." ]; then
  DOWNLOAD_URL=$(echo $FIND_RESULT | htmlq a -a href)
  curl $DOWNLOAD_URL -o $OUTPUT
else
  echo "Failed to download iso image with schematic_id=$SCHEMATIC_ID"
  echo $FIND_RESULT
  exit 1
fi
