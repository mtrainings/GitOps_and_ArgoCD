# Use private git repo using https
1. Create secret for provate repo
```
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-https
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://spy8681@bitbucket.org/spy8681/argocd-example-apps.git
  password: <PAT-TOKEN>
  username: my-token
```
2. Apply this manifest with kubectl
```
kubectl apply -f repo.yaml -n argocd
```
3. Verify secret is created
```
kubectl get secret private-repo-https -n argocd
```
4. Login into ArgoCD WebUI
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
5. Verify Repo Status
* Go to settings page.
* Open repositories page.
* Verify the repo status.

6. Create an Application from private git repo:

Example manifest
---
```
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
    repoURL: https://spy8681@bitbucket.org/spy8681/argocd-example-apps.git
    targetRevision: master
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
```
7. Apply this manifest with kubectl
```
kubectl apply -f app.yaml -n argocd
```

8. Go to ArgoCD WebUI and Sync application


# Use private git repo using ssh
1. Create secret for provate repo
```
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-ssh
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: bitbucket.org:spy8681/argocd-example-apps.git
  sshPrivateKey: |
    -----BEGIN OPENSSH PRIVATE KEY-----
     # private key goes here
    -----END OPENSSH PRIVATE KEY----
```
2. Apply this manifest with kubectl
```
kubectl apply -f repo.yaml -n argocd
```
3. Verify secret is created
```
kubectl get secret private-repo-ssh -n argocd
```
4. Login into ArgoCD WebUI
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
5. Verify Repo Status
* Go to settings page.
* Open repositories page.
* Verify the repo status.

6. Create an Application from private git repo:

Example manifest
---
```
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
    repoURL: bitbucket.org:spy8681/argocd-example-apps.git
    targetRevision: master
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
```
7. Apply this manifest with kubectl
```
kubectl apply -f app.yaml -n argocd
```
8. Go to ArgoCD WebUI and Sync application
