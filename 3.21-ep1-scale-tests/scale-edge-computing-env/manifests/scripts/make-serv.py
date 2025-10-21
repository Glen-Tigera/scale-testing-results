#!/usr/bin/env python

import argparse
parser = argparse.ArgumentParser(description='Create services.yaml with a configurable number of services in it.')
parser.add_argument('start_serv_num', type=int, help='Number of first service.')
parser.add_argument('end_serv_num', type=int, help='Number of last service.')
args = parser.parse_args()

for i in range(args.start_serv_num, args.end_serv_num):
    service = """apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx%s
  namespace: addon-live-policies
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80""" % i
    print(service)
    if i != args.end_serv_num:
        print("---")
