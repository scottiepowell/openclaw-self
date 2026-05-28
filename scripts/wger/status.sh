#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="fitness"
RELEASE="wger"

echo '== Pods =='
kubectl get pods -n "$NAMESPACE" -o wide
echo
echo '== Services =='
kubectl get svc -n "$NAMESPACE"
echo
echo '== PVCs =='
kubectl get pvc -n "$NAMESPACE"
echo
echo '== PVs =='
kubectl get pv
echo
echo '== Helm status =='
helm status "$RELEASE" -n "$NAMESPACE" || true
echo
echo '== Recent events =='
kubectl get events -n "$NAMESPACE" --sort-by=.lastTimestamp | tail -n 30 || true
