# LAB 05 – Projects & RBAC: guard rails for teams

> **Story:** A second team wants to use Argo CD. The security officer asks: *"Can a developer deploy into `kube-system`? Can the CI pipeline delete production?"* Today the answer is yes. Projects and RBAC change that.

| | |
|---|---|
| **Duration** | ~40 min |
| **You create** | `work/gitops/argocd/project-parcelpal.yaml`; you edit `env/argocd-values.yaml` |
| **Solution** | `solutions/LAB05/` (or `./bin/lab catchup 5`) |

| Concept | Answers | Lives in |
|---|---|---|
| **AppProject** | *What* may an app deploy – from which repos, to which clusters/namespaces, which kinds? | `AppProject` resource |
| **RBAC** | *Who* may do what with apps, projects, repos, clusters… | `argocd-rbac-cm` |
| **Project role** | a machine identity (JWT) scoped to one project – for CI | inside the `AppProject` |

## Step 1 – The project

```bash
cd work/gitops
cat > argocd/project-parcelpal.yaml <<'EOF'
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: parcelpal
  namespace: argocd
spec:
  description: ParcelPal applications
  sourceRepos:                                   # where manifests may come from
    - http://gitea:3000/student/*
    - https://stefanprodan.github.io/podinfo
  destinations:                                  # where they may go
    - server: https://kubernetes.default.svc
      namespace: tracker
    - server: https://kubernetes.default.svc
      namespace: shop-*
    - server: https://kubernetes.default.svc
      namespace: status
    - server: https://kubernetes.default.svc
      namespace: orders
    - server: https://kubernetes.default.svc
      namespace: checkout
  clusterResourceWhitelist:                      # cluster-scoped kinds allowed: only namespaces
    - group: ""
      kind: Namespace
  namespaceResourceBlacklist:                    # teams may not touch quotas and limits
    - group: ""
      kind: ResourceQuota
    - group: ""
      kind: LimitRange
  roles:
    - name: ci
      description: CI pipelines may sync, nothing else
      policies:
        - p, proj:parcelpal:ci, applications, get, parcelpal/*, allow
        - p, proj:parcelpal:ci, applications, sync, parcelpal/*, allow
EOF
kubectl apply -f argocd/project-parcelpal.yaml
```

Move `tracker`, `shop-dev`, `shop-prod` and `status` into the project:

```bash
sed -i 's/^  project: default$/  project: parcelpal/' argocd/tracker.yaml argocd/shop-*.yaml argocd/status.yaml
git add argocd && git commit -m "ParcelPal project" && git push
kubectl apply -f argocd/
```

✅ **Checkpoint:** **Settings → Projects → parcelpal** lists the four apps; they stay *Synced/Healthy*.

## Step 2 – The project says no

Try to escape the guard rails:

```bash
argocd app create escape --project parcelpal \
  --repo http://gitea:3000/student/gitops.git --path apps/tracker \
  --dest-server https://kubernetes.default.svc --dest-namespace kube-system
```

✅ **Checkpoint:** `application destination … namespace kube-system is not permitted in project 'parcelpal'`.

Now try a forbidden kind. Add a quota to the tracker and push:

```bash
kubectl create quota tracker-quota --hard=pods=10 -n tracker --dry-run=client -o yaml > apps/tracker/quota.yaml
git add -A && git commit -m "quota" && git push
argocd app get tracker --refresh | grep -i quota
```

✅ **Checkpoint:** the sync fails with *resource :ResourceQuota is not permitted in project parcelpal*. Remove the file again (`git rm apps/tracker/quota.yaml`, commit, push) – the app recovers.

## Step 3 – A local user and RBAC

Users and policies are Argo CD configuration – so they belong in the Helm values. Add to `env/argocd-values.yaml`:

```yaml
configs:
  cm:
    timeout.reconciliation: 60s
    accounts.alice: login            # local user for the UI and CLI
  rbac:
    policy.default: ""               # no access unless granted below
    policy.csv: |
      p, role:parcelpal-dev, applications, get,  parcelpal/*, allow
      p, role:parcelpal-dev, applications, sync, parcelpal/*, allow
      p, role:parcelpal-dev, logs,         get,  parcelpal/*, allow
      p, role:parcelpal-dev, projects,     get,  parcelpal,   allow
      g, alice, role:parcelpal-dev
```

(Keep `params` as it is – merge, don't replace the whole `configs` block.)

```bash
./bin/lab install-argocd          # helm upgrade with the new values
argocd login argocd.localtest.me --grpc-web --insecure --username admin --password 'ParcelPal-Admin-2026!'
argocd account update-password --account alice --current-password 'ParcelPal-Admin-2026!' --new-password 'Alice-Lab-2026!'
```

Policy format: `p, <subject>, <resource>, <action>, <project>/<object>, allow|deny` – and `g, <user or SSO group>, <role>` assigns roles.

Check before you trust it:

```bash
argocd admin settings rbac can alice sync applications parcelpal/tracker  --namespace argocd
argocd admin settings rbac can alice delete applications parcelpal/tracker --namespace argocd
```

Log in as Alice in a private browser window (<http://argocd.localtest.me>, `alice` / `Alice-Lab-2026!`).

✅ **Checkpoint:** Alice sees the four ParcelPal apps (not `default`-project apps), can **Sync** and read **Logs**, but **Delete** fails with *permission denied*.

> Since Argo CD 3.0 `update` and `delete` on an application no longer include its resources: to let someone delete a pod inside an app, grant `delete/*` explicitly. In production `g,` lines map SSO groups (Entra ID, Okta, GitHub teams…) – not local users.

## Step 4 – A token for CI

```bash
TOKEN=$(argocd proj role create-token parcelpal ci --token-only)
argocd app sync tracker --auth-token "$TOKEN"          # allowed
argocd app delete tracker --auth-token "$TOKEN" --yes   # denied
argocd proj role list parcelpal
```

✅ **Checkpoint:** the sync works, the delete returns *permission denied*. A pipeline holding this token can only do what the `ci` role allows, only in this project.

> Revoke tokens with `argocd proj role delete-token parcelpal ci <issued-at>`. Give them an expiry (`--expires-in 24h`).

## Bonus

- Sync windows: in `project-parcelpal.yaml` add `syncWindows` that deny syncs on Saturdays and Sundays – and `manualSync: true` for emergencies.
- `orphanedResources: { warn: true }` in the project – create a ConfigMap by hand in `tracker` and look for the warning.
- `argocd account can-i sync applications 'parcelpal/*'` – as admin and as alice.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| apps show *Unknown* after moving to the project | the project does not allow their repo or namespace – compare `sourceRepos`/`destinations` |
| Alice sees nothing | `policy.default: ""` + missing `get` permission, or the RBAC change has not been applied (`./bin/lab install-argocd`) |
| `account update-password`: `account alice does not exist` | `accounts.alice: login` missing in `configs.cm` |
| `create-token`: `permission denied` | you are logged in as Alice – log in as admin again |
