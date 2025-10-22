## BPF Setup

bz init profile -n scale-simulation-cluster --additionals "CLUSTER_NODES=5,CLUSTER_IMAGE=ubuntu-2404-lts-amd64,GOOGLE_MASTER_MACHINE_TYPE=n2-standard-8,GOOGLE_NODE_MACHINE_TYPE=n2-standard-4,GOOGLE_INFRA_MACHINE_TYPE=n2-standard-4,GOOGLE_RR_MACHINE_TYPE=n2-standard-2,GOOGLE_ETCD_MACHINE_TYPE=n2-standard-2,NUM_INFRA_NODES=3,CRC_PODS_PER_NODE=3000" --product calient --provisioner gcp-kubeadm --dataplane CalicoBPF --release-stream v3.22 --hashrelease true --installer operator --k8sversion stable-1

## Switch to IPTables
kubectl patch installation.operator.tigera.io default --type merge -p '{"spec":{"calicoNetwork":{"linuxDataplane":"Iptables"}}}'

kubectl patch ds -n kube-system kube-proxy --type merge -p '{"spec":{"template":{"spec":{"nodeSelector":{"non-calico": null}}}}}'


bz provision

bz install

kubectl apply -f ../manifests

