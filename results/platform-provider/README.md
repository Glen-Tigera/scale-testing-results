# Platform Provider Scenario

## Overview

The Platform Provider scenario tests Calico's performance in multi-tenant environments with various service scales, measuring Time-to-First-Packet (TTFP) and service endpoint performance.

## Directory Structure

```
platform-provider/
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

- Time-to-First-Packet (TTFP) performance (< 4s target)
- Service scale testing (3k - 58k+ services)
- Multi-tenant networking
- Service endpoint response times
- Calico node startup during scale operations

## Comparing Results

To compare results across dataplanes:
1. Navigate to a specific release (e.g., `v3.22-ep2/`)
2. Review the README in each dataplane directory for TTFP metrics

To compare across releases:
1. Navigate to a specific dataplane directory
2. Compare TTFP results and scale limits between releases

## Key Metrics

- TTFP 99th percentile (< 4s target)
- Calico node startup time (< 60s target)
- Maximum service count tested
- Load generator performance metrics

