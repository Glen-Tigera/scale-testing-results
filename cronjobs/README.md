# CronJobs Directory

This directory contains Kubernetes CronJob definitions for automated scale testing, organized by scenario.

## Directory Structure

```
cronjobs/
├── simulation/
│   └── shared/          # Simulation scenario cronjobs
├── ai-workloads/
│   └── shared/          # AI workload scenario cronjobs
├── financial-services/
│   └── shared/          # Financial services scenario cronjobs
├── platform-provider/
│   └── shared/          # Platform provider scenario cronjobs
├── edge-computing/
│   └── shared/          # Edge computing scenario cronjobs
├── ci-runner/
│   └── shared/          # CI runner scenario cronjobs
└── shared/              # Shared documentation and utilities
```

## CronJob Files

Each scenario directory contains:
- `scale-test-{scenario}-cronjob.yaml` - CronJob definition for automated testing

## Shared Documentation

The `shared/` directory contains:
- `CALICO_STARTUP_TEST_USAGE.md` - Documentation for Calico startup test cronjobs

## Usage

### Applying a CronJob

```bash
kubectl apply -f cronjobs/{scenario}/shared/scale-test-{scenario}-cronjob.yaml
```

### Creating a Manual Job from CronJob

```bash
kubectl create job <job-name> --from=cronjob/<cronjob-name>
```

### Example

For platform provider tests:
```bash
kubectl apply -f cronjobs/platform-provider/shared/scale-test-platform-provider-cronjob.yaml
kubectl create job test-run-20k-services --from=cronjob/platform-provider-ttfp-test
```

## Configuration

Each CronJob is configured with:
- Schedule (typically suspended by default)
- Resource limits
- Test parameters via environment variables
- Result storage locations

## Future Organization

As cronjobs become release-specific or dataplane-specific, they can be organized further:
- `cronjobs/{scenario}/{release}/` - For release-specific cronjobs
- `cronjobs/{scenario}/{release}/{dataplane}/` - For dataplane-specific cronjobs

