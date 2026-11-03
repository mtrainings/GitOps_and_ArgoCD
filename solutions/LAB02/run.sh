kubectl --context kind-hub apply -f argocd/tracker.yaml
argocd app sync tracker --timeout 120 >/dev/null
argocd app wait tracker --health --timeout 180 >/dev/null
