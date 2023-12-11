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

# Install Calico Network Plugin.
kubectl apply -f "https://raw.githubusercontent.com/projectcalico/calico/v$CALICO_VERSION/manifests/calico.yaml"

# Install Flannel Network Plugin.
# https://github.com/flannel-io/flannel
#kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Install Metrics Server.
kubectl apply -f https://raw.githubusercontent.com/techiescamp/kubeadm-scripts/main/manifests/metrics-server.yaml

# TODO: Install using helm to avoid version pinning.

# Install MetalLB load balancer.
# https://metallb.universe.tf/installation/
#kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.11/config/manifests/metallb-native.yaml

# https://metallb.universe.tf/configuration/#layer-2-configuration
#kubectl apply -f /vagrant/manifests/ipaddresspool.yaml

# Install nginx Ingress Controller.
# https://kubernetes.github.io/ingress-nginx/deploy/#quick-start
#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

