#!/usr/bin/env bash
set -eufo pipefail

TOKEN=$(kubectl -n kubernetes-dashboard describe secret admin-user-token | grep '^token' | awk '{ print $2 }')

echo "Use this token to access the web ui"
echo $TOKEN

open http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
kubectl proxy
