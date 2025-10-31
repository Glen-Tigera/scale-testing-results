# Simulation - v3.22 EP2 - eBPF Dataplane Results

## Test Configuration

- **Release**: v3.22 EP2
- **Dataplane**: eBPF
- **Test Type**: Pod Density Simulation

## Test Scenarios

This directory contains pod density simulation results testing Calico's ability to handle various pods-per-node configurations:

### Pod Density Tests
- 200 pods per node
- 400 pods per node
- 600 pods per node
- 800 pods per node
- 900 pods per node

## Key Metrics Measured

### Pod Creation Performance
- Tests measure Calico's performance as pod density increases
- Results show scalability limits and performance characteristics

### Cluster Behavior
- Node resource utilization
- Network policy enforcement at scale
- Pod networking performance

## Files in This Directory

- `default-calico-test-run-*-pods-per-node-bpf-*.log` - Pod density test execution logs

## Results Summary

For detailed results, review individual log files. Tests progressively increase pod density to identify:
1. **Performance Thresholds**: Maximum pods per node that maintain acceptable performance
2. **Resource Usage**: How Calico components behave under high pod density
3. **Scalability Limits**: Point at which performance degrades

## Comparison with Other Dataplanes

To compare across dataplanes:
- Review `../iptables/README.md` for iptables dataplane comparison
- Review `../nftables/README.md` for nftables dataplane comparison

Different dataplanes may show different optimal pod densities.

## Comparison with Other Releases

To compare with other releases:
- Compare with `../../v3.21-ep1/ebpf/README.md` for release-to-release comparison

## Notes

- Simulation tests focus on pod density rather than network policies
- Results help determine optimal pod-per-node ratios for different dataplanes
- Tests are designed to identify performance degradation points

