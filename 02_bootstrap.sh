#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
source ./env

cat << EOF > ntpd.conf
servers 0.kr.pool.ntp.org
servers 1.kr.pool.ntp.org
servers 2.kr.pool.ntp.org
servers 3.kr.pool.ntp.org
EOF

NODES=(${PROXY_NODES[@]} ${CONTROLPLANE_NODES[@]} ${WORKER_NODES[@]})

# bootstrap servers
for NODE in ${NODES[@]}; do
  scp ntpd.conf $NODE:/etc/ntpd.conf
  if [ $NODE == $GPU_NODE ]; then
    # Ubuntu
    ssh $NODE -C $" \
      systemctl restart ntpd && \
      systemctl enable ntpd && \
      systemctl disable --now systemd-resolved && \
      apt-get remove -y systemd-resolved && \
      echo \"nameserver ${PROXY_IP}\" > /etc/resolv.conf && \
      echo 'change dns into your dns server' && \
      read -p 'Press enter to continue' && \
      vi /etc/netplan/50-cloud-init.yaml"
  else
    # Alpine
    ssh $NODE -C $" \
      rc-service ntpd restart && \
      rc-update add ntpd default && \
      echo 'change dns into your dns server' && \
      setup-dns"
  fi
done

rm ntpd.conf
