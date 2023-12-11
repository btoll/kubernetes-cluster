#!/bin/bash

set -eo pipefail

LANG=C
umask 0022

if [ -z "$1" ]
then
    echo "[ERROR] You must provide a user name."
    echo "$0 USERNAME"
    exit 1
fi

NAME="$1"

if kubectl config get-users | grep --quiet "$NAME"
then
    echo "[ERROR] User \`$NAME\` already exists."
    exit 1
fi

read -p "Cluster role for user \`$NAME\`? [admin, edit, view] " ROLE

if ! ( [ "$ROLE" = admin ] || [ "$ROLE" = edit ] || [ "$ROLE" = view ] )
then
    echo "[ERROR] You must select a valid cluster role."
    exit 1
fi

openssl genpkey -out "$NAME.key" -algorithm ed25519
openssl req -new -key "$NAME.key" -out "$NAME.csr" -subj "/CN=$NAME/O=$ROLE"

cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $NAME
spec:
  request: $(base64 -w0 $NAME.csr)
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400
  usages:
  - client auth
EOF

kubectl certificate approve "$NAME"
kubectl get csr "$NAME" -o jsonpath="{.status.certificate}" | base64 -d > "$NAME.crt"
kubectl config set-credentials "$NAME" --client-key="$NAME.key" --client-certificate="$NAME.crt" --embed-certs=true
kubectl config set-context "$NAME" --cluster=kubernetes --user="$NAME"

kubectl create clusterrolebinding "$NAME" --user="$NAME" --clusterrole="$ROLE"

kubectl delete csr "$NAME"
rm "$NAME.csr"

