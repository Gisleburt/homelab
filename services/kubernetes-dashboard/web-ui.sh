#!/usr/bin/env bash
set -eufo pipefail

echo "I've not worked out how to do this with docker yet, you'll need kubectl installed locally"

KUBECONFIG="$( dirname "${BASH_SOURCE[0]}" )/../../k3s-config.yaml"
export KUBECONFIG
TOKEN=$(\
  kubectl -n kubernetes-dashboard describe secret admin-user-token \
  | grep '^token' \
  | awk '{ print $2 }' \
)

echo "Copying token to clipboard"
echo $TOKEN | pbcopy

kubectl proxy &
PID=$!

open http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

echo Press space to quit
read -s -d ' '

echo Closing proxy
kill $PID
