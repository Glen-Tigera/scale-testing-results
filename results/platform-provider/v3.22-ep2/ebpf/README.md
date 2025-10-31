# Platform Provider - v3.22 EP2 - eBPF Dataplane Results

## Test Configuration

- **Release**: v3.22 EP2
- **Dataplane**: eBPF
- **Kubernetes Version**: v1.33.5
- **Encapsulation**: IPIP
- **BGP**: Enabled

## Test Scenarios

This directory contains Time-to-First-Packet (TTFP) test results for platform provider scenarios with varying service scales:

### Service Scale Tests
- 3k services
- 10k services
- 20k-25k services
- 26k-58k services

## Key Metrics Measured

### Time-to-First-Packet (TTFP)
- **Target**: < 4 seconds (99th percentile)
- Measures the time for the first packet to be processed after service creation

### Calico Node Startup Time
- **Target**: < 60 seconds
- Tests measure the time for a calico-node pod to become Ready after restart

### Cluster Scale Metrics
- Total NetworkPolicies
- Total Services
- Total Ready Nodes

### Performance Metrics
- Load generator statistics
- Request rates and latency
- Service endpoint response times

## Files in This Directory

- `default-scale-platform-provider-ttfp-test-run-*k-services-bpf-*.log` - TTFP test logs
- `scale-platform-provider-ttfp-test-run-*k-services-bpf.log` - Iterative scale test logs

## Results Summary

For detailed results, review individual log files. Key observations:

1. **TTFP Performance**: Time-to-first-packet measurements at various service scales
2. **Startup Performance**: Calico node startup times during scale tests
3. **Scale Limits**: Maximum services tested in iterative mode (up to 58k services)

## Test Methodology

Tests follow this pattern:
1. Scale services to target count
2. Clean up pods and wait for stabilization
3. Start test and measure TTFP
4. Collect load generator logs
5. Measure calico-node startup time (if NODE_NAME is configured)

## Comparison with Other Releases

To compare with other releases:
- Review `../iptables/README.md` for iptables dataplane comparison
- Review `../nftables/README.md` for nftables dataplane comparison
- Compare with `../../v3.21-ep1/ebpf/README.md` for release-to-release comparison

## Notes

- Tests can run in single-test mode (NUM_SERVICES) or iteration mode (START_ITER to END_ITER)
- Results include both successful and boundary condition tests
- TTFP measurements are taken from Prometheus metrics

