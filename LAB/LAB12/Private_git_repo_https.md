# Use Private Git Repo Using HTTPS

## 1. Create a Secret for Private Repo

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-https
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://dev.azure.com/mtrainings/ArgoCD/_git/argocd-example-apps
  password: <PAT-TOKEN>
  username: my-token
```

## 2. Apply this Manifest with kubectl

```bash
kubectl apply -f repo-https.yaml -n argocd
```

## 3. Verify Secret is Created

```bash
kubectl get secret private-repo-https -n argocd
```

## 4. Retrieve the admin password for ArgoCD WebUI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

## 5. Verify Repo Status

* Go to the settings page.
* Open the repositories page.
* Verify the repo status.

## 6. Create an Application from the Private Git Repo

**Example Manifest:**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata: 
  name: app-1
  namespace: argocd
spec: 
  destination: 
    namespace: app-1
    server: "https://kubernetes.default.svc"
  project: default
  source: 
    path: guestbook
    repoURL: https://dev.azure.com/mtrainings/ArgoCD/_git/argocd-example-apps
    targetRevision: master
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
```

## 7. Apply this Manifest with kubectl

```bash
kubectl apply -f app.yaml -n argocd
```

## 8. Go to ArgoCD WebUI and Sync the Application
