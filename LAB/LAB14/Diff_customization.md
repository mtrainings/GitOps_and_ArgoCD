# Diff Customization (Ignore Differences for Deployment Replicas)

<details>
<summary><b>Solution</b></summary>
<p>
## 1. Create an Argo CD Application Declaratively Using YAML with the Following Specifications

```yaml
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

## 2. Apply this Manifest with kubectl

```bash
kubectl apply -f app.yaml -n argocd
```

## 3. Verify App

```bash
kubectl get application -n argocd
```

## 4. Verify that Resources are Created in diffing-customization-demo Namespace

```bash
kubectl get all -n diffing-customization-demo
```

## 5. Scale the Deployment into 3 Replicas Using kubectl

```bash
kubectl scale deployment/guestbook-ui -n diffing-customization-demo --replicas=3
```

## 6. Retrieve the admin password for ArgoCD WebUI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

## 7. Refresh the Application in Argo CD

</p>
</details>
