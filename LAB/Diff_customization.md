# Diff customization (Ignore differences for deployment replicas)
1. Create an Argo CD application declaratively using Yaml with below specs
```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata: 
  name: diffing-customization-demo
  namespace: argocd
spec: 
  destination:
    namespace: diffing-customization-demo
    server: "https://kubernetes.default.svc"
  project: default
  source: 
    path: guestbook-with-sub-directories
    repoURL: "https://github.com/spy86/argocd-example-apps.git"
    targetRevision: master
    directory:
      recurse: true
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
  ignoreDifferences:
    - group: apps
      kind: Deployment
      jsonPointers:
      - /spec/replicas
```
2. Apply this manifest with kubectl
```
kubectl apply -f app.yaml -n argocd
```
3. Verify app
```
kubectl get application -n argocd
```
4. Verify that resources created in diffing-customization-demo namespace
```
kubectl get all -n diffing-customization-demo
```
5. Scale the deployment into 3 replicas using kubectl
```
kubectl scale deployment/guestbook-ui -n diffing-customization-demo --replicas=3
```
6. Login into ArgoCD WebUI
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
7. Refresh the application in Argo CD.
