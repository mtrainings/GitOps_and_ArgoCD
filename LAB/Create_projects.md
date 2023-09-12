# Create projects
1. Create an Argo CD project declaratively with below specs

Example manifest:
---
```
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: dev-project
  namespace: argocd
spec:
  description: Dev Project
  sourceRepos:
  - '*'

  destinations:
  - namespace: ns-1
    server: https://kubernetes.default.svc

  clusterResourceWhitelist:
  - group: '*'
    kind: '*'

  namespaceResourceWhitelist:
  - group: '*'
    kind: '*'
```
2. Apply this manifest with kubectl
```
kubectl apply -f project.yaml -n argocd
```
3. Verify if project are deployed in ArgoCD
```
kubectl get appproject -n argocd
```
4. Create an Argo CD application declaratively with below specs
Example manifest:
---
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata: 
  name: guestbook-dev-project
  namespace: argocd
spec: 
  destination: 
    namespace: test-1
    server: "https://kubernetes.default.svc"
  project: dev-project
  source: 
    path: guestbook
    repoURL: "https://github.com/spy86/argocd-example-apps.git"
    targetRevision: master
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
```
5. Apply this manifest with kubectl
```
kubectl apply -f app.yaml -n argocd
```
6. Verify if app are deployed in ArgoCD
```
kubectl get application -n argocd
kubectl describe application guestbook-dev-project -n argocd
```
7. Correct the application with permitted namespace `ns-1`
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata: 
  name: guestbook-dev-project
  namespace: argocd
spec: 
  destination: 
    namespace: ns-1
    server: "https://kubernetes.default.svc"
  project: dev-project
  source: 
    path: guestbook
    repoURL: "https://github.com/spy86/argocd-example-apps.git"
    targetRevision: master
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
```
8. Login into ArgoCD WebUI
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
9. Now login to UI and click Sync.