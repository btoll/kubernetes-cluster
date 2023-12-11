#!/bin/bash

# https://istio.io/latest/docs/setup/getting-started/
# https://github.com/istio/istio/releases/tag/1.19.0

#minikube start --nodes 4 --cpus 6 --memory 8192 --driver virtualbox
#istioctl install -y
#kubectl describe clusterrole edit

#https://github.com/GoogleCloudPlatform/microservices-demo/blob/main/release/kubernetes-manifests.yaml
#kubectl get ns default --show-labels
#kubectl label ns default istio-injection=enabled
#kubectl apply -f <(curl https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/main/release/kubernetes-manifests.yaml)

#kubectl apply -f /usr/local/istio-1.19.0/samples/addons/prometheus.yaml
#kubectl apply -f /usr/local/istio-1.19.0/samples/addons/grafana.yaml
#kubectl apply -f /usr/local/istio-1.19.0/samples/addons/grafana.yaml

#kubectl -n istio-system port-forward svc/grafana 3000
#localhost:3000

set -euo pipefail

LANG=C
umask 0022

curl -sLO https://github.com/istio/istio/releases/download/1.19.0/istio-1.19.0-linux-amd64.tar.gz.sha256
curl -sLO https://github.com/istio/istio/releases/download/1.19.0/istio-1.19.0-linux-amd64.tar.gz

if ! sha256sum --check --status istio-1.19.0-linux-amd64.tar.gz.sha256
then
    echo "[ERROR] Checksum failed."
    exit 1
fi

sudo tar -xzf istio-1.19.0-linux-amd64.tar.gz -C /usr/local
sudo chmod -R 0755 /usr/local/istio-1.19.0

sudo install --mode 0755 /usr/local/istio-1.19.0/bin/* /usr/local/bin

# Verify all prerequisites have been met (such as kubernetes version).
if ! istioctl x precheck
then
    echo "[ERROR] Istio prechecks failed."
    exit 1
fi

# istioctl install --set profile=demo -y
# istioctl verify-install
# kubectl label namespace default istio-injection=enabled

# Sample app.
# kubectl apply -f {istio installation}/samples/bookinfo/platform/kube/bookinfo.yaml
# istioctl analyze

# Install grafana, jaeger, prometheus and kiali.
# kubectl apply -f ./samples/addons/
# istioctl dashboard {kiali,prometheus,grafana}

# Check istio has a route to a proxy:
# istioctl proxy-config routes deploy/istio-ingressgateway.istio-system

