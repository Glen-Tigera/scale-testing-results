# Edge Computing Scenario

## Overview

The Edge Computing scenario tests Calico's performance in edge computing deployments with distributed nodes and edge-specific network requirements.

## Directory Structure

```
edge-computing/
├── v3.21-ep1/
│   ├── ebpf/
│   ├── iptables/
│   └── nftables/
└── v3.22-ep2/
    ├── ebpf/
    ├── iptables/
    └── nftables/
```

## Test Focus Areas

- Distributed edge node performance
- Edge-specific networking requirements
- Low-latency networking
- Edge node connectivity
- Resource-constrained environments

## Comparing Results

To compare results across dataplanes:
1. Navigate to a specific release (e.g., `v3.22-ep2/`)
2. Review the README in each dataplane directory

To compare across releases:
1. Navigate to a specific dataplane directory
2. Compare performance and capabilities between releases

## Key Metrics

- Edge node connectivity performance
- Network policy enforcement at edge
- Resource efficiency
- Low-latency networking capabilities

