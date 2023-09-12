# Creating Argo CD Application Declaratively
1. Create an Argo CD application declaratively using Yaml
Example manifest:
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata: 
  name: guestbook
  namespace: argocd
spec: 
  destination: 
    namespace: guestbook
    server: "https://kubernetes.default.svc"
  project: default
  source: 
    path: guestbook
    repoURL: "https://github.com/spy86/argocd-example-apps.git"
    targetRevision: master
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
```
2. Apply this manifest with kubectl
```
kubectl apply -f app.yaml -n argocd
```
3. Verify if app are deployed in ArgoCD
```
kubectl get application -n argocd
```
4. Login into ArgoCD WebUI
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
4. Now login to UI and click Sync.