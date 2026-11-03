# LAB01 - install Argo CD with Helm, log in, set the lab admin password
"$LAB" install-argocd
"$LAB" login
if pw=$(argocd admin initial-password -n argocd --kube-context kind-hub 2>/dev/null | head -n1) && [[ -n $pw ]]; then
  argocd account update-password --current-password "$pw" --new-password 'ParcelPal-Admin-2026!'
  kubectl --context kind-hub -n argocd delete secret argocd-initial-admin-secret
  "$LAB" login
fi
