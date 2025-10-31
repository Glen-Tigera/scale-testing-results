# AI Workloads - v3.22 EP2 - eBPF Dataplane Results

## Test Configuration

- **Release**: v3.22 EP2
- **Dataplane**: eBPF
- **Kubernetes Version**: v1.33.5
- **Test Type**: AI/ML Workload Simulation

## Test Scenarios

This directory contains AI workload simulation results with varying fake node scales:

### Scale Tests
- 400 real nodes with:
  - 3,000 fake nodes
  - 5,000 fake nodes
  - 7,000 fake nodes
  - 8,000 fake nodes
  - 9,000 fake nodes
  - 10,000 fake nodes
  - 12,000 fake nodes
  - 14,000 fake nodes

## Key Metrics Measured

### Cluster Scale Performance
- Tests measure Calico's performance with AI/ML-style workloads
- High pod counts and complex networking requirements
- Fake nodes simulate large-scale AI training scenarios

### Performance Metrics
- Pod creation and deletion rates
- Network policy enforcement at scale
- Resource utilization

## Files in This Directory

- `default-calico-test-run-400-real-nodes-*-fake-nodes-ebpf-*.log` - AI workload test execution logs

## Results Summary

For detailed results, review individual log files. Key observations:

1. **Scale Limits**: Maximum fake nodes tested (14k fake nodes)
2. **Performance Characteristics**: How Calico handles AI/ML workload patterns
3. **Resource Efficiency**: Calico's resource usage at extreme scales

## AI Workload Characteristics

AI/ML workloads typically feature:
- High pod counts
- Rapid pod churn (training job lifecycles)
- Complex network policies
- High bandwidth requirements

These tests validate Calico's ability to handle such workloads efficiently.

## Comparison with Other Dataplanes

To compare across dataplanes:
- Review `../iptables/README.md` for iptables dataplane comparison
- Review `../nftables/README.md` for nftables dataplane comparison

eBPF dataplane is often preferred for AI workloads due to performance characteristics.

## Comparison with Other Releases

To compare with other releases:
- Compare with `../../v3.21-ep1/ebpf/README.md` for release-to-release comparison

## Notes

- Tests use a combination of real and fake nodes to simulate large-scale AI clusters
- Results help determine optimal configurations for AI/ML deployments
- eBPF dataplane is typically recommended for AI workloads

