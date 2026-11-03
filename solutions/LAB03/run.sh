kubectl --context kind-hub apply -f argocd/tracker.yaml
# Gitea -> Argo CD webhook: instant refresh instead of polling
. "$ROOT/env/versions.env"
curl -fs -u "$GITEA_USER:$GITEA_PASSWORD" "http://gitea:3000/api/v1/repos/$GITEA_USER/gitops/hooks" | grep -q api/webhook \
  || curl -fs -u "$GITEA_USER:$GITEA_PASSWORD" -X POST "http://gitea:3000/api/v1/repos/$GITEA_USER/gitops/hooks" \
       -H 'Content-Type: application/json' \
       -d '{"type":"gitea","active":true,"events":["push"],"config":{"url":"http://hub-control-plane:30080/api/webhook","content_type":"json"}}' >/dev/null
argocd app wait tracker --sync --health --timeout 180 >/dev/null
