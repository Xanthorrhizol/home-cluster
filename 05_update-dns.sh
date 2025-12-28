#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
source ./env

# install dns
if [ ! -d bind ]; then
  mkdir bind
fi
./utils/create-bind-db.sh
scp bind/db.$DOMAIN $PROXY_NODE:/etc/bind/
ssh $PROXY_NODE -C $" \
  rc-service named restart && \
  rc-update add named default"

rm -rf bind
