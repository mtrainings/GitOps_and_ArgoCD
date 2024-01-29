# Tracking Strategies: Git Tag

## 1. Create an Argo CD application declaratively using YAML with the following specifications

**Example Manifest:**

```yaml
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

## 2. Apply this manifest with kubectl

```bash
kubectl apply -f app2.yaml -n argocd
```

## 3. Verify the application

```bash
kubectl get application -n argocd
```

## 4. Verify that resources are created in the `track-head` namespace

```bash
kubectl get all -n track-head
```
