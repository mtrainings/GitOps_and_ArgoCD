. "$ROOT/env/versions.env"
# Part A - notifications
cp "$ROOT/solutions/LAB10/argocd-values.yaml" "$ROOT/env/argocd-values.yaml"
"$LAB" install-argocd >/dev/null
"$LAB" login >/dev/null
argocd app sync root --timeout 120 >/dev/null || true
argocd app wait chat --sync --health --timeout 240 >/dev/null
# Part B - Image Updater writes back to Git over SSH with a deploy key that may push
key="$WORK/image-updater-key"
[[ -f $key ]] || ssh-keygen -q -t ed25519 -N '' -C image-updater -f "$key"
curl -fs -u "$GITEA_USER:$GITEA_PASSWORD" "http://gitea:3000/api/v1/repos/$GITEA_USER/gitops/keys" | grep -q '"title":"image-updater"' \
  || curl -fs -u "$GITEA_USER:$GITEA_PASSWORD" -X POST "http://gitea:3000/api/v1/repos/$GITEA_USER/gitops/keys" \
       -H 'Content-Type: application/json' \
       -d "{\"title\":\"image-updater\",\"key\":\"$(cat "$key.pub")\",\"read_only\":false}" >/dev/null
ssh-keyscan -p 2222 127.0.0.1 2>/dev/null | sed 's/^\[127.0.0.1\]:2222/gitea/' | argocd cert add-ssh --batch --upsert >/dev/null
kubectl --context kind-hub -n argocd create secret generic git-creds --from-file=sshPrivateKey="$key" \
  --dry-run=client -o yaml | kubectl --context kind-hub apply -f -
kubectl --context kind-hub -n argocd rollout restart deploy/argocd-image-updater-controller >/dev/null   # re-read known hosts
for _ in $(seq 1 60); do
  git pull -q; grep -q "newTag: 6.17" apps/shop/overlays/dev/kustomization.yaml 2>/dev/null && break; sleep 5
done
grep -q "newTag: 6.17" apps/shop/overlays/dev/kustomization.yaml || { echo "Image Updater did not write back"; exit 1; }
argocd app wait shop-dev --sync --health --timeout 240 >/dev/null
