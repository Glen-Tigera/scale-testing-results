# Scale Testing Repository

This repository contains scale testing configurations, results, and automation for Calico scale testing across multiple scenarios, releases, and dataplane implementations.

## Repository Structure

```
.
├── profiles/          # Test profiles and configurations
├── scale-results/     # Test results and logs
└── scripts/           # Setup scripts and cronjobs
```

## Organization

The repository is organized by:
1. **Scenario** - The type of workload/test being run
2. **Release** - The Calico release version (e.g., v3.21-ep1, v3.22-ep2)
3. **Dataplane** - The dataplane implementation (ebpf, iptables, nftables)

## Scenarios

Six key scenarios are supported:

1. **Simulation** - Pod density and simulation workloads
2. **AI Workloads** - AI/ML workload testing with high pod counts
3. **Financial Services** - Financial services use cases with strict policies
4. **Platform Provider** - Platform providers with high services
5. **Edge Computing** - Edge computing deployments with small k8s clusters on the edge
6. **CI Runner** - CI/CD pipeline scale with high job counts

## Directory Descriptions

### profiles/

Contains Banzai test profiles and configurations used to provision and configure test clusters. Organized by scenario, release, and dataplane.

**Structure:** `profiles/{scenario}/{release}/{dataplane}/`

**See:** [profiles/README.md](profiles/README.md)

### scale-results/

Contains test results, logs, and metrics from scale tests. Organized by scenario, release, and dataplane to enable easy comparison.

**Structure:** `scale-results/{scenario}/{release}/{dataplane}/`

**See:** [scale-results/README.md](scale-results/README.md)

### scripts/

Contains setup scripts and Kubernetes CronJob definitions for automated testing. Each scenario has its own directory with setup scripts and cronjob YAMLs. Shared utilities are in the `shared/` subdirectory.

**Structure:** `scripts/{scenario}/` or `scripts/shared/`

**See:** [scripts/README.md](scripts/README.md)

### scale-results/

Legacy results directory. Content is being migrated to `results/` for consistency.

## Workflow

1. **Profile Setup** - Use profiles in `profiles/{scenario}/{release}/{dataplane}/` to provision test clusters
2. **Run Tests** - Execute tests using scripts and cronjobs from `scripts/{scenario}/`
3. **View Results** - Find results organized in `scale-results/{scenario}/{release}/{dataplane}/`

## Comparison Across Releases

To compare results between releases:

1. Navigate to `scale-results/{scenario}/`
2. Compare `v3.21-ep1/{dataplane}/` with `v3.22-ep2/{dataplane}/`
3. Review README files in each dataplane directory for detailed metrics

## Quick Start

```bash
# 1. Setup a test cluster
cd scripts/platform-provider/
./setup_scale_platform_provider_cluster.sh

# 2. Apply a cronjob for automated testing
kubectl apply -f scale-test-platform-provider-cronjob.yaml

# 3. Create a manual test run
kubectl create job test-run --from=cronjob/platform-provider-ttfp-test

# 4. View results
ls scale-results/platform-provider/v3.22-ep2/ebpf/
```

