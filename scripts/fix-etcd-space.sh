#!/bin/bash
set -e

echo "Finding etcd pod..."
ETCD_POD=$(kubectl get pods -n kube-system -l component=etcd -o name | head -1 | cut -d/ -f2)
echo "Using etcd pod: $ETCD_POD"

ETCD_CMD="ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key"

echo "1. Checking current alarms..."
kubectl exec -n kube-system $ETCD_POD -- sh -c "$ETCD_CMD alarm list"

echo "2. Getting current revision..."
CURRENT_REV=$(kubectl exec -n kube-system $ETCD_POD -- sh -c "$ETCD_CMD endpoint status --write-out=json" | jq -r '.[0].Status.header.revision')
echo "Current revision: $CURRENT_REV"

echo "3. Compacting etcd..."
kubectl exec -n kube-system $ETCD_POD -- sh -c "$ETCD_CMD compact $CURRENT_REV"

echo "4. Defragmenting etcd (this may take several minutes on large clusters)..."
kubectl exec -n kube-system $ETCD_POD -- sh -c "$ETCD_CMD --command-timeout=5m defrag"

echo "5. Disarming alarms..."
kubectl exec -n kube-system $ETCD_POD -- sh -c "$ETCD_CMD alarm disarm"

echo "6. Verifying etcd is healthy..."
kubectl exec -n kube-system $ETCD_POD -- sh -c "$ETCD_CMD endpoint status --write-out=table"

echo ""
echo "7. Now cleaning up old resources..."
echo "   Deleting completed jobs..."
kubectl delete jobs --all-namespaces --field-selector status.successful=1 --ignore-not-found=true 2>/dev/null || echo "   (No completed jobs found)"

echo "   Deleting failed jobs..."
kubectl delete jobs --all-namespaces --field-selector status.failed=1 --ignore-not-found=true 2>/dev/null || echo "   (No failed jobs found)"

echo "   Deleting completed pods..."
kubectl delete pods --all-namespaces --field-selector status.phase=Succeeded --ignore-not-found=true 2>/dev/null || echo "   (No completed pods found)"

echo "   Deleting failed pods..."
kubectl delete pods --all-namespaces --field-selector status.phase=Failed --ignore-not-found=true 2>/dev/null || echo "   (No failed pods found)"

echo ""
echo "8. Final status check..."
kubectl exec -n kube-system $ETCD_POD -- sh -c "$ETCD_CMD endpoint status --write-out=table"

echo ""
echo "✅ Done! etcd space has been freed and cluster should be writable again."