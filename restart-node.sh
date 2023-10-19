#!/usr/bin/env sh
set -e

. ./aliases.sh

NUMBER=$1

NODE=$(kubectl get nodes | tail -n +2 | awk '{ print $1 }' | rg "${NUMBER}")

echo
echo "Cordoning: ${NODE}"
echo "========="
kubectl cordon "$NODE"

echo
echo "Draining: ${NODE}"
echo "========"
kubectl drain "${NODE}" --grace-period=60 --force --delete-emptydir-data --ignore-daemonsets

echo
echo "Restarting: ${NODE}"
echo "=========="
ansible "10.4.0.${NUMBER}" -i hosts -m reboot -b

echo
echo "Uncordoning: ${NODE}"
echo "==========="
kubectl uncordon "${NODE}"
