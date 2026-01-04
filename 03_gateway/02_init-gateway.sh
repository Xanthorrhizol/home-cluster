#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
source ../env

# create CA pem file
./utils/create-ca.sh

# install dns
ssh $GW_NODE -C "apk update && apk add bind"
if [ ! -d bind ]; then
  mkdir bind
fi
./utils/create-named.conf.sh
./utils/create-bind-db.sh
scp bind/* $GW_NODE:/etc/bind/
ssh $GW_NODE -C $" \
  rc-service named restart && \
  rc-update add named default"

# install haproxy
utils/create-haproxy.cfg.sh
ssh $GW_NODE -C "apk add haproxy"
scp haproxy.cfg $GW_NODE:/etc/haproxy/haproxy.cfg
ssh $GW_NODE -C "if [ ! -d /etc/haproxy/ssl ]; then mkdir /etc/haproxy/ssl; fi"
scp pki/$DOMAIN.pem $GW_NODE:/etc/haproxy/ssl
ssh $GW_NODE -C $" \
  rc-service haproxy restart && \
  rc-update add haproxy default && \
  rndc reload"

rm -rf bind haproxy.cfg
