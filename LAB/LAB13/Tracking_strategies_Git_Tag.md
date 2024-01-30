# Tracking Strategies: Git Tag

This exercise illustrates the use of a Git tag as a tracking strategy for Argo CD applications. Follow these steps:

<details>
<summary><b>Solution</b></summary>
<p>

## 1. Create an Argo CD application declaratively using YAML with the following specifications

**Example Manifest:**

```yaml
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

## 2. Apply this manifest with kubectl

```bash
kubectl apply -f app.yaml -n argocd
```

## 3. Verify the application

```bash
kubectl get application -n argocd
```

## 4. Verify that resources are created in the `track-git-tag` namespace

```bash
kubectl get all -n track-git-tag
```

</p>
</details>
