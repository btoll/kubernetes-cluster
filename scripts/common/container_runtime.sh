#!/bin/bash

set -euo pipefail

LANG=C
umask 0022

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# DNS Setting
if [ ! -d /etc/systemd/resolved.conf.d ]; then
    mkdir /etc/systemd/resolved.conf.d/
fi
cat <<EOF | tee /etc/systemd/resolved.conf.d/dns_servers.conf
[Resolve]
DNS=8.8.8.8
EOF

systemctl restart systemd-resolved

# keeps the swap off during reboot
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true

# Forwarding IPv4 and letting iptables see bridged traffic.
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#forwarding-ipv4-and-letting-iptables-see-bridged-traffic
#cat <<EOF | tee /etc/modules-load.d/k8s.conf
cat <<EOF | tee /etc/modules-load.d/crio.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
#cat <<EOF | tee /etc/sysctl.d/k8s.conf
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sysctl --system

# Verify that the `br_netfilter` and `overlay` modules are loaded.
lsmod | grep br_netfilter
lsmod | grep overlay

# Verify that the `net.bridge.bridge-nf-call-iptables`, `net.bridge.bridge-nf-call-ip6tables`
# and `net.ipv4.ip_forward` system variables are set to 1 in your `sysctl` config.
sysctl \
    net.bridge.bridge-nf-call-iptables \
    net.bridge.bridge-nf-call-ip6tables \
    net.ipv4.ip_forward

# Install `cri-o` container runtime.
# https://github.com/cri-o/cri-o/blob/main/install.md#apt-based-operating-systems
# Get only the major and minor version numbers:
VERSION="$(echo $KUBERNETES_VERSION | grep -oE '[0-9]+\.[0-9]+')"
echo "deb \
    [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] \
    https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" \
    > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb \
    [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] \
    https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" \
    > "/etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list"

mkdir -p /usr/share/keyrings
curl -L \
    "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key" \
    | gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
curl -L \
    "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key" \
    | gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg

apt-get update
apt-get install -y \
    cri-o \
    cri-o-runc

#cat >> /etc/default/crio << EOF
#${ENVIRONMENT}
#EOF

systemctl daemon-reload
systemctl enable crio --now

