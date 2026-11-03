kubectl --context kind-hub apply -f bootstrap/root.yaml
argocd app wait root --sync --health --timeout 300 >/dev/null
for a in argo-rollouts argocd-image-updater shop-dev shop-staging shop-prod; do
  for _ in $(seq 1 60); do argocd app get "$a" >/dev/null 2>&1 && break; sleep 3; done
  argocd app wait "$a" --sync --health --timeout 300 >/dev/null
done
