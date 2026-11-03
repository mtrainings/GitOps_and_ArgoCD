argocd app sync root --timeout 120 >/dev/null || true
for _ in $(seq 1 60); do argocd app get checkout >/dev/null 2>&1 && break; sleep 3; done
argocd app wait checkout --sync --health --timeout 300 >/dev/null
# new version -> canary stops at 25 % and waits for a human
sed -i -e 's#podinfo:6.16.0#podinfo:6.17.0#' -e 's#"\#2e8b57"#"\#ff8c00"#' apps/checkout/rollout.yaml
git commit -qam "checkout 6.17.0" && git push -q
for _ in $(seq 1 60); do
  kubectl --context kind-hub -n checkout get rollout checkout -o jsonpath='{.status.phase}' 2>/dev/null | grep -q Paused && break; sleep 5
done
kubectl argo rollouts --context kind-hub -n checkout promote checkout --full >/dev/null
for _ in $(seq 1 60); do
  [[ $(kubectl --context kind-hub -n checkout get rollout checkout -o jsonpath='{.status.phase}') == Healthy ]] && break; sleep 5
done
argocd app wait checkout --sync --health --timeout 120 >/dev/null
