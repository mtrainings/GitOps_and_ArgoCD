# Creating Argo CD Application from UI

1. Create an Argo CD application using Web UI by clicking button `New App`

Specification:
---
* Name: `app-1`
* project: `default`
* Sync options: Select `auto create namespace`.
* Source repo: `https://github.com/spy86/argocd-example-apps.git`
* Source path: `guestbook` 
* Source branch: `master`
* Destination cluster url: `https://kubernetes.default.svc`
* Destination namespace: `app-1`