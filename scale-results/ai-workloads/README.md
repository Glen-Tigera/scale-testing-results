# AI Workloads Scenario

## Overview

The AI Workloads scenario tests Calico's performance with AI/ML workloads, which typically involve high pod counts, rapid pod churn, complex network policies, and high bandwidth requirements.

## Directory Structure

```
ai-workloads/
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

- Large-scale cluster performance (400 real nodes + up to 14k fake nodes)
- AI/ML workload patterns
- High pod counts
- Rapid pod lifecycle management
- Complex networking at scale

## Comparing Results

To compare results across dataplanes:
1. Navigate to a specific release (e.g., `v3.22-ep2/`)
2. Review the README in each dataplane directory

To compare across releases:
1. Navigate to a specific dataplane directory
2. Compare scale limits and performance characteristics

## Key Metrics

- Maximum fake nodes supported
- Cluster scale performance
- Resource efficiency at extreme scales
- Pod management performance

## Note

eBPF dataplane is typically preferred for AI workloads due to its performance characteristics.

