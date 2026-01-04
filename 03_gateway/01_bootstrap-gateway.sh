#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
source ../env

cat << EOF > ntpd.conf
servers 0.kr.pool.ntp.org
servers 1.kr.pool.ntp.org
servers 2.kr.pool.ntp.org
servers 3.kr.pool.ntp.org
EOF

scp ntpd.conf $GW_NODE:/etc/ntpd.conf
ssh $GW_NODE -C $" \
  rc-service ntpd restart && \
  rc-update add ntpd default"

rm ntpd.conf
