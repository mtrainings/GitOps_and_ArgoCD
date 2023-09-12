# Install ArgoCD

1. Install Argo CD using Non-HA manifests in argocd namespace.
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
2. After installing Argo CD, make sure that pods are running and ready.
```
kubectl get po -n argocd
```
3. Show admin for password for ArgoCD WebUI
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
4. Forward port for ArgoCD WebUI
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
5. As a login provide `admin` and as password provide this one from point 3