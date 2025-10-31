# Scale Test Profiles

This directory contains the test profiles and configurations used to run scale tests for each scenario, organized by scenario, release version, and dataplane.

## Directory Structure

```
profiles/
├── simulation/
├── ai-workloads/
├── financial-services/
├── platform-provider/
├── edge-computing/
└── ci-runner/
```

Each scenario contains subdirectories for each release version (e.g., `v3.21-ep1`, `v3.22-ep2`), and within each release, profiles are organized by dataplane where applicable:

- `ebpf/` - eBPF dataplane profiles
- `iptables/` - iptables dataplane profiles
- `nftables/` - nftables dataplane profiles

For v3.21-ep1, profiles are typically organized at the release level without dataplane subdirectories, as dataplane selection was handled differently in that release.

## Profile Contents

Each profile directory typically contains:

- `manifests/` - Kubernetes manifests for test workloads
- `addons/` - Addon configurations
- `scripts/` - Test execution scripts
- `dependencies/` - Dependency definitions
- `installers/` - Installation scripts
- `provisioners/` - Cluster provisioning configurations
- `tests/` - Test definitions
- `Taskfile.yml` - Task runner configuration
- `Taskvars.yml` - Task variables
- `README.md` - Profile-specific documentation

## Using Profiles

1. Navigate to the scenario and release you want to test (e.g., `platform-provider/v3.22-ep2/`)
2. Review the `README.md` for profile-specific instructions
3. Use the `Taskfile.yml` and `Taskvars.yml` to configure and run tests
4. Results will be generated in the corresponding `results/` directory

## Relationship to Results

Profiles in this directory are used to generate the test results stored in the `results/` directory. The structure mirrors the results organization to make it easy to find the configuration used for any given test result.

- Profile: `profiles/platform-provider/v3.22-ep2/ebpf/`
- Results: `results/platform-provider/v3.22-ep2/ebpf/`

