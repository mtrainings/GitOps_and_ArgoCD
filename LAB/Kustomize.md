# Kustomize

1. Create an Argo CD application declaratively with below specs
Example manifest:
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata: 
  name: kustomize-app
  namespace: argocd
spec: 
  destination:
    namespace: kustomize-app
    server: "https://kubernetes.default.svc"
  project: default
  source: 
    path: kustomize-guestbook
    repoURL: "https://github.com/spy86/argocd-example-apps.git"
    targetRevision: master
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
```
2. Apply this manifest with kubectl
```
kubectl apply -f kustomize.yaml -n argocd
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
6. Set name prefix staging- and common label app: demo options in Argo CD
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata: 
  name: kustomize-app
  namespace: argocd
spec: 
  destination:
    namespace: kustomize-app
    server: "https://kubernetes.default.svc"
  project: default
  source: 
    path: kustomize-guestbook
    repoURL: "https://github.com/spy86/argocd-example-apps.git"
    targetRevision: master
    kustomize:
      namePrefix: staging-
      commonLabels:
        app: demo
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
```
7. Apply this manifest with kubectl
```
kubectl apply -f kustomize.yaml -n argocd
```
8. Verify app
```
kubectl get application -n argocd
```
9. Go to UI and click Re-Sync the application and select **prune** option to delete old resources **with old names**.
