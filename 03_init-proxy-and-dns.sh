#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
source ./env

# create CA pem file
./utils/create-ca.sh

# install dns
ssh $PROXY_NODE -C "apk update && apk add bind"
if [ ! -d bind ]; then
  mkdir bind
fi
./utils/create-named.conf.sh
./utils/create-temporal-bind-db.sh
scp bind/* $PROXY_NODE:/etc/bind/
ssh $PROXY_NODE -C $" \
  rc-service named restart && \
  rc-update add named default"

# install haproxy
utils/create-haproxy.cfg.sh
ssh $PROXY_NODE -C "apk add haproxy"
scp haproxy.cfg $PROXY_NODE:/etc/haproxy/haproxy.cfg
ssh $PROXY_NODE -C "if [ ! -d /etc/haproxy/ssl ]; then mkdir /etc/haproxy/ssl; fi"
scp pki/$DOMAIN.pem $PROXY_NODE:/etc/haproxy/ssl
ssh $PROXY_NODE -C $" \
  rc-service haproxy restart && \
  rc-update add haproxy default && \
  rndc reload"

rm -rf bind haproxy.cfg
