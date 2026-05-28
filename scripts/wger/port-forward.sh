#!/usr/bin/env bash
set -euo pipefail

kubectl -n fitness port-forward svc/wger-http 8080:8000
