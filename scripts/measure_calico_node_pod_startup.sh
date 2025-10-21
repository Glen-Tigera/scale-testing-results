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
# Collect Cluster Metrics Before Test
# ============================================
echo "=== Collecting Cluster Metrics ==="

TOTAL_NETWORK_POLICIES=$(kubectl get networkpolicies --all-namespaces -o json | jq '.items | length')
echo "Total NetworkPolicies: $TOTAL_NETWORK_POLICIES"

TOTAL_SERVICES=$(kubectl get services --all-namespaces -o json | jq '.items | length')
echo "Total Services: $TOTAL_SERVICES"

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
  
  echo "Waiting for new load generator pod..."
  kubectl wait --for=condition=Ready pod -l app=loadgenerator -n $LOADGEN_NAMESPACE --timeout=120s
  
  NEW_LOADGEN_POD=$(kubectl get pods -n $LOADGEN_NAMESPACE -l app=loadgenerator -o jsonpath='{.items[0].metadata.name}')
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
if [ -n "$NEW_LOADGEN_POD" ]; then
  echo "=== Waiting for Load Generator Statistics ==="
  echo "Waiting 30 seconds for load generator to accumulate stats..."
  sleep 30
  
  echo ""
  echo "=== Load Generator Pod-to-Pod Latency Statistics ==="
  kubectl logs $NEW_LOADGEN_POD -n $LOADGEN_NAMESPACE --tail=50 | grep -A 20 "Type.*Name.*# reqs" || echo "No statistics found yet"
  echo ""
fi

# ============================================
# Final Results
# ============================================
echo "========================================"
echo "CLUSTER METRICS SUMMARY"
echo "========================================"
echo "Total NetworkPolicies: $TOTAL_NETWORK_POLICIES"
echo "Total Services: $TOTAL_SERVICES"
echo "Pods on target node: $PODS_ON_TARGET_NODE"
echo "Calico-node startup time: ${DURATION}s"
echo "========================================"
echo ""

if [ $DURATION -ge $ACCEPTABLE_START_UP_TIME ]; then
  echo "❌ FAILURE: $NEW_POD startup took too long ($DURATION seconds) and failed to meet $ACCEPTABLE_START_UP_TIME second startup time requirement."
  exit 1
else
  echo "✅ SUCCESS: $NEW_POD startup time is within the acceptable range ($DURATION seconds < ${ACCEPTABLE_START_UP_TIME}s)"
  exit 0
fi
