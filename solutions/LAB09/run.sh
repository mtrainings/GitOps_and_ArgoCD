"$LAB" edge
argocd cluster add kind-edge --name edge --cluster-endpoint kube-public --label env=edge --yes --upsert >/dev/null
argocd app sync root --timeout 120 >/dev/null || true
for a in fleet-in-cluster fleet-edge; do
  for _ in $(seq 1 60); do argocd app get "$a" >/dev/null 2>&1 && break; sleep 3; done
  argocd app wait "$a" --sync --health --timeout 300 >/dev/null
done
