#!/usr/bin/env bash

set -e

BZ_PROFILES_PATH=${BZ_PROFILES_PATH:=$HOME/bzprofiles}

bash mcm-init.sh
bash mcm-provision.sh
