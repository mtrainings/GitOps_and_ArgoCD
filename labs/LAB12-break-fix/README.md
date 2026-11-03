# LAB 12 – Break-fix challenge 🔧

> **Story:** It's release week and eight teams have opened tickets: *"Argo CD is broken!"*. Argo CD is fine – every ticket is a configuration mistake. Fix them like an on-call engineer: read the condition, form a hypothesis, change one thing, verify.

| | |
|---|---|
| **Duration** | ~40 min (pairs or teams work great) |
| **You use** | `./bin/lab breakfix`, `./bin/lab check` |

```bash
./bin/lab breakfix
./bin/lab check          # 0 / 8 - your starting point
```

This creates:

- a Gitea repository `student/breakfix`, cloned to `work/student-breakfix`;
- a private repository `finance/ledger`;
- a project `breakfix` (destinations: `bf-*` namespaces);
- eight Applications `bf1` … `bf8`.

Fix them by editing the **Application** (`kubectl -n argocd edit application bfN`, the UI, or `argocd app set`) or the **repository** (`work/student-breakfix`, then commit + push) – whichever is wrong. Do not change the project.

## Where to look

| Where | What you learn |
|---|---|
| app **Conditions** (UI banner, `argocd app get bfN`) | ComparisonError, InvalidSpecError, repo errors |
| **Last sync result** (`argocd app get bfN --show-operation`) | which resource / hook / wave failed and why |
| resource **health** and **Events** in the tree | ImagePullBackOff, CreateContainerConfigError, … |
| `argocd app diff bfN`, `argocd app manifests bfN` | what Argo CD wants to apply |
| `kubectl -n argocd logs deploy/argocd-repo-server` | Git / Helm / Kustomize problems |

## The tickets

| # | Ticket | Hint (only if stuck) |
|---|---|---|
| BF1 | *Warehouse: "app path does not exist" – but the manifests are right there!* | Compare the path with the folders in the repo. |
| BF2 | *Labels: "unable to resolve" since we renamed something* | Read `targetRevision` slowly. |
| BF3 | *Payments: the app is red before it even tried to sync* | What does the project allow? |
| BF4 | *Returns: sync failed – namespaces "bf-4" not found* | Who should create the namespace? |
| BF5 | *Invoices: the deployment never even starts* | A hook runs before anything else. Read its log. |
| BF6 | *Routing: sync has been "Running" for ten minutes* | Waves. And: a running operation must end before a new one starts (`argocd app terminate-op`). |
| BF7 | *Ledger: "authentication required" – our other repos work fine!* | Which URLs does the credential template from LAB06 cover? |
| BF8 | *Tracking API: pods in ImagePullBackOff* | Look at the image tag very closely. |

✅ **Goal:** `./bin/lab check` reports **8 / 8**.

## Wrap-up

- Which tickets would a CI check on the GitOps repo have caught before merge? (`kubectl kustomize`, `helm template`, `kubeconform`, `argocd app diff --local`)
- Which errors appear as *conditions* (before sync) and which only during the sync?
- What would you put in a runbook for the on-call team?
