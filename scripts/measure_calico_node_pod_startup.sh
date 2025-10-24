#!/bin/bash
set -e

# Configuration
export NAMESPACE="${NAMESPACE:-calico-system}"
export LABEL_SELECTOR="${LABEL_SELECTOR:-k8s-app=calico-node}"
export NODE_NAME="${NODE_NAME:-glen-bz-d6et-kadm-node-1.us-central1-a.c.tigera-dev.internal}"
export ACCEPTABLE_START_UP_TIME="${ACCEPTABLE_START_UP_TIME:-60}"
export LOADGEN_NAMESPACE="${LOADGEN_NAMESPACE:-default}"

# Validate NODE_NAME is set
if [ -z "$NODE_NAME" ]; then
  echo "ERROR: NODE_NAME environment variable must be set"
  exit 1
fi

echo "=== Calico Node Startup Time Measurement ==="
echo "Namespace: $NAMESPACE"
echo "Label Selector: $LABEL_SELECTOR"
echo "Target Node: $NODE_NAME"
echo "Acceptable Startup Time: ${ACCEPTABLE_START_UP_TIME}s"
echo ""

# ============================================
# Collect Cluster Information
# ============================================
echo "=== Collecting Cluster Information ==="

# Kubernetes Version
K8S_VERSION=$(kubectl version -o json 2>/dev/null | jq -r '.serverVersion.gitVersion' || echo "Unknown")
echo "Kubernetes Version: $K8S_VERSION"

# Detect Provisioner
PROVISIONER="GCP-Kubeadm (default)"
if kubectl get nodes -o json | jq -r '.items[0].spec.providerID' | grep -q "gce://"; then
  PROVISIONER="GKE (Google Kubernetes Engine)"
elif kubectl get nodes -o json | jq -r '.items[0].spec.providerID' | grep -q "aws://"; then
  PROVISIONER="EKS (Amazon Elastic Kubernetes Service)"
elif kubectl get nodes -o json | jq -r '.items[0].spec.providerID' | grep -q "azure://"; then
  PROVISIONER="AKS (Azure Kubernetes Service)"
else
  PROVIDER_ID=$(kubectl get nodes -o json | jq -r '.items[0].spec.providerID' 2>/dev/null || echo "")
  if [ -n "$PROVIDER_ID" ]; then
    PROVISIONER="$PROVIDER_ID"
  fi
fi
echo "Provisioner: $PROVISIONER"

# Calico Configuration from Installation Resource
echo ""
echo "=== Calico Configuration ==="
INSTALLATION=$(kubectl get installation default -o json 2>/dev/null || echo "")
if [ -n "$INSTALLATION" ]; then
  DATAPLANE_MODE=$(echo "$INSTALLATION" | jq -r '.spec.calicoNetwork.linuxDataplane')
  ENCAPSULATION=$(echo "$INSTALLATION" | jq -r '.spec.calicoNetwork.ipPools[0].encapsulation // "Unknown"')
  BACKEND=$(echo "$INSTALLATION" | jq -r '.spec.calicoNetwork.bgp // "Unknown"')
  IP_POOL_CIDR=$(echo "$INSTALLATION" | jq -r '.spec.calicoNetwork.ipPools[0].cidr // "Unknown"')
  
  echo "Dataplane Mode: $DATAPLANE_MODE"
  echo "Encapsulation Type: $ENCAPSULATION"
  echo "BGP Enabled: $BACKEND"
  echo "IP Pool CIDR: $IP_POOL_CIDR"
else
  echo "Dataplane Mode: Unable to retrieve (no Installation resource found)"
  DATAPLANE_MODE="Unknown"
  ENCAPSULATION="Unknown"
  BACKEND="Unknown"
fi

echo ""
echo "=== Cluster Scale Metrics ==="

TOTAL_NETWORK_POLICIES=$(kubectl get networkpolicies --all-namespaces -o json | jq '.items | length')
echo "Total NetworkPolicies: $TOTAL_NETWORK_POLICIES"

TOTAL_SERVICES=$(kubectl get services --all-namespaces -o json | jq '.items | length')
echo "Total Services: $TOTAL_SERVICES"

TOTAL_NODES=$(kubectl get nodes --no-headers | grep " Ready " | wc -l)
echo "Total Ready Nodes: $TOTAL_NODES"

echo ""
echo "Pods per Node:"
kubectl get pods --all-namespaces -o json | jq -r '.items | group_by(.spec.nodeName) | .[] | "\(.[] | .spec.nodeName | select(. != null)): \(length) pods"' | sort | uniq

PODS_ON_TARGET_NODE=$(kubectl get pods --all-namespaces -o json | jq -r ".items[] | select(.spec.nodeName==\"$NODE_NAME\") | .metadata.name" | wc -l)
echo ""
echo "Pods on target node ($NODE_NAME): $PODS_ON_TARGET_NODE"
echo ""

