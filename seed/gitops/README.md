# ParcelPal – desired state

Everything that runs in ParcelPal's clusters is described here. Argo CD makes the clusters match this repository.

| Path | What |
|---|---|
| `apps/tracker/` | parcel tracker – plain manifests |
| `apps/shop/` | web shop – Kustomize base + `overlays/<env>` |
| `helm/` | values for Helm-based apps |
| `apps/orders/` | orders service + Redis |
| `apps/checkout/` | checkout – progressive delivery with Argo Rollouts |
| `apps/chat/` | chat webhook receiver for notifications |
| `argocd/` | Argo CD objects: Applications, projects, ApplicationSets (you create them during the labs) |
