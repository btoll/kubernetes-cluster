#!/bin/bash

set -euo pipefail

LANG=C
umask 0022

# Install Go.
wget -O- https://go.dev/dl/go1.21.0.linux-amd64.tar.gz \
    | tar -xzf - -C /usr/local

echo 'PATH=/usr/local/go/bin:$PATH' >> /root/.bashrc

sudo --login --user vagrant bash << EOF
echo 'PATH=/usr/local/go/bin:$PATH' >> /home/vagrant/.bashrc
EOF

# Install Helm.
curl https://baltocdn.com/helm/signing.asc \
    | gpg --dearmor  \
    > /usr/share/keyrings/helm.gpg

echo "deb \
    [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] \
    https://baltocdn.com/helm/stable/debian/ all main" \
    | tee /etc/apt/sources.list.d/helm-stable-debian.list

apt-get update
apt-get install -y helm

# Install Redis.
#helm repo add bitnami https://charts.bitnami.com/bitnami
#helm repo update
#helm install my-redis bitnami/redis

# Install Prometheus.
#helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
#helm repo update
#helm install prometheus prometheus-community/kube-prometheus-stack

