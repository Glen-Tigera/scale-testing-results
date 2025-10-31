# Scale Testing Results

This directory contains scale testing results organized by scenario, release version, and dataplane implementation.

## Directory Structure

```
results/
├── simulation/
├── ai-workloads/
├── financial-services/
├── platform-provider/
├── edge-computing/
└── ci-runner/
```

Each scenario contains subdirectories for each release version (e.g., `v3.21-ep1`, `v3.22-ep2`), and within each release, results are organized by dataplane:

- `ebpf/` - eBPF dataplane results
- `iptables/` - iptables dataplane results
- `nftables/` - nftables dataplane results

## Scenarios

### Simulation
Tests focused on pod density and simulation workloads to measure Calico's performance under various pod-per-node configurations.

### AI Workloads
Tests designed to measure Calico's performance with AI/ML workloads, typically involving high pod counts and network policy complexity.

### Financial Services
Tests targeting financial services use cases with strict network policies and compliance requirements.

### Platform Provider
Tests for platform provider scenarios, measuring Calico's behavior in multi-tenant environments with various service scales.

### Edge Computing
Tests focused on edge computing deployments with distributed nodes and edge-specific network requirements.

### CI Runner
Tests measuring Calico's performance in CI/CD pipeline scenarios with rapid pod creation and deletion.

## Comparing Results Across Releases

To compare results between releases:

1. Navigate to the scenario directory (e.g., `financial-services/`)
2. Open the README file in each release's dataplane directory (e.g., `v3.22-ep2/ebpf/README.md`)
3. Compare metrics, performance data, and test outcomes documented in each README

Each dataplane directory contains a README with:
- Test configuration
- Key metrics and results
- Performance comparisons
- Notable observations or issues

## File Naming Convention

Log files are typically named with:
- Test name/description
- Dataplane type (ebpf/iptables/nftables)
- Pod/job identifier
- Timestamp

Example: `default-calico-test-run-100k-policies-ebpf-95sdt-1761344864432943046.log`

