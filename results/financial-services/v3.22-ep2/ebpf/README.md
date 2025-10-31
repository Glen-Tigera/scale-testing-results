# Financial Services - v3.22 EP2 - eBPF Dataplane Results

## Test Configuration

- **Release**: v3.22 EP2
- **Dataplane**: eBPF
- **Kubernetes Version**: v1.33.5
- **Encapsulation**: IPIP
- **BGP**: Enabled

## Test Scenarios

This directory contains test results for financial services workloads with varying network policy scales:

### Network Policy Scale Tests
- 30k policies
- 100k policies
- 120k policies
- 130k policies
- 140k policies
- 160k policies

## Key Metrics Measured

### Calico Node Startup Time
- **Target**: < 60 seconds
- Tests measure the time for a calico-node pod to become Ready after restart

### Cluster Scale Metrics
- Total NetworkPolicies
- Total Services
- Total Ready Nodes

### Performance Metrics
- Pod-to-pod latency statistics
- Request rates and failure rates
- Load generator statistics

## Files in This Directory

- `default-calico-test-run-*k-policies-ebpf-*.log` - Test execution logs for different policy scales
- `tigera-elasticsearch-*.log` - Elasticsearch component logs
- `calico-system-calico-node-*.log` - Calico node component logs
- `tigerastatus-*.yaml` - Tigera status snapshots at different scales
- `ebpf.zip` - Compressed archive of all results

## Results Summary

For detailed results, review individual log files. Key observations:

1. **Startup Performance**: Calico node startup times at various network policy scales
2. **Latency Metrics**: Pod-to-pod communication latency under load
3. **Scale Limits**: Maximum network policies tested (160k in this release)

## Comparison with Other Releases

To compare with other releases:
- Review `../iptables/README.md` for iptables dataplane comparison
- Review `../nftables/README.md` for nftables dataplane comparison
- Compare with `../../v3.21-ep1/ebpf/README.md` for release-to-release comparison

## Notes

- All tests were run on clusters with 500+ nodes
- Results include both successful and boundary condition tests
- Load generator statistics are included for performance analysis

