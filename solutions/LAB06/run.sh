. "$ROOT/env/versions.env"
# Part A - the repository becomes private ...
curl -fs -u "$GITEA_USER:$GITEA_PASSWORD" -X PATCH "http://gitea:3000/api/v1/repos/$GITEA_USER/gitops" \
  -H 'Content-Type: application/json' -d '{"private":true}' >/dev/null
# ... so Argo CD needs credentials: one template for every repo under http://gitea:3000/student/
kubectl --context kind-hub apply -f - <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: gitea-student
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repo-creds
stringData:
  type: git
  url: http://gitea:3000/$GITEA_USER
  username: $GITEA_USER
  password: $GITEA_PASSWORD
YAML
# Part C - Sealed Secrets
kubectl --context kind-hub apply -f argocd/sealed-secrets.yaml
argocd app wait sealed-secrets --sync --health --timeout 240 >/dev/null
kubectl --context kind-hub -n tracker create secret generic tracker-api \
  --from-literal=API_TOKEN=pp-7f3c-tracker-2026 --dry-run=client -o yaml \
  | kubeseal --context kind-hub --controller-namespace kube-system -o yaml > apps/tracker/sealedsecret.yaml
git add apps/tracker/sealedsecret.yaml
git diff --cached --quiet || { git commit -qm "Tracker API token as a SealedSecret"; git push -q; }
argocd app sync tracker --timeout 120 >/dev/null || true
argocd app wait tracker --sync --health --timeout 180 >/dev/null
