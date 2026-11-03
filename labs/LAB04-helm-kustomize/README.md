# LAB 04 – Helm, Kustomize and multiple sources

> **Story:** The web *shop* needs a dev and a prod environment from one set of manifests, and the public *status* page should come from the vendor's Helm chart – with ParcelPal's own values kept in Git.

| | |
|---|---|
| **Duration** | ~45 min |
| **You create** | `work/gitops/argocd/shop-dev.yaml`, `shop-prod.yaml`, `status.yaml` |
| **Solution** | `solutions/LAB04/` (or `./bin/lab catchup 4`) |

How Argo CD decides what a source is:

| Found in the path | Tool |
|---|---|
| `kustomization.yaml` | Kustomize |
| `Chart.yaml` (or `chart:` from a Helm repo) | Helm |
| `*.jsonnet` | Jsonnet |
| anything else | plain directory of YAML/JSON |
| configured plugin | Config Management Plugin (sidecar) |

The repo server renders everything to plain manifests – the controller only ever sees YAML.

## Part A – Kustomize overlays

```bash
cd work/gitops
find apps/shop -type f              # base/ + overlays/dev, overlays/prod
kubectl kustomize apps/shop/overlays/dev | grep -E 'host:|value:|replicas:'
```

The overlays change host name, message, colour and replicas. Create one Application per environment:

```bash
for env in dev prod; do cat > argocd/shop-$env.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: shop-$env
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea:3000/student/gitops.git
    targetRevision: main
    path: apps/shop/overlays/$env
  destination:
    server: https://kubernetes.default.svc
    namespace: shop-$env
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF
done
git add argocd && git commit -m "shop dev + prod" && git push
kubectl apply -f argocd/shop-dev.yaml -f argocd/shop-prod.yaml
```

✅ **Checkpoint:** <http://shop-dev.localtest.me> is orange with *shop - dev*, <http://shop.localtest.me> green with *shop - prod*; `kubectl -n shop-prod get pods` shows 2 replicas.

**Promote a change the GitOps way:** give dev a new image in its overlay only:

```bash
cat >> apps/shop/overlays/dev/kustomization.yaml <<'EOF'
images:
  - name: ghcr.io/stefanprodan/podinfo
    newTag: 6.16.0
EOF
git commit -am "shop-dev: podinfo 6.16.0" && git push
```

✅ **Checkpoint:** shop-dev shows version 6.16.0 (bottom of the page / `curl -s shop-dev.localtest.me/version`), prod stays on 6.15.0. Promotion to prod = the same change in `overlays/prod`, via a reviewed pull request.

> Argo CD can also override Kustomize settings in the Application (`spec.source.kustomize.images`, `namePrefix`, `commonLabels`…). Prefer Git – overrides in the Application are easy to forget.

## Part B – A Helm chart from a Helm repository

```bash
helm show values podinfo --repo https://stefanprodan.github.io/podinfo --version 6.17.0 | head -40
```

```bash
cat > argocd/status.yaml <<'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: status
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://stefanprodan.github.io/podinfo
    chart: podinfo
    targetRevision: 6.17.0
    helm:
      releaseName: status
      valuesObject:
        ui:
          message: "ParcelPal status (inline values)"
        ingress:
          enabled: true
          className: traefik
          hosts:
            - host: status.localtest.me
              paths:
                - path: /
                  pathType: Prefix
  destination:
    server: https://kubernetes.default.svc
    namespace: status
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF
kubectl apply -f argocd/status.yaml
```

✅ **Checkpoint:** <http://status.localtest.me> shows *inline values*. `helm list -A` shows **no** release – Argo CD uses `helm template` and applies the result itself; Helm hooks become Argo CD hooks.

## Part C – Multiple sources: chart from the vendor, values from Git

Inline values live in the Application – the values file should live next to everything else. `helm/status-values.yaml` is already in the repo. Change the `source` block to `sources`:

```yaml
  sources:
    - repoURL: https://stefanprodan.github.io/podinfo
      chart: podinfo
      targetRevision: 6.17.0
      helm:
        releaseName: status
        valueFiles:
          - $values/helm/status-values.yaml
    - repoURL: http://gitea:3000/student/gitops.git
      targetRevision: main
      ref: values                          # makes the repo available as $values
```

```bash
git add argocd/status.yaml && git commit -m "status: chart + values from Git" && git push
kubectl apply -f argocd/status.yaml
```

✅ **Checkpoint:** the page says *all systems operational* in steel blue. Edit `helm/status-values.yaml` (e.g. `replicaCount: 2`), push – the status app follows.

> Imperative overrides exist too: `argocd app set status -p replicaCount=3`. They are stored in the Application, not in Git – handy for experiments, a trap in production.

## Bonus

- **Directory options:** create an app for `apps/` with `directory.recurse: true` and `directory.include: '{tracker/*.yaml}'`. What does Argo CD render?
- **Helm from OCI:** the podinfo chart is also at `oci://ghcr.io/stefanprodan/charts/podinfo`. Argo CD needs it registered as a Helm repo with *Enable OCI*.
- Compare `argocd app manifests status` with `helm template status podinfo --repo … -f helm/status-values.yaml`.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `Unable to resolve '6.17.0' to a Chart version` | chart version typo, or `repoURL` points to the Git repo instead of the Helm repo |
| `$values/...: no such file` | the second source needs `ref: values`, and the path after `$values/` is relative to that repo's root |
| shop-dev and shop-prod fight over the same resources | both apps target the same namespace – check `destination.namespace` |
| `kustomize build` error in the UI | run `kubectl kustomize <path>` locally – same error, faster feedback |
