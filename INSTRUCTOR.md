# Instructor guide

## Before the course

1. One VM per participant: Ubuntu 24.04, **4 vCPU / 8 GB RAM / 30 GB**, Docker, user in the `docker` group, `sudo`.
2. Pre-pull everything (the first `up` downloads the kind node image and Traefik; Argo CD and the apps follow in LAB01–LAB11):

   ```bash
   chmod +x bin/* && ./bin/lab tools && ./bin/lab up && ./bin/lab catchup 11 && ./bin/lab destroy
   ```

   `destroy` keeps the Docker image cache, so the course day starts fast.
3. Pin versions in `env/versions.env`. Argo CD has a minor release about every quarter – read the upgrade notes (`operator-manual/upgrading/`).
4. Internet access is needed for ghcr.io, Docker Hub, the Helm repositories and GitHub releases.
5. WSL 2 works: keep one WSL terminal open the whole day – when the last session ends, WSL shuts the distribution down and stops the clusters.

## Suggested schedule (2 days, 9:00–16:00)

| | Day 1 – Foundations | Day 2 – Scale & automation |
|---|---|---|
| 09:00 | GitOps principles, push vs. pull, Argo CD architecture | Recap + quiz |
| 09:45 | **LAB01** install | Sync waves & hooks → **LAB07** |
| 10:45 | ☕ | ☕ |
| 11:00 | Applications → **LAB02** | App of apps & ApplicationSet → **LAB08** |
| 12:00 | Automation & tracking → **LAB03** | Multi-cluster → **LAB09** |
| 12:45 | 🍽 | 🍽 |
| 13:30 | Helm, Kustomize, multi-source → **LAB04** | Notifications & Image Updater → **LAB10** |
| 14:30 | Projects & RBAC → **LAB05** | Progressive delivery → **LAB11** |
| 15:15 | ☕ / Secrets → **LAB06** | ☕ / **LAB12** break-fix |
| 15:45 | Wrap-up day 1 | Best practices, Q&A, survey |

Anyone who falls behind: `./bin/lab catchup <N>` (end state of lab N). Bonus tasks are for fast participants – never wait for them.

## Teaching notes

- **Argo CD 3.x defaults** (verified on 3.5.7): annotation-based resource tracking, fine-grained RBAC (`update/*`, `delete/*` for resources inside apps), logs need explicit `logs, get`, status fields ignored in diffs, Helm 4 renders charts, SSH host keys always verified. Old blog posts (2.x) often show label tracking and `argocd-cm` repository lists – both obsolete.
- **LAB01** – `argocd login` needs `--grpc-web --insecure` here (gRPC through an HTTP ingress, self-signed certificate). The `127.0.0.1 argocd.localtest.me` line in `/etc/hosts` is there because the CLI does not fall back from IPv6.
- **LAB02** – let them see *Synced + Degraded* once (wrong image tag) – the two statuses are the most misunderstood concept of the day.
- **LAB03** – self-heal is the "wow" moment. Rollback with automated sync is refused – good discussion of "Git is the only truth".
- **LAB04** – `helm list` is empty: Argo CD templates charts, it does not install Helm releases.
- **LAB05** – change RBAC through the Helm values, never `kubectl edit cm` – the next `helm upgrade` would silently undo it.
- **LAB06** – stress that the repo credential Secret is applied from the shell, not committed. Back up the Sealed Secrets key.
- **LAB07** – a sync waits for *health* between waves; a resource that never gets healthy blocks the sync (BF6 builds on this).
- **LAB08** – after this lab nobody runs `kubectl apply` for Argo CD objects any more; remind them in LAB09–11.
- **LAB09** – `--cluster-endpoint kube-public` is the kind-specific trick; in the cloud the API endpoint is reachable as is.
- **LAB10** – Image Updater checks every 2 minutes – start Part B before the notifications discussion.
- **LAB11** – show the Argo CD app health *Suspended* during the indefinite pause.

## LAB12 – solutions

| # | Root cause | Symptom | Fix |
|---|---|---|---|
| BF1 | `path: bf1/manifest` | `app path does not exist` | `bf1/manifests` |
| BF2 | `targetRevision: mian` | `unable to resolve 'mian' to a commit SHA` | `main` |
| BF3 | destination namespace `payments` | `namespace payments is not permitted in project 'breakfix'` | `bf-3` (projects allow `bf-*`) |
| BF4 | no `CreateNamespace=true` | `namespaces "bf-4" not found` | add the sync option (or a Namespace manifest) |
| BF5 | PreSync hook checks an empty `DB_HOST` | hook Job failed, sync *Failed*, deployment never applied | set a value in `bf5/db-check.yaml` |
| BF6 | Deployment (wave 0) needs a ConfigMap from wave 1 | pod `CreateContainerConfigError`, sync *Running* for ever | ConfigMap wave `-1`, then `argocd app terminate-op bf6` |
| BF7 | private repo `finance/ledger` outside the `student/` credential template | `authentication required` | `repository` Secret (or `repo-creds` for `http://gitea:3000/finance`) |
| BF8 | `newTag: 6.15.O` (letter O) | `ImagePullBackOff`, app *Degraded* | `6.15.0` |

Reference fixes: `solutions/LAB12/fix.sh` (run from the repository root).
