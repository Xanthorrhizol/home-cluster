#!/bin/bash
cat << EOF > view-only-clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: view-only
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
EOF
kubectl apply -f view-only-clusterrole.yaml
kubectl create serviceaccount view-only-user -n kube-system
kubectl create clusterrolebinding view-only-binding \
  --clusterrole=view-only \
  --serviceaccount=kube-system:view-only-user
cat << EOF > view-only-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: view-only-token
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: view-only-user
type: kubernetes.io/service-account-token
EOF
kubectl apply -f view-only-secret.yaml
TOKEN=$(kubectl get secret view-only-token -n kube-system -o jsonpath='{.data.token}' | base64 -d)
# 현재 클러스터 정보 가져오기
CLUSTER_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CLUSTER_CA=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')

# kubeconfig 작성
cat > view-only-kubeconfig.yaml << EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${CLUSTER_CA}
    server: ${CLUSTER_SERVER}
  name: my-cluster
contexts:
- context:
    cluster: my-cluster
    user: view-only-user
  name: view-only-context
current-context: view-only-context
users:
- name: view-only-user
  user:
    token: ${TOKEN}
EOF
