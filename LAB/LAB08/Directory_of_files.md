# Directory of Files Options

## 1. Create an Argo CD Application Declaratively Using YAML

**Example Manifest:**

```yaml
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

## 2. Apply this Manifest with kubectl

```bash
kubectl apply -f dir-app.yaml -n argocd
```

## 3. Verify App

```bash
kubectl get application -n argocd
```

## 4. Retrieve the admin password for ArgoCD WebUI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

## 5. Now Log in to UI and Click Sync

## 6. Set Recurse Option

```yaml
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

## 7. Apply this Manifest with kubectl

```bash
kubectl apply -f dir-app.yaml -n argocd
```

## 8. Verify App

```bash
kubectl get application -n argocd
```

## Go to UI and Re-Sync the Application
