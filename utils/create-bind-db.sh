#!/bin/bash
source ./env;

if [ ! -d bind ]; then
  mkdir bind
fi

cat << EOF > bind/db.$DOMAIN
\$TTL 86400
@   IN  SOA ns.$DOMAIN. admin.$DOMAIN. (
        2025121301
        3600
        1800
        604800
        86400
)
    IN  NS  ns.$DOMAIN.

$(i=0; for NODE in ${CONTROLPLANE_NODES[@]}; do echo "$NODE.server.$DOMAIN. IN A ${CONTROLPLANE_IPS[$i]}"; ((i++)); done)
$(i=0; for NODE in ${WORKER_NODES[@]}; do echo "$NODE.server.$DOMAIN. IN A ${WORKER_IPS[$i]}"; ((i++)); done)
*   IN  A   $GW_IP
EOF
