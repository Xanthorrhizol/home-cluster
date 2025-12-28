#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
source ./env

if [ -f gpu.xml ]; then
  rm gpu.xml
fi
for PCI_ADDR in ${GPU_PCI_ADDRS[@]}; do
  DOMAIN=0000
  BUS=${PCI_ADDR:0:2}
  SLOT=${PCI_ADDR:3:2}
  FUNCTION=${PCI_ADDR:6:1}
  cat << EOF > gpu.xml
<hostdev mode='subsystem' type='pci' managed='yes'>
  <source>
    <address domain='0x${DOMAIN}' bus='0x${BUS}' slot='0x${SLOT}' function='0x${FUNCTION}'/>
  </source>
</hostdev>
EOF
  virsh attach-device ${GPU_NODE} --file gpu.xml --live --config
done

rm gpu.xml
