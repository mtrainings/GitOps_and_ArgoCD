# LAB 11 – Progressive delivery with Argo Rollouts

> **Story:** Last month a bad checkout release hit 100 % of customers in one go. From now on a new checkout version gets 25 % of the pods first – and only a human (or a metric) lets it go further.

| | |
|---|---|
| **Duration** | ~45 min |
| **You create** | `argocd/checkout.yaml`; you edit `apps/checkout/rollout.yaml` |
| **Solution** | `solutions/LAB11/` (or `./bin/lab catchup 11`) |

Argo CD decides **what** runs (desired state from Git). Argo Rollouts decides **how** a new version replaces the old one. A `Rollout` is a Deployment with a strategy:

| Strategy | How |
|---|---|
| **Canary** | shift a growing share of pods/traffic to the new version, pause between steps |
| **Blue-green** | start the new version next to the old one, switch the Service at once |
| + **Analysis** | query Prometheus/Datadog/a web endpoint/a Job between steps – abort automatically on bad results |
| + **Traffic routing** | exact percentages via an ingress/service mesh (Traefik, NGINX, Istio, Gateway API plugin…) – without it, the split follows the pod ratio |

The controller was installed in LAB08 (`argo-rollouts` app).

## Step 1 – Deploy checkout

Read `apps/checkout/rollout.yaml`: 4 replicas, steps 25 % → pause (indefinitely) → 50 % → 30 s → 75 % → 30 s → 100 %.

```bash
cd work/gitops
cat > argocd/checkout.yaml <<'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: checkout
  namespace: argocd
spec:
  project: parcelpal
  source:
    repoURL: http://gitea:3000/student/gitops.git
    targetRevision: main
    path: apps/checkout
  destination:
    server: https://kubernetes.default.svc
    namespace: checkout
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF
git add argocd/checkout.yaml && git commit -m "checkout app" && git push
```

✅ **Checkpoint:** the *checkout* app is *Healthy*; <http://checkout.localtest.me> is green, version 6.16.0.

```bash
kubectl argo rollouts get rollout checkout -n checkout
```

The first rollout goes straight to 100 % – there is no old version to protect.

## Step 2 – A canary release

In a second terminal keep an eye on the versions:

```bash
while true; do curl -s http://checkout.localtest.me/version | grep -o '"version": "[^"]*"'; sleep 1; done
```

Release 6.17.0 in orange:

```bash
sed -i -e 's#podinfo:6.16.0#podinfo:6.17.0#' -e 's/"#2e8b57"/"#ff8c00"/' apps/checkout/rollout.yaml
git commit -am "checkout 6.17.0" && git push
kubectl argo rollouts get rollout checkout -n checkout --watch      # Ctrl+C
```

✅ **Checkpoint:** 1 of 4 pods runs 6.17.0 (25 %), the rollout is **Paused**, and the Argo CD app health shows **Suspended**. About every fourth answer in the loop says `6.17.0`.

Happy with the canary? Promote it:

```bash
kubectl argo rollouts promote checkout -n checkout
```

…or in Argo CD: open the *Rollout* resource → **⋮ → Resume** (resource actions).

✅ **Checkpoint:** 50 % → 75 % → 100 % with 30 s pauses; finally all answers are `6.17.0`, the app is *Healthy*.

## Step 3 – Abort a bad release

Release a version that cannot start:

```bash
sed -i 's#podinfo:6.17.0#podinfo:6.99.0#' apps/checkout/rollout.yaml
git commit -am "checkout 6.99.0" && git push
kubectl argo rollouts get rollout checkout -n checkout
```

The canary pod is stuck in `ImagePullBackOff` – but 3 of 4 pods still serve 6.17.0. Abort:

```bash
kubectl argo rollouts abort checkout -n checkout
```

✅ **Checkpoint:** the stable version is scaled back to 4 pods; the rollout is **Degraded** (aborted) and so is the Argo CD app.

Now fix the source of truth – Git still says 6.99.0:

```bash
git revert --no-edit HEAD && git push
```

✅ **Checkpoint:** the rollout returns to *Healthy* on 6.17.0 without a new canary – it is the stable version already.

> Never fix a rollout only with `kubectl argo rollouts undo` while Argo CD watches: self-heal would bring the bad spec back. Revert in Git.

## Step 4 – Dashboard (optional)

```bash
kubectl argo rollouts dashboard -n checkout &      # http://localhost:3100
```

## Bonus

- **Automated analysis:** add an `AnalysisTemplate` with the `web` provider that calls `http://checkout.checkout.svc/healthz` and a step `- analysis: { templates: [{ templateName: health }] }` after `setWeight: 25`.
- **Blue-green:** replace `canary` with `blueGreen: { activeService: checkout, autoPromotionEnabled: false }` (and a preview Service).
- Why did we not need a `Deployment` at all? Look at `kubectl -n checkout get rs` – who owns the ReplicaSets?

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `no matches for kind "Rollout"` | the argo-rollouts app (LAB08) is missing – the CRD is not installed |
| app stays *Progressing* during the pause | expected for timed pauses; an indefinite pause shows *Suspended* |
| `promote` does nothing | the rollout is not paused, or you are in the wrong namespace (`-n checkout`) |
| traffic split not exactly 25 % | without traffic routing the split follows the ratio of ready pods |
