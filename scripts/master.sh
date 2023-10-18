#!/bin/bash

set -euo pipefail

LANG=C
umask 0022

#kubeadm config images pull --cri-socket="/var/run/crio/crio.sock"
kubeadm config images pull

#    --cri-socket="/var/run/crio/crio.sock" \
kubeadm init \
    --apiserver-advertise-address="$CONTROL_PLANE_IP" \
    --apiserver-cert-extra-sans="$CONTROL_PLANE_IP" \
    --node-name=$(hostname -s) \
    --pod-network-cidr="$POD_CIDR" \
    --service-cidr="$SERVICE_CIDR" \
    --ignore-preflight-errors Swap

CONFIG_DIR=/vagrant/configs
mkdir -p "$CONFIG_DIR" "$HOME/.kube"
cp /etc/kubernetes/admin.conf "$CONFIG_DIR/kubeconfig"
cp /etc/kubernetes/admin.conf "$HOME/.kube/config"
kubeadm token create --print-join-command > "$CONFIG_DIR/join.sh"
chmod +x "$CONFIG_DIR/join.sh"

sudo --login --user vagrant bash << EOF
whoami
mkdir -p /home/vagrant/.kube
cp -i "$CONFIG_DIR/kubeconfig" /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
EOF

# Install Calico Network Plugin
curl -O "https://raw.githubusercontent.com/projectcalico/calico/v$CALICO_VERSION/manifests/calico.yaml"
kubectl apply -f calico.yaml

# Install Metrics Server
kubectl apply -f https://raw.githubusercontent.com/techiescamp/kubeadm-scripts/main/manifests/metrics-server.yaml

