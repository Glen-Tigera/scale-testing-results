# Simulation Scenario

## Overview

The Simulation scenario tests Calico's performance under various pod density configurations. These tests help determine optimal pods-per-node ratios and identify performance degradation points.

## Directory Structure

```
simulation/
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

- Pod density limits
- Pod creation/deletion performance
- Resource utilization at scale
- Network policy enforcement with high pod counts

## Comparing Results

To compare results across dataplanes:
1. Navigate to a specific release (e.g., `v3.22-ep2/`)
2. Review the README in each dataplane directory:
   - `ebpf/README.md`
   - `iptables/README.md`
   - `nftables/README.md`

To compare across releases:
1. Navigate to a specific dataplane (e.g., `ebpf/`)
2. Compare `../v3.21-ep1/ebpf/` with `../v3.22-ep2/ebpf/`

## Key Metrics

- Maximum pods per node supported
- Pod creation rate
- Resource consumption
- Performance degradation thresholds

