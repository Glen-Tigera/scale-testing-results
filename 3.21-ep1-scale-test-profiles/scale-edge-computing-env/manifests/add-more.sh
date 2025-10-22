#!/bin/bash
set -ex
NUM_TO_CREATE="${1:-1000}"
THREADS="${2:-10}"
ACTION="${3:-apply}"

NUM_NS=$(kubectl get ns | grep "test-ns" | wc -l)

if [ "$ACTION" == "delete" ]; then
  seq "$NUM_NS" -1 $((NUM_NS-NUM_TO_CREATE)) | xargs -P "${THREADS}" -I _ sh -c "kubectl delete ns test-ns-_"
elif [ "$ACTION" == "apply" ]; then
  seq "$NUM_NS" $((NUM_NS+NUM_TO_CREATE)) | xargs -P "${THREADS}" -I _ sh -c "sed 's/9999/_/' example.yaml | kubectl apply -f -"
fi
