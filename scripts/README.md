# Scripts and CronJobs Directory

This directory contains scripts and Kubernetes CronJob definitions for setting up and managing scale test clusters, organized by scenario.

## Directory Structure

```
scripts/
├── simulation/              # Simulation scenario scripts and cronjobs
├── ai-workloads/            # AI workload scenario scripts and cronjobs
├── financial-services/      # Financial services scenario scripts and cronjobs
├── platform-provider/       # Platform provider scenario scripts and cronjobs
├── edge-computing/          # Edge computing scenario scripts and cronjobs
├── ci-runner/               # CI runner scenario scripts and cronjobs
├── shared/                  # Shared utilities used across scenarios
│   ├── measure_calico_node_pod_startup.sh  # General utility script
│   └── fix-etcd-space.sh                   # General utility script
├── CALICO_STARTUP_TEST_USAGE.md        # Documentation
└── README.md                # This file
```

## Script Files

### Scenario-Specific Scripts

Each scenario directory contains:
- `setup_scale_*_cluster.sh` - Scripts for provisioning and setting up test clusters
- `scale-test-*-cronjob.yaml` - Kubernetes CronJob definitions for automated testing

### Shared Scripts

Scripts in the `shared/` directory are used across multiple scenarios:
- `shared/measure_calico_node_pod_startup.sh` - Measures Calico node startup time
- `shared/fix-etcd-space.sh` - Utilities for managing etcd storage

## Usage

### Running Setup Scripts

```bash
# Navigate to scenario directory
cd scripts/platform-provider/

# Review and execute setup script
./setup_scale_platform_provider_cluster.sh
```

### Applying CronJobs

```bash
# Apply a cronjob for a specific scenario
kubectl apply -f scripts/platform-provider/scale-test-platform-provider-cronjob.yaml
```

### Creating a Manual Job from CronJob

```bash
# Create a one-time job from a cronjob
kubectl create job <job-name> --from=cronjob/<cronjob-name>
```

### Example Workflow

For platform provider tests:
```bash
# 1. Setup cluster
cd scripts/platform-provider/
./setup_scale_platform_provider_cluster.sh

# 2. Apply cronjob
kubectl apply -f scale-test-platform-provider-cronjob.yaml

# 3. Create manual job (if needed)
kubectl create job test-run-20k-services --from=cronjob/platform-provider-ttfp-test
```

## Configuration

CronJobs are typically configured with:
- Schedule (usually suspended by default for manual execution)
- Resource limits
- Test parameters via environment variables
- Result storage locations matching the `results/` directory structure

## Future Organization

As scripts and cronjobs become release-specific or dataplane-specific, they can be organized further:
- `scripts/{scenario}/{release}/` - For release-specific files
- `scripts/{scenario}/{release}/{dataplane}/` - For dataplane-specific files
