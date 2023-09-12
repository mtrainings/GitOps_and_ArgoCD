# Access to ArgoCD server via UI
1. Show admin for password for ArgoCD WebUI
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
2. Forward port for ArgoCD WebUI
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
3. As a login provide `admin` and as password provide this one from point 3