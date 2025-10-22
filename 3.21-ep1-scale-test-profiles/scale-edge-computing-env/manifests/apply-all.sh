#!/bin/bash
set -ex


kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: addon-policies
EOF

kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: addon-fake-nodes
EOF

kubectl --kubeconfig=$MANAGED_KUBECONFIG get configmap tigera-ca-bundle --namespace=calico-system -o json | jq 'del(.metadata.creationTimestamp, .metadata.uid, .metadata.ownerReferences, .metadata.resourceVersion, .metadata.namespace)' | kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -n addon-fake-nodes -f -
kubectl --kubeconfig=$MANAGED_KUBECONFIG get secret node-certs --namespace=calico-system -o json | jq 'del(.metadata.creationTimestamp, .metadata.uid, .metadata.ownerReferences, .metadata.resourceVersion, .metadata.namespace)' | kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -n addon-fake-nodes -f -

kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f unused-policies-10k.1.yaml & \
kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f unused-policies-10k.2.yaml & \
kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f unused-policies-10k.3.yaml & \
kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f unused-policies-10k.4.yaml & \
kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f unused-policies-10k.5.yaml & \
kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f unused-policies-10k.6.yaml & \
kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f unused-policies-10k.7.yaml & \
kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f unused-policies-10k.8.yaml & \
kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f unused-policies-10k.9.yaml & \
kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f unused-policies-10k.10.yaml & \
kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f live-deployments.yaml & \
kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f services.yaml & \
kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f live-policies.yaml & \
kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f metrics-server.yaml & \
kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f microservices.yaml
# Uncomment if also deploying scale test operator
# kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f test-config.yaml

