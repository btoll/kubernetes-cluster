#!/bin/bash

set -euo pipefail

LANG=C
umask 0022

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# Install `kubeadm`, `kubelet` and `kubectl`.
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl

curl -fsSL https://dl.k8s.io/apt/doc/apt-key.gpg \
    | gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg

echo "deb \
    [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
    https://apt.kubernetes.io/ kubernetes-xenial main" \
    | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y \
    etcd-client \
    kubeadm="$KUBERNETES_VERSION" \
    kubectl="$KUBERNETES_VERSION" \
    kubelet="$KUBERNETES_VERSION"

apt-mark hold \
    kubeadm \
    kubectl \
    kubelet

local_ip="$(ip --json a s | jq -r '.[] | if .ifname == "eth1" then .addr_info[] | if .family == "inet" then .local else empty end else empty end')"
cat > /etc/default/kubelet << EOF
KUBELET_EXTRA_ARGS=--node-ip=$local_ip
EOF

