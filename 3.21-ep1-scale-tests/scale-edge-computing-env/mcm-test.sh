#!/usr/bin/env bash

BZ_PROFILES_PATH=${BZ_PROFILES_PATH:=$HOME/bzprofiles}
BZ_SECRETS_PATH=${BZ_SECRETS_PATH:=$HOME/.banzai/secrets}
BZ=${BZ_PATH:=$HOME/.local/bin/bz}
BZ_MCM_STATUS_PATH=${BZ_MCM_STATUS_PATH:=$(find "$BZ_PROFILES_PATH" -maxdepth 1 -type f -name "mcm-*.status" -printf "%T@ %p\n" | sort -rn -k1 | head -n 1 | cut -d" " -f2)}
K8S_E2E_FLAGS=${K8S_E2E_FLAGS:="--ginkgo.focus=(\[calient-mcm\])"}

echo [INFO] Using "$BZ_MCM_STATUS_PATH" to extract clusters
clusters=$(cut -d: -f2 "$BZ_MCM_STATUS_PATH" | tr -d '\n')

if [[ -z "$clusters" ]]; then
  echo [ERROR] No clusters have been declared to be tested
  exit 1
fi

# Get the kubeconfig path of all managed clusters from status file
function getVolumesToMount() {
  NEW_K8S_E2E_FLAGS="${K8S_E2E_FLAGS} --e2ecfg.calient-managed-kubeconfigs="
  statusFile=${BZ_PROFILES_PATH}/mcm-${1::-3}.status
  prefix="managed:"
  while IFS= read -r line; do
    if [[ $line == $prefix* ]]; then
      line=${line#$prefix}
      arr=$(echo "$line" | tr " " "\n")
      for managedCluster in $arr; do
        KUBECONFIG_PATH="$BZ_PROFILES_PATH/${managedCluster}/.local/kubeconfig"
        NEW_K8S_E2E_DOCKER_EXTRA_FLAGS+=" -v $KUBECONFIG_PATH:$KUBECONFIG_PATH"
        NEW_K8S_E2E_FLAGS+="$KUBECONFIG_PATH,"
      done
    fi
  done <"$statusFile"
}

echo [INFO] Creating "$BZ_PROFILES_PATH/.report" to store test reports
echo mkdir -p "$BZ_PROFILES_PATH/.report"
mkdir -p "$BZ_PROFILES_PATH/.report"

exit_status=0

for cluster in $clusters; do
  if [[ -d $BZ_PROFILES_PATH/$cluster ]]; then
    cd "$BZ_PROFILES_PATH/$cluster" || exit 1
    cluster_type=$(awk '/CALIENT_CLUSTER_TYPE:/{print $2}' Taskvars.yml | tr -d "\n")
    if [[ $cluster_type == Management ]]; then
      getVolumesToMount "$cluster"
    fi
    echo [INFO] Running tests on "$cluster_type" cluster "$cluster" using "$K8S_E2E_FLAGS"
    echo K8S_E2E_FLAGS="$NEW_K8S_E2E_FLAGS" K8S_E2E_DOCKER_EXTRA_FLAGS="$NEW_K8S_E2E_DOCKER_EXTRA_FLAGS" "$BZ" tests
    K8S_E2E_FLAGS="$NEW_K8S_E2E_FLAGS" K8S_E2E_DOCKER_EXTRA_FLAGS="$NEW_K8S_E2E_DOCKER_EXTRA_FLAGS" "$BZ" tests; (( exit_status = exit_status || $? ))
    if [[ -f "$BZ_PROFILES_PATH/$cluster/.local/report/k8s-e2e/junit_1.xml" ]]; then
      echo [INFO] Moving test results to "$BZ_PROFILES_PATH/.report"
      echo cp "$BZ_PROFILES_PATH/$cluster/.local/report/k8s-e2e/junit_1.xml" "$BZ_PROFILES_PATH/.report/junit_${cluster}_1.xml"
      cp "$BZ_PROFILES_PATH/$cluster/.local/report/k8s-e2e/junit_1.xml" "$BZ_PROFILES_PATH/.report/junit_${cluster}_1.xml"
      echo [INFO] Rewriting testcase name to match the correct cluster
      echo sed -i "s/<testcase name=\"/<testcase name=\"[cluster-${cluster}]/" "$BZ_PROFILES_PATH/.report/junit_${cluster}_1.xml"
      sed -i "s/<testcase name=\"/<testcase name=\"[cluster-${cluster}]/" "$BZ_PROFILES_PATH/.report/junit_${cluster}_1.xml"
    fi
  fi
  NEW_K8S_E2E_DOCKER_EXTRA_FLAGS=""
done

echo [INFO] Tests finished with "$exit_status"
exit $exit_status
