#!/bin/bash
cd $(dirname "$(readlink -f "$0")")
source ../../env
kubectl label ns rustcost gateway-access=true

cat << EOF > http-route.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
  namespace: rustcost
spec:
  parentRefs:
    - name: home-gateway
      namespace: envoy-gateway-system
  hostnames:
    - cost.${DOMAIN}
  rules:
    - backendRefs:
      - name: rustcost-core-svc
        port: 80
      matches:
        - path:
            type: PathPrefix
            value: /api/
      filters:
        - type: URLRewrite
          urlRewrite:
            path:
              type: ReplacePrefixMatch
              replacePrefixMatch: /
    - backendRefs:
      - name: rustcost-gpu-exporter
        port: 8000
      matches:
        - path:
            type: PathPrefix
            value: /metrics/
    - backendRefs:
      - name: rustcost-dashboard-svc
        port: 80
      matches:
        - path:
            type: PathPrefix
            value: /
EOF
