#!/usr/bin/env bash

set -e

INTERACTIVE_MODE=${INTERACTIVE_MODE:=false}
CUSTOM_K8S_E2E_IMAGE=${CUSTOM_K8S_E2E_IMAGE:=gcr.io/unique-caldron-775/k8s-e2e:stable}
BZ_MCM_PREFIX=${BZ_MCM_PREFIX:=$USER-bz-$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 4)}

BZ_PROFILES_PATH=${BZ_PROFILES_PATH:=$HOME/bzprofiles}
BZ_SECRETS_PATH=${BZ_SECRETS_PATH:=$HOME/.banzai/secrets}
BZ=${BZ_PATH:=$HOME/.local/bin/bz}
BZ_BRANCH=${BZ_BRANCH}

MANAGEMENT_K8SVERSION=${MANAGEMENT_K8SVERSION:="stable-1"}
MANAGEMENT_RELEASE_STREAM=${MANAGEMENT_RELEASE_STREAM:="master"}
MANAGEMENT_PROVISIONER=${MANAGEMENT_PROVISIONER:="azr-aks"}

MANAGED_CLUSTERS=${MANAGED_CLUSTERS:-1}
MANAGED_RELEASE_STREAM=${MANAGED_RELEASE_STREAM:=$MANAGEMENT_RELEASE_STREAM}
MANAGED_K8SVERSION=${MANAGED_K8SVERSION:=$MANAGEMENT_K8SVERSION}
MANAGED_PROVISIONER=${MANAGED_PROVISIONER:-$MANAGEMENT_PROVISIONER}

function configure_cluster () {
  if [[ -z "$1" ]]; then
    echo [ERROR] Cannot create a profile without a name
    exit 1
  fi

  if [[ -z "$2" ]]; then
    echo [ERROR] Cannot provision a cluster without a type
    exit 1
  elif [[ $2 == "Managed" ]]; then
     if [[ -z "$6" ]]; then
      echo [ERROR] Cannot provision a managed cluster without a management kubeconfig
      exit 1
     fi
  fi

  if [[ $INTERACTIVE_MODE == false ]]; then
      if [[ -z "$3" ]]; then
        echo [ERROR] Cannot provision a cluster without k8s version
        exit 1
      fi

      if [[ -z "$4" ]]; then
        echo [ERROR] Cannot provision a cluster without a release stream
        exist 1
      fi

      if [[ -z "$5" ]]; then
        echo [ERROR] Cannot provision a cluster without a provisioner
        exit 1
      fi
  fi

  echo cd "$BZ_PROFILES_PATH"
  cd "$BZ_PROFILES_PATH"

  optionalFlags=""
  # Only set --core-branch if it is explicitly provided as a parameter. This
  # is useful for dev testing when you want to provide your own branch. This 
  # should not be set in pipelines for official releases. 
  if [[ -n "$BZ_BRANCH" ]]; then
      optionalFlags="${optionalFlags} --core-branch $BZ_BRANCH"
  fi 

  if [[ $INTERACTIVE_MODE == true ]]; then
    echo K8S_E2E_IMAGE=$CUSTOM_K8S_E2E_IMAGE CALIENT_CLUSTER_TYPE="$2" CLUSTER_NAME="$1" "$BZ" init profile -n "$1" $optionalFlags
    K8S_E2E_IMAGE=$CUSTOM_K8S_E2E_IMAGE CALIENT_CLUSTER_TYPE=$2 CLUSTER_NAME="$1" $BZ init profile -n "$1" $optionalFlags
  else
    echo CALIENT_MANAGEMENT_KUBECONFIG="$6" K8S_E2E_IMAGE=$CUSTOM_K8S_E2E_IMAGE CALIENT_CLUSTER_TYPE="$2" CLUSTER_NAME="$1" "$BZ" init profile -n "$1" $optionalFlags --k8sversion "$3" --product calient --release-stream "$4" --installer operator --provisioner "$5" --secretsPath "$BZ_SECRETS_PATH" --skip-prompt
    CALIENT_MANAGEMENT_KUBECONFIG=$6 K8S_E2E_IMAGE=$CUSTOM_K8S_E2E_IMAGE CALIENT_CLUSTER_TYPE=$2 CLUSTER_NAME="$1" $BZ init profile -n "$1" $optionalFlags --k8sversion "$3" --product calient --release-stream "$4" --installer operator --provisioner "$5" --secretsPath "$BZ_SECRETS_PATH" --skip-prompt
  fi
  echo cd "$BZ_PROFILES_PATH/$1"
  cd "$BZ_PROFILES_PATH/$1"

  echo cd "$BZ_PROFILES_PATH"
  cd "$BZ_PROFILES_PATH"
}

management="$BZ_MCM_PREFIX-mgmt"
managed_prefix="$BZ_MCM_PREFIX-managed"
echo [INFO] Starting multicluster provisioning and configuration using prefix mcm id "$BZ_MCM_PREFIX" in "$BZ_PROFILES_PATH"
echo mkdir -p "$BZ_PROFILES_PATH"
mkdir -p "$BZ_PROFILES_PATH"

echo [INFO] Provision management cluster
configure_cluster "$management" Management $MANAGEMENT_K8SVERSION $MANAGEMENT_RELEASE_STREAM $MANAGEMENT_PROVISIONER
cd "$BZ_PROFILES_PATH/$management" || exit 1

for i in $(seq 1 "$MANAGED_CLUSTERS"); do
    echo [INFO] Provision managed cluster number "$i"
    managed=$managed_prefix-$i
    configure_cluster "$managed" Managed $MANAGED_K8SVERSION $MANAGED_RELEASE_STREAM "$MANAGED_PROVISIONER" "$BZ_PROFILES_PATH/$management/.local/kubeconfig"
    cd "$BZ_PROFILES_PATH/$managed" || exit 1
done

echo [INFO] Creating /tmp/mcm-"$BZ_MCM_PREFIX".status file
printf "management: %s\n"  "$management" > /tmp/mcm-"$BZ_MCM_PREFIX".status
printf "managed:" >> /tmp/mcm-"$BZ_MCM_PREFIX".status
for i in $(seq 1 "$MANAGED_CLUSTERS"); do
  printf " %s" "${managed_prefix}"-"${i}" >> /tmp/mcm-"$BZ_MCM_PREFIX".status
done
printf "\n" >> /tmp/mcm-"$BZ_MCM_PREFIX".status

echo cp /tmp/mcm-"$BZ_MCM_PREFIX".status "$BZ_PROFILES_PATH"
cp /tmp/mcm-"$BZ_MCM_PREFIX".status "$BZ_PROFILES_PATH"
echo [INFO]  Content of "$BZ_PROFILES_PATH"/mcm-"$BZ_MCM_PREFIX".status
cat "$BZ_PROFILES_PATH"/mcm-"$BZ_MCM_PREFIX".status
