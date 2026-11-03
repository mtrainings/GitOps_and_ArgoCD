#!/usr/bin/env bash
# Scores the LAB12 break-fix challenge: every bfN Application must be Synced and Healthy
set -uo pipefail
pass=0; total=8
hub() { kubectl --context kind-hub "$@"; }
echo "Break-fix challenge"
for n in 1 2 3 4 5 6 7 8; do
  st=$(hub -n argocd get application "bf$n" -o jsonpath='{.status.sync.status}/{.status.health.status}/{.spec.destination.namespace}' 2>/dev/null)
  sync=${st%%/*}; rest=${st#*/}; health=${rest%%/*}; ns=${rest#*/}
  if [[ $sync == Synced && $health == Healthy && $ns == bf-* ]]; then
    echo "  PASS  BF$n"; pass=$((pass+1))
  else
    echo "  FAIL  BF$n  (sync: ${sync:-?}, health: ${health:-?}, namespace: ${ns:-?})"
  fi
done
echo; echo "Score: $pass / $total"
