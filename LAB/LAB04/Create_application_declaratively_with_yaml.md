# Creating Argo CD Application Declaratively

## 1. Create an Argo CD application declaratively using YAML

**Example manifest:**

```yaml
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

## 2. Apply this manifest with kubectl

```bash
kubectl apply -f app.yaml -n argocd
```

## 3. Verify if the app is deployed in ArgoCD

```bash
kubectl get application -n argocd
```

## 4. Retrieve the admin password for ArgoCD WebUI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

## 5. Now log in to the UI and click Sync
