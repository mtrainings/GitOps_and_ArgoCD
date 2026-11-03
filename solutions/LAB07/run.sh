kubectl --context kind-hub apply -f argocd/orders.yaml
argocd app wait orders --sync --health --operation --timeout 300 >/dev/null
