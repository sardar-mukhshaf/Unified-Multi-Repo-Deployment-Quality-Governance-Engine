#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${cluster_name} \
  --b64-cluster-ca ${cluster_ca_cert} \
  --apiserver-endpoint ${cluster_endpoint} \
  --dns-cluster-ip 10.100.0.10 \
  --use-max-pods true \
  --node-ip $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
