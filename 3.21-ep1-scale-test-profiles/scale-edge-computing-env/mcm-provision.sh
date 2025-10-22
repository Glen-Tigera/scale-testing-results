#!/usr/bin/env bash

set -e

BZ_PROFILES_PATH=${BZ_PROFILES_PATH:=$HOME/bzprofiles}
BZ_SECRETS_PATH=${BZ_SECRETS_PATH:=$HOME/.banzai/secrets}
BZ=${BZ_PATH:=$HOME/.local/bin/bz}
BZ_MCM_STATUS_PATH=${BZ_MCM_STATUS_PATH:=$(find "$BZ_PROFILES_PATH" -maxdepth 1 -type f -name "mcm-*.status" -printf "%T@ %p\n" | sort -rn -k1 | head -n 1 | cut -d" " -f2)}

echo [INFO] Using "$BZ_MCM_STATUS_PATH" to extract clusters
management=$(grep "management:" "$BZ_MCM_STATUS_PATH" | cut -d: -f2 )
managed=$(grep "managed:" "$BZ_MCM_STATUS_PATH" | cut -d: -f2 )
clusters="$management $managed"

if [[ -z "$clusters" ]]; then
  echo [ERROR] No clusters have been declared to be installed/provision
  exit 1
fi

echo [INFO] The following custers: "$clusters" are declared

for cluster in $clusters; do
  if [[ -d $BZ_PROFILES_PATH/$cluster ]]; then
    echo [INFO] Installing Calient using operator on "$cluster"
    pushd "$BZ_PROFILES_PATH/$cluster"
    $BZ provision
    $BZ install
    popd
  fi
done

