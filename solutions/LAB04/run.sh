for a in shop-dev shop-prod status; do kubectl --context kind-hub apply -f "argocd/$a.yaml"; done
for a in shop-dev shop-prod status; do argocd app wait "$a" --sync --health --timeout 240 >/dev/null; done
