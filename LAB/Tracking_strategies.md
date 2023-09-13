# Tracking strategies Git tag/Git HEAD

## Track Git Tag

1. Use tag from repo `https://github.com/spy86/argocd-example-apps.git` 
2. Create an Argo CD application declaratively using Yaml with below
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: track-git-tag
  namespace: argocd
spec:
  destination:
    namespace: track-git-tag
    server: "https://kubernetes.default.svc"
  project: default
  source:
    path: guestbook
    repoURL: "https://github.com/spy86/argocd-example-apps.git"
    targetRevision: master
    directory:
      recurse: true
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
```
3. Apply this manifest with kubectl
```
kubectl apply -f app.yaml -n argocd
```
4. Verify app
```
kubectl get application -n argocd
```
5. Verify that resources created in track-git-tag namespace
```
kubectl get all -n track-git-tag
```
---
## Track Head
1. Create an Argo CD application declaratively using Yaml with below specs
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: track-head
  namespace: argocd
spec:
  destination:
    namespace: track-head
    server: "https://kubernetes.default.svc"
  project: default
  source:
    path: guestbook
    repoURL: "https://github.com/spy86/argocd-example-apps.git"
    targetRevision: HEAD
    directory:
      recurse: true
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
```
2. Apply this manifest with kubectl
```
kubectl apply -f app2.yaml -n argocd
```
3. Verify app
```
kubectl get application -n argocd
```
4. Verify that resources created in track-head namespace
```
kubectl get all -n track-head
```
5. Login into ArgoCD WebUI
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
