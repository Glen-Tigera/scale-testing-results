# Calico Node Startup Time Measurement Job

This Kubernetes Job measures the startup time of a calico-node DaemonSet pod by deleting an existing pod and timing how long it takes for the replacement pod to become Ready.

## Quick Start

1. **Edit the manifest** to set your target node name:
   ```bash
   # Open the file and find the NODE_NAME environment variable
   # Update it with your actual node name
   vim calico-node-startup-measurement-job.yaml
   ```

   Look for this section and update the `NODE_NAME` value:
   ```yaml
   env:
   - name: NODE_NAME
     value: ""  # CHANGE THIS to your target node name
   ```

2. **Apply the manifest**:
   ```bash
   kubectl apply -f calico-node-startup-measurement-job.yaml
   ```

3. **Watch the job progress**:
   ```bash
   # Watch job status
   kubectl get jobs calico-node-startup-test -w

   # Follow the logs
   kubectl logs -f job/calico-node-startup-test
   ```

## Quick Apply with Node Name Override

You can also set the node name directly when applying:

```bash
# Get a list of your nodes
kubectl get nodes

# Apply with a specific node
kubectl apply -f calico-node-startup-measurement-job.yaml
kubectl set env job/calico-node-startup-test NODE_NAME=your-node-name-here
```

Or use a one-liner with sed:

```bash
NODE_NAME="your-node-name-here"
sed "s/value: \"\" *# CHANGE THIS/value: \"$NODE_NAME\"/" calico-node-startup-measurement-job.yaml | kubectl apply -f -
```

## What Gets Created

The manifest creates:
- **ServiceAccount**: `calico-startup-tester` - Identity for the job
- **ClusterRole**: `calico-startup-tester` - Permissions to get/list/delete pods
- **ClusterRoleBinding**: Links the ServiceAccount to the ClusterRole
- **ConfigMap**: `calico-startup-test-script` - Contains the measurement script
- **Job**: `calico-node-startup-test` - Runs the test

## Configuration Options

You can customize the following environment variables in the Job spec:

| Variable | Default | Description |
|----------|---------|-------------|
| `NODE_NAME` | (required) | The node where calico-node should be tested |
| `NAMESPACE` | `calico-system` | Namespace where calico-node pods run |
| `LABEL_SELECTOR` | `k8s-app=calico-node` | Label selector for calico-node pods |
| `ACCEPTABLE_START_UP_TIME` | `60` | Maximum acceptable startup time in seconds |

## Success Criteria

The job succeeds (exit 0) if:
- The calico-node pod starts within the `ACCEPTABLE_START_UP_TIME`
- The pod becomes Ready

The job fails (exit 1) if:
- No calico-node pod is found on the specified node
- The pod takes longer than `ACCEPTABLE_START_UP_TIME` to become Ready
- Any kubectl command fails

## Viewing Results

```bash
# Check job status
kubectl get job calico-node-startup-test

# View logs
kubectl logs job/calico-node-startup-test

# Get detailed job info
kubectl describe job calico-node-startup-test
```

## Cleanup

The job is configured with `ttlSecondsAfterFinished: 600`, which means it will automatically be deleted 10 minutes after completion.

To manually clean up:

```bash
# Delete the job and its pods
kubectl delete job calico-node-startup-test

# Delete all resources (if you want to remove everything)
kubectl delete -f calico-node-startup-measurement-job.yaml
```

## Running Multiple Tests

To run the test on multiple nodes:

```bash
# Create unique jobs for each node
for NODE in $(kubectl get nodes -o name | cut -d/ -f2); do
  sed "s/name: calico-node-startup-test/name: calico-node-startup-test-${NODE}/" \
      calico-node-startup-measurement-job.yaml | \
  sed "s/value: \"\" *# CHANGE THIS/value: \"${NODE}\"/" | \
  kubectl apply -f -
done
```

## Troubleshooting

**Job fails immediately:**
- Check if NODE_NAME is set correctly
- Verify the node name exists: `kubectl get nodes`
- Check RBAC permissions: `kubectl auth can-i delete pods --as=system:serviceaccount:default:calico-startup-tester`

**Pod not found error:**
- Verify calico-node is running: `kubectl get pods -n calico-system -l k8s-app=calico-node`
- Check the namespace and label selector match your installation

**Permission denied:**
- Ensure the ClusterRole and ClusterRoleBinding were created successfully
- Check: `kubectl get clusterrole calico-startup-tester`

## Example Output

```
=== Calico Node Startup Time Measurement ===
Namespace: calico-system
Label Selector: k8s-app=calico-node
Target Node: node-1
Acceptable Startup Time: 60s

Found pod: calico-node-abc123 on node node-1
Deleting pod calico-node-abc123...
Waiting for new pod on node node-1...
New pod detected: calico-node-xyz789
Pod created at: 2025-10-21T10:15:30Z (epoch: 1729504530)
Waiting for pod calico-node-xyz789 to become Ready...
pod/calico-node-xyz789 condition met

========================================
DaemonSet pod calico-node-xyz789 became Ready in 12 seconds.
Calico-node startup time: 12s
========================================

✅ SUCCESS: calico-node-xyz789 startup time is within the acceptable range (12 seconds < 60s)
```

