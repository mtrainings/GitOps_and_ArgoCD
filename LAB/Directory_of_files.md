# Directory of Files Options

1. Create an Argo CD application declaratively using Yaml

Example manifest:
---
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata: 
  name: directory-app
  namespace: argocd
spec: 
  destination:
    namespace: directory-app
    server: "https://kubernetes.default.svc"
  project: default
  source: 
    path: guestbook-with-sub-directories
    repoURL: "https://github.com/spy86/argocd-example-apps.git"
    targetRevision: master
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
```
2. Apply this manifest with kubectl
```
kubectl apply -f dir-app.yaml -n argocd
```
3. Verify app
```
kubectl get application -n argocd
```
4. Login into ArgoCD WebUI
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
5. Now login to UI and click Sync.

6. Set recurse option
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata: 
  name: directory-app
  namespace: argocd
spec: 
  destination:
    namespace: directory-app
    server: "https://kubernetes.default.svc"
  project: default
  source: 
    path: guestbook-with-sub-directories
    repoURL: "https://github.com/spy86/argocd-example-apps.git"
    targetRevision: master
    directory:
      recurse: true
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
```
7. Apply this manifest with kubectl
```
kubectl apply -f dir-app.yaml -n argocd
```
8. Verify app
```
kubectl get application -n argocd
```
9. Go to UI and Re-Sync the application
