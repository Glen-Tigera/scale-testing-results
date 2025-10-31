#!/bin/bash
set -ex

# I needed this in my setup to activate my Banzai virtualenv
# source /home/lance/scratch/env/bin/activate

# Setup env vars to control config details of the MCM clusters
export BZ_BRANCH=stable-v0.9
export BZ_PROFILES_PATH=$(pwd)
export MANAGEMENT_PROVISIONER=gcp-kubeadm
export MANAGEMENT_RELEASE_STREAM=v3.21
export RELEASE_PATCH=0-1.0
export USE_HASH_RELEASE=false
export CRC_PODS_PER_NODE=300
export CLUSTER_NODE_TYPE=n2-standard-4
export GOOGLE_MASTER_MACHINE_TYPE=n2-standard-32
export GOOGLE_NODE_MACHINE_TYPE=n2-standard-32
export GOOGLE_INFRA_MACHINE_TYPE=n2-standard-8
export GOOGLE_RR_MACHINE_TYPE=n2-standard-2
export GOOGLE_ETCD_MACHINE_TYPE=n2-standard-2
export CLUSTER_NODES=10
export NUM_INFRA_NODES=3
export DATAPLANE=CalicoIptables # Valid options can be any of CalicoIptables, CalicoBPF, CalicoVPP, CalicoNftables

# Setup the MCM clusters
./mcm-init.sh
./mcm-provision.sh

# Setup env vars for the rest of the script
BZ_MCM_STATUS_PATH=${BZ_MCM_STATUS_PATH:=$(find "$BZ_PROFILES_PATH" -maxdepth 1 -type f -name "mcm-*.status" -printf "%T@ %p\n" | sort -rn -k1 | head -n 1 | cut -d" " -f2)}
echo [INFO] Using "$BZ_MCM_STATUS_PATH" to extract clusters
export MGMT_NAME=$(grep "management:" "$BZ_MCM_STATUS_PATH" | cut -d: -f2 | tr -d '[:space:]')
export MANAGED_NAME=$(grep "managed:" "$BZ_MCM_STATUS_PATH" | cut -d: -f2 | tr -d '[:space:]')

export MANAGED_KUBECONFIG="$PWD/$MANAGED_NAME/.local/kubeconfig"
export MANAGEMENT_KUBECONFIG="$PWD/$MGMT_NAME/.local/kubeconfig"

sleep 60  # for things to settle down

# Do a sparse checkout of the calico-private repo, just to get the fake-guardian setup scripts.
export CALICO_PRIVATE_GIT_TAG="${MANAGEMENT_RELEASE_STREAM}.${RELEASE_PATCH}"
git clone --filter=blob:none --no-checkout git@github.com:tigera/calico-private.git calico-private
pushd calico-private
  git sparse-checkout init --cone
  git sparse-checkout set test-tools/fake-guardian/cmd/create-managed-clusters test-tools/titan api
  git checkout ${CALICO_PRIVATE_GIT_TAG}
popd

# Create the fake cluster connections in the management cluster.
pushd calico-private/test-tools/fake-guardian/cmd/create-managed-clusters && NAMESPACE="fake-guardian" TENANT_ID="" go run main.go
popd

# Copy secrets needed for fake clusters and create the fake cluster statefulset in the managed cluster
kubectl --kubeconfig=$MANAGED_KUBECONFIG -n tigera-guardian get cm tigera-ca-bundle -o json | jq -c 'del(.metadata)|.metadata.name="tigera-ca-bundle"|.metadata.namespace="fake-guardian"' | kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f -
kubectl --kubeconfig=$MANAGEMENT_KUBECONFIG -n tigera-manager  get secret tigera-pull-secret -o json | jq -c 'del(.metadata)|.metadata.name="tigera-pull-secret"|.metadata.namespace="fake-guardian"' | kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f -
kubectl --kubeconfig=$MANAGED_KUBECONFIG apply -f calico-private/test-tools/fake-guardian/fake-guardian.yaml

# Install the rest of the "realistic" config.
pushd manifests && ./apply-all.sh
popd

# This command scales the fake clusters.
# kubectl --kubeconfig=$MANAGED_KUBECONFIG scale statefulset -n fake-guardian fake-guardian-ss --replicas=2
