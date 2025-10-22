## BPF Setup for Simulation Scenario
bz init profile -n scale-ai-workload-cluster --additionals "CLUSTER_NODES=5,CLUSTER_IMAGE=ubuntu-2404-lts-amd64,GOOGLE_MASTER_MACHINE_TYPE=n2-standard-8,GOOGLE_NODE_MACHINE_TYPE=n2-standard-4,GOOGLE_INFRA_MACHINE_TYPE=n2-standard-4,GOOGLE_RR_MACHINE_TYPE=n2-standard-2,GOOGLE_ETCD_MACHINE_TYPE=n2-standard-2,NUM_INFRA_NODES=3,CRC_PODS_PER_NODE=3000" --product calient --provisioner gcp-kubeadm --dataplane CalicoBPF --release-stream v3.22 --hashrelease true --installer operator --k8sversion stable-1

bz provision

bz install

kubectl apply -f ../manifests

## Apply cronjob
kubectl apply -f ../jobs/calico-node-startup-measurement-job.yaml

## Scale NGINX
kubectl scale deployment nginx --replicas=1000 -n default

## Create job from cronjob
kubectl create job calico-test-run-1000-pods-per-node-nftables --from=cronjob/calico-node-startup-test

## Switch to IPTables
kubectl patch installation.operator.tigera.io default --type merge -p '{"spec":{"calicoNetwork":{"linuxDataplane":"Iptables"}}}'

## Switch to Nftables
kubectl patch installation.operator.tigera.io default --type merge -p '{"spec":{"calicoNetwork":{"linuxDataplane":"Nftables"}}}'

# Re-enable kube-proxy
kubectl patch ds -n kube-system kube-proxy --type merge -p '{"spec":{"template":{"spec":{"nodeSelector":{"non-calico": null}}}}}'
