#!/bin/bash

set -ex

kubectl patch felixconfiguration default --type='merge' -p '{"spec":{"debugPort": 6060, "debugHost":"0.0.0.0"}}'
sleep 10  # for Felix to startup with debug server available

NODEIP=$(yq r ../Taskvars.yml NODE_CONNECT_COMMANDS_0 | awk '{print $8}' | cut -d '@' -f2)
curl -o mem.pprof "http://${NODEIP}:6060/debug/pprof/heap"
curl -o cpu.pprof "http://${NODEIP}:6060/debug/pprof/profile?seconds=30"
curl -o trace.out "http://${NODEIP}:6060/debug/pprof/trace?seconds=5"

kubectl patch felixconfiguration default --type='merge' -p '{"spec":{"debugPort": null, "debugHost": null}}'
