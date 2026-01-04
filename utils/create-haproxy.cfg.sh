#!/bin/bash
source ./env

cat << EOF > haproxy.cfg
#---------------------------------------------------------------------
# Example configuration for a possible web application.  See the
# full configuration options online.
#
#   http://haproxy.1wt.eu/download/1.4/doc/configuration.txt
#
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    # to have these messages end up in /var/log/haproxy.log you will
    # need to:
    #
    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    #
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
    log         127.0.0.1 local2

    # unecessary since already in a container and runs w/ a non-root user
    # chroot      /var/lib/haproxy
    # user        haproxy
    # group       haproxy
    # daemon

    pidfile     /var/lib/haproxy/haproxy.pid
    maxconn     4000

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000
    default-server          init-addr last,libc,none

#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------
frontend  http
    bind *:80 
    bind *:443 ssl crt /etc/haproxy/ssl/$DOMAIN.pem
    http-request set-header X-Forwarded-Proto https if { ssl_fc }
    http-request set-header X-Forwarded-Proto http if !{ ssl_fc } 
    http-request redirect scheme https code 301 unless { ssl_fc }

    acl domain_nas  hdr_beg(host) -i nas.
    acl domain_nas_explorer hdr_beg(host) -i nas-explorer.
    acl domain_app  hdr_end(host) -i $DOMAIN

    use_backend be_nas if domain_nas domain_app
    use_backend be_nas_explorer if domain_nas_explorer domain_app

    use_backend be_app if domain_app

#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend be_app
    balance roundrobin
$(i=0; for NODE in ${WORKER_NODES[@]}; do echo "    server      $NODE ${WORKER_IPS[$i]}:80 check"; ((i++)); done)

backend be_nas
    balance roundrobin
    server      nas $NAS_IP:80 check

backend be_nas_explorer
    balance roundrobin
    server      nas_explorer $NAS_IP:3670 check
EOF
