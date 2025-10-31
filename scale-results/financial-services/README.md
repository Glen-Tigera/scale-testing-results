# Financial Services Scenario

## Overview

The Financial Services scenario tests Calico's performance with financial services workloads, which typically require strict network policies, compliance requirements, and high policy counts.

## Directory Structure

```
financial-services/
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

- Network policy scale (30k - 160k+ policies)
- Calico node startup performance
- Policy enforcement latency
- Compliance and security requirements
- High-policy-count scenarios

## Comparing Results

To compare results across dataplanes:
1. Navigate to a specific release (e.g., `v3.22-ep2/`)
2. Review the README in each dataplane directory for detailed metrics

To compare across releases:
1. Navigate to a specific dataplane directory
2. Compare results between `../v3.21-ep1/` and `../v3.22-ep2/`

## Key Metrics

- Calico node startup time (< 60s target)
- Network policy enforcement performance
- Policy scale limits
- Pod-to-pod latency under policy load

