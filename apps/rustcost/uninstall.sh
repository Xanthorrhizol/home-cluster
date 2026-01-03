#!/bin/bash
function usage() {
  echo "Usage: $0 <httproute.enabled(true|false)>"
}
if [ $# -lt 1 ]; then
  usage
  exit 1
fi
HTTP_ROUTE=$1
case "$HTTP_ROUTE" in
  true|false)
    ;;
  *)
    usage
    exit 1
    ;;
esac
helm uninstall -n rustcost rustcost

if [ "$HTTP_ROUTE" = "true" ]; then
  kubectl delete -f http-route.yaml
fi
