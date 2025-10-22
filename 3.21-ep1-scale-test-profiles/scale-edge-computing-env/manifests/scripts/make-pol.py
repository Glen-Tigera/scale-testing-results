#!/usr/bin/env python

import argparse
parser = argparse.ArgumentParser(description='Create policies.yaml with a configurable number of policies in it.')
parser.add_argument('start_pol_num', type=int, help='Number of first policy.')
parser.add_argument('end_pol_num', type=int, help='Number of last policy.')
args = parser.parse_args()

for i in range(args.start_pol_num, args.end_pol_num):
    policy = f"""
apiVersion: v1
kind: Namespace
metadata:
  name: test-ns-{i}
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  namespace: test-ns-{i}
spec:
  containers:
  - name: nginx
    image: bitnami/nginx:1.18
    ports:
    - containerPort: 80
  tolerations:
    - key: "mocklet.io/provider"
      operator: "Equal"
      value: "mock"
      effect: "NoSchedule"
  nodeSelector:
    type: mocklet
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  labels:
    type: testpol
  name: testpol
  namespace: test-ns-{i}
spec:
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
        - 192.168.0.0/16
        - 10.0.0.0/8
        - 1.2.3.4/32
        - 5.6.7.8/32
        - 9.10.11.12/32
        - 12.34.5.6/32
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: test-ns-{i}
  - ports:
    - port: 53
      protocol: TCP
    - port: 53
      protocol: UDP
    to:
    - ipBlock:
        cidr: 10.96.0.10/32
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
      podSelector:
        matchLabels:
          k8s-app: kube-dns
  - ports:
    - port: 53
      protocol: TCP
    - port: 53
      protocol: UDP
    to:
    - ipBlock:
        cidr: 169.245.1.1/32
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
      podSelector:
        matchLabels:
          k8s-app: kube-dns
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: test-ns-{i}
  podSelector: {{}}
  policyTypes:
  - Ingress
  - Egress"""
    print(policy)
    if i != args.end_pol_num - 1:
        print("---")
