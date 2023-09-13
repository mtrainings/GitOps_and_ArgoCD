# HELM in ArgoCD

1. Create an Argo CD application declaratively using Yaml

Example manifest:
---
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata: 
  name: helm-app
  namespace: argocd
spec: 
  destination: 
    namespace: helm-app
    server: "https://kubernetes.default.svc"
  project: default
  source: 
    path: helm-guestbook
    repoURL: "https://github.com/spy86/argocd-example-apps.git"
    targetRevision: master
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
```
2. Apply this manifest with kubectl
```
kubectl apply -f helm-app.yaml -n argocd
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

6. Update helm release name
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata: 
  name: helm-app
  namespace: argocd
spec: 
  destination: 
    namespace: helm-app
    server: "https://kubernetes.default.svc"
  project: default
  source: 
    path: helm-guestbook
    repoURL: "https://github.com/spy86/argocd-example-apps.git"
    targetRevision: master
    helm:
     releaseName: my-release
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
```
7. Apply this manifest with kubectl
```
kubectl apply -f helm-app.yaml -n argocd
```
5. Verify app
```
kubectl get application -n argocd
```
6. Go to UI and Re-Sync the application and select **prune** option to delete old resources **with old names**.
