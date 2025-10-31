#!/usr/bin/env bash

BZ_PROFILES_PATH=${BZ_PROFILES_PATH:=$HOME/bzprofiles}
BZ_SECRETS_PATH=${BZ_SECRETS_PATH:=$HOME/.banzai/secrets}
BZ=${BZ_PATH:=$HOME/.local/bin/bz}
BZ_MCM_STATUS_PATH=${BZ_MCM_STATUS_PATH:=$(find "$BZ_PROFILES_PATH" -maxdepth 1 -type f -name "mcm-*.status" -printf "%T@ %p\n" | sort -rn -k1 | head -n 1 | cut -d" " -f2)}

echo [INFO] Using "$BZ_MCM_STATUS_PATH" to extract clusters
clusters=$(cut -d: -f2 "$BZ_MCM_STATUS_PATH" | tr -d '\n')

if [[ -z "$clusters" ]]; then
  echo [ERROR] No clusters have been declared to be destroyed
  exit 1
fi

for cluster in $clusters; do
  if [[ -d $BZ_PROFILES_PATH/$cluster ]]; then
    echo [INFO] Destroying "$cluster"
    cd "$BZ_PROFILES_PATH/$cluster" || exit 1
    $BZ destroy
    cd "$BZ_PROFILES_PATH" || exit 1
    echo [INFO] Deleting "$cluster"
    rm -rf "$cluster"
    echo [INFO] Deleting diagnostic for "$cluster"
    rm "$BZ_PROFILES_PATH/.diags/$cluster-diags.zip"
    echo [INFO] Deleting test reports for "$cluster"
    rm "$BZ_PROFILES_PATH/.report/junit_${cluster}_1.xml"
  fi
done

echo [INFO] rm "$BZ_MCM_STATUS_PATH"
rm "$BZ_MCM_STATUS_PATH"
