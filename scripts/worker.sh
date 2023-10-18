#!/bin/bash

set -euo pipefail

LANG=C
umask 0022

CONFIG_DIR=/vagrant/configs

/bin/bash "$CONFIG_DIR/join.sh" -v

sudo --login --user vagrant bash << EOF
whoami
mkdir -p /home/vagrant/.kube
cp -i "$CONFIG_DIR/kubeconfig" /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
# https://v1-27.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#managed-node-labels
kubectl label node $(hostname -s) node-role.kubernetes.io/worker=worker
EOF

