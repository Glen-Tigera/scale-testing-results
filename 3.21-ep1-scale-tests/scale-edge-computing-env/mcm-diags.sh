#!/usr/bin/env bash

BZ_PROFILES_PATH=${BZ_PROFILES_PATH:=$HOME/bzprofiles}
BZ_SECRETS_PATH=${BZ_SECRETS_PATH:=$HOME/.banzai/secrets}
BZ=${BZ_PATH:=$HOME/.local/bin/bz}
BZ_MCM_STATUS_PATH=${BZ_MCM_STATUS_PATH:=$(find "$BZ_PROFILES_PATH" -maxdepth 1 -type f -name "mcm-*.status" -printf "%T@ %p\n" | sort -rn -k1 | head -n 1 | cut -d" " -f2)}

echo [INFO] Using "$BZ_MCM_STATUS_PATH" to extract clusters
clusters=$(cut -d: -f2 "$BZ_MCM_STATUS_PATH" | tr -d '\n')

if [[ -z "$clusters" ]]; then
  echo [ERROR] No clusters have been declared to be diagnosed
  exit 1
fi

echo mkdir -p "$BZ_PROFILES_PATH/.diags"
mkdir -p "$BZ_PROFILES_PATH/.diags"

for cluster in $clusters; do
  if [[ -d $BZ_PROFILES_PATH/$cluster ]]; then
    echo [INFO] Running diagnostics on "$cluster"
    cd "$BZ_PROFILES_PATH/$cluster" || exit 1
    echo DIAGS_ZIP_FILENAME="$cluster-diags.zip" "$BZ" diags
    DIAGS_ZIP_FILENAME=$cluster-diags.zip $BZ diags
    echo cp "$BZ_PROFILES_PATH/$cluster/.local/diags/$cluster-diags.zip" "$BZ_PROFILES_PATH/.diags/."
    cp "$BZ_PROFILES_PATH/$cluster/.local/$cluster-diags.zip" "$BZ_PROFILES_PATH/.diags/."
  fi
done
