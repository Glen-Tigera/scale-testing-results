#!/bin/bash

# Configuration
export NAMESPACE=calico-system
export LABEL_SELECTOR="k8s-app=calico-node"
# Override this env var or default to a hardcoded value.
export NODE_NAME="${NODE_NAME:-glen-bz-d6et-kadm-node-1.us-central1-a.c.tigera-dev.internal}"
export ACCEPTABLE_START_UP_TIME=60

# Find the pod running on the specified node
OLD_POD=$(kubectl get pods -n $NAMESPACE -l "$LABEL_SELECTOR" -o json | jq -r ".items[] | select(.spec.nodeName==\"$NODE_NAME\") | .metadata.name")
if [ -z "$OLD_POD" ]; then
  echo "No DaemonSet pod found on node $NODE_NAME"
  exit 1
fi

echo "Deleting DaemonSet pod $OLD_POD on node $NODE_NAME"
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

# Wait for pod to be Ready
echo "Waiting for pod $NEW_POD to become Ready..."
kubectl wait --for=condition=Ready pod/$NEW_POD -n $NAMESPACE --timeout=300s

READY_EPOCH=$(date +%s)
DURATION=$((READY_EPOCH - START_EPOCH))

echo "DaemonSet pod $NEW_POD became Ready in $DURATION seconds."
echo "Calico-node startup time: ${DURATION}s"

if [ $DURATION -ge $ACCEPTABLE_START_UP_TIME ]; then
  echo "ERROR: $NEW_POD startup took too long ($DURATION seconds) and failed to meet $ACCEPTABLE_START_UP_TIME second startup time requirement."
  exit 1
else
  echo "SUCCESS: $NEW_POD startup time is within the acceptable range ($DURATION seconds)"
fi
