# Installing Argo CD CLI

1. Install Argo CD CLI, use the below commands
```
wget -O /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.8.1/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
```
2. Verify that CLI is installed
```
argocd
```
3. Forward port for ArgoCD
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
4. Login using CLI and start usig commands
```
argocd login 127.0.0.1:8080
```
5. Check connection 
```
argocd cluster list --grpc-web
```