# CI Runner Scenario

## Overview

The CI Runner scenario tests Calico's performance in CI/CD pipeline scenarios with rapid pod creation and deletion, measuring how Calico handles high pod churn rates typical in continuous integration environments.

## Directory Structure

```
ci-runner/
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

- Rapid pod lifecycle management
- High pod churn rates
- CI/CD pipeline performance
- Quick pod provisioning
- Resource cleanup efficiency

## Comparing Results

To compare results across dataplanes:
1. Navigate to a specific release (e.g., `v3.22-ep2/`)
2. Review the README in each dataplane directory

To compare across releases:
1. Navigate to a specific dataplane directory
2. Compare pod lifecycle performance between releases

## Key Metrics

- Pod creation rate
- Pod deletion efficiency
- Resource cleanup time
- CI pipeline throughput
- Network provisioning speed

