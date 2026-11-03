kubectl --context kind-hub apply -f argocd/project-parcelpal.yaml
for a in tracker shop-dev shop-prod status; do kubectl --context kind-hub apply -f "argocd/$a.yaml"; done
cp "$ROOT/solutions/LAB05/argocd-values.yaml" "$ROOT/env/argocd-values.yaml"
"$LAB" install-argocd >/dev/null
"$LAB" login >/dev/null
argocd account update-password --account alice --current-password 'ParcelPal-Admin-2026!' --new-password 'Alice-Lab-2026!'
for a in tracker shop-dev shop-prod status; do argocd app wait "$a" --sync --health --timeout 180 >/dev/null; done
