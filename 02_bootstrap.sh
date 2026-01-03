#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
source ./env

cat << EOF > ntpd.conf
servers 0.kr.pool.ntp.org
servers 1.kr.pool.ntp.org
servers 2.kr.pool.ntp.org
servers 3.kr.pool.ntp.org
EOF

NODES=($GW_NODE ${CONTROLPLANE_NODES[@]} ${WORKER_NODES[@]})

# bootstrap servers
for NODE in ${NODES[@]}; do
  scp ntpd.conf $NODE:/etc/ntpd.conf
  ssh $NODE -C $" \
    rc-service ntpd restart && \
    rc-update add ntpd default && \
    echo 'change dns into your dns server' && \
    setup-dns"
  if [ $NODE == $GPU_NODE ]; then
    ssh $NODE -C "apk add gcompat"
  fi
done

rm ntpd.conf
