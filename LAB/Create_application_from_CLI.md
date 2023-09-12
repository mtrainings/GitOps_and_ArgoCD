# Creating Argo CD Application from CLI
1. Forward port for ArgoCD
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
2. Login using CLI and start usig commands
```
argocd login 127.0.0.1:8080
```
2. Create application witn argo cli
```
argocd app create app-2 --repo https://github.com/spy86/argocd-example-apps.git --revision master --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace app-2 --sync-option CreateNamespace=true --grpc-web
```
3. Verify app is created
```
argocd app list --grpc-web
```
4. Sync the application 
```
argocd app sync app-2 --grpc-web
```
5. Verify app is synced
```
argocd app list --grpc-web
```