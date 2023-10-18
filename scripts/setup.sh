#!/bin/bash

set -euo pipefail

LANG=C
umask 0022

swapoff -a

apt-get update && \
apt-get install -y \
    build-essential \
    curl \
    git \
    gnupg2 \
    wget

# Fixes the "-bash: warning: setlocale: LC_ALL: cannot change locale (en_IN.UTF-8)" warning.
# Also, fixes the same warnings for Perl.
localedef -i en_US -f UTF-8 en_US.UTF-8

# Local hostname resolution.
echo "$NETWORK$HOST master" >> /etc/hosts
for i in $(seq "${WORKERS}")
do
    echo "$NETWORK$((HOST+i)) worker${i}" >> /etc/hosts
done

echo "alias k=kubectl" >> "$HOME/.bashrc"

sudo --login --user vagrant bash << EOF
echo "alias k=kubectl" >> /home/vagrant/.bashrc
EOF