# ============================================
# Restart Load Generator & Clear Stats
# ============================================
echo "=== Restarting Load Generator ==="
LOADGEN_POD=$(kubectl get pods -n $LOADGEN_NAMESPACE -l app=loadgenerator -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -n "$LOADGEN_POD" ]; then
  echo "Found load generator pod: $LOADGEN_POD"
  echo "Deleting load generator pod to clear stats..."
  kubectl delete pod $LOADGEN_POD -n $LOADGEN_NAMESPACE
  
  echo "Waiting for new load generator pod to be created..."
  RETRIES=0
  MAX_RETRIES=30
  while [ $RETRIES -lt $MAX_RETRIES ]; do
    NEW_LOADGEN_POD=$(kubectl get pods -n $LOADGEN_NAMESPACE -l app=loadgenerator -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    if [ -n "$NEW_LOADGEN_POD" ] && [ "$NEW_LOADGEN_POD" != "$LOADGEN_POD" ]; then
      echo "New load generator pod created: $NEW_LOADGEN_POD"
      break
    fi
    sleep 2
    RETRIES=$((RETRIES + 1))
  done
  
  if [ -z "$NEW_LOADGEN_POD" ] || [ "$NEW_LOADGEN_POD" = "$LOADGEN_POD" ]; then
    echo "WARNING: New load generator pod not created within timeout"
  else
    echo "Waiting for new load generator pod to be ready..."
    kubectl wait --for=condition=Ready pod/$NEW_LOADGEN_POD -n $LOADGEN_NAMESPACE --timeout=120s
  fi
  echo "New load generator pod ready: $NEW_LOADGEN_POD"
else
  echo "WARNING: No load generator pod found with label app=loadgenerator in namespace $LOADGEN_NAMESPACE"
fi
echo ""

# ============================================
# Calico Node Pod Restart Test
# ============================================
echo "=== Starting Calico Node Restart Test ==="

# Find the pod running on the specified node
OLD_POD=$(kubectl get pods -n $NAMESPACE -l "$LABEL_SELECTOR" -o json | jq -r ".items[] | select(.spec.nodeName==\"$NODE_NAME\") | .metadata.name")
if [ -z "$OLD_POD" ]; then
  echo "ERROR: No DaemonSet pod found on node $NODE_NAME"
  exit 1
fi

echo "Found pod: $OLD_POD on node $NODE_NAME"
echo "Deleting pod $OLD_POD..."
kubectl delete pod $OLD_POD -n $NAMESPACE

# Wait for a new pod to appear on the same node
echo "Waiting for new pod on node $NODE_NAME..."
while true; do
  NEW_POD=$(kubectl get pods -n $NAMESPACE -l "$LABEL_SELECTOR" -o json | jq -r ".items[] | select(.spec.nodeName==\"$NODE_NAME\") | .metadata.name")
  if [[ "$NEW_POD" != "$OLD_POD" && -n "$NEW_POD" ]]; then
    echo "New pod detected: $NEW_POD"
    break
  fi
  sleep 1
done

# Get the new pod creation time
START_TIME=$(kubectl get pod $NEW_POD -n $NAMESPACE -o jsonpath="{.metadata.creationTimestamp}")
START_EPOCH=$(date -d "$START_TIME" +%s)
echo "Pod created at: $START_TIME (epoch: $START_EPOCH)"

# Wait for pod to be Ready
echo "Waiting for pod $NEW_POD to become Ready..."
kubectl wait --for=condition=Ready pod/$NEW_POD -n $NAMESPACE --timeout=300s

READY_EPOCH=$(date +%s)
DURATION=$((READY_EPOCH - START_EPOCH))

echo ""
echo "========================================"
echo "DaemonSet pod $NEW_POD became Ready in $DURATION seconds."
echo "Calico-node startup time: ${DURATION}s"
echo "========================================"
echo ""

# ============================================
# Wait and Collect Load Generator Stats
# ============================================
MEDIAN_LATENCY="N/A"
if [ -n "$NEW_LOADGEN_POD" ]; then
  echo "=== Waiting for Load Generator Statistics ==="
  echo "Waiting 30 seconds for load generator to accumulate stats..."
  sleep 30
  
  echo ""
  echo "=== Load Generator Pod-to-Pod Latency Statistics ==="
  LOADGEN_STATS=$(kubectl logs $NEW_LOADGEN_POD -n $LOADGEN_NAMESPACE --tail=50 | grep -A 20 "Type.*Name.*# reqs" || echo "")
  echo "$LOADGEN_STATS"
  echo ""
  
  # Extract median latency from Aggregated row
  MEDIAN_LATENCY=$(echo "$LOADGEN_STATS" | grep "Aggregated" | awk -F'|' '{print $2}' | awk '{print $4}')
  if [ -z "$MEDIAN_LATENCY" ]; then
    MEDIAN_LATENCY="N/A"
  fi
fi

# ============================================
# Final Results
# ============================================
echo "========================================"
echo "TEST RESULTS SUMMARY"
echo "========================================"
echo "Cluster Information:"
echo "  Kubernetes Version: $K8S_VERSION"
echo "  Provisioner: $PROVISIONER"
echo "  Total Ready Nodes: $TOTAL_NODES"
echo ""
echo "Calico Configuration:"
echo "  Dataplane Mode: $DATAPLANE_MODE"
echo "  Encapsulation: $ENCAPSULATION"
echo "  BGP Enabled: $BACKEND"
echo ""
echo "Cluster Scale:"
echo "  Total NetworkPolicies: $TOTAL_NETWORK_POLICIES"
echo "  Total Services: $TOTAL_SERVICES"
echo "  Pods on target node: $PODS_ON_TARGET_NODE"
echo ""
echo "Performance:"
echo "  Calico-node startup time: ${DURATION}s"
echo "  Pod-to-Pod Median Latency: ${MEDIAN_LATENCY}ms"
echo "========================================"
echo ""

if [ $DURATION -ge $ACCEPTABLE_START_UP_TIME ]; then
  echo "❌ FAILURE: $NEW_POD startup took too long ($DURATION seconds) and failed to meet $ACCEPTABLE_START_UP_TIME second startup time requirement."
  exit 1
else
  echo "✅ SUCCESS: $NEW_POD startup time is within the acceptable range ($DURATION seconds < ${ACCEPTABLE_START_UP_TIME}s)"
  exit 0
fi
