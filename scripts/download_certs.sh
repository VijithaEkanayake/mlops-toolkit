#!/usr/bin/env bash

set -eo pipefail

WORKING_DIR=.
CERTS_DIR=$WORKING_DIR/certs

mkdir -p "$CERTS_DIR"

# Validate inputs.
[ $# -ne 2 ] && { echo "Usage: $0 [MLOPS_PREFIX] [MLOPS_K8_NAMESPACE]"; exit 1; }
[ "$TRACE" ] && set -x
read -r MLOPS_PREFIX MLOPS_K8_NAMESPACE <<<"$@"

certPath=$CERTS_DIR/certificate
keyPath=$CERTS_DIR/key
caPath=$CERTS_DIR/ca

kubectl get secret "$MLOPS_PREFIX"-tls-monitoring-app-backend --namespace "$MLOPS_K8_NAMESPACE" -o json > log_cert &&
  kubectl get secret "$MLOPS_PREFIX"-tls-monitoring-app-backend --namespace "$MLOPS_K8_NAMESPACE" -o json > log_key &&
  kubectl get secret "$MLOPS_PREFIX"-tls-monitoring-app-backend --namespace "$MLOPS_K8_NAMESPACE" -o json > log_ca &&
  cat log_cert | jq -r '.data."tls.crt"' | base64 -d > $certPath &&
  cat log_key | jq -r '.data."tls.key"' | base64 -d > $keyPath &&
  cat log_ca | jq -r '.data."ca.crt"' | base64 -d > $caPath &&
  echo "### Certificates were downloaded successfully to ${CERTS_DIR} ###"
