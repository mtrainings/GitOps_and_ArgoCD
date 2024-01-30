# Creating Argo CD Application from CLI

This exercise demonstrates the process of creating an Argo CD application using the Command-Line Interface (CLI). Follow these steps:

<details>
<summary><b>Solution</b></summary>
<p>

## 1. Forward port for ArgoCD

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## 2. Login using CLI and start using commands

```bash
argocd login 127.0.0.1:8080
```

## 3. Create application with Argo CLI

```bash
argocd app create app-2 --repo https://github.com/spy86/argocd-example-apps.git --revision master --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace app-2 --sync-option CreateNamespace=true --grpc-web
```

## 4. Verify app is created

```bash
argocd app list --grpc-web
```

## 5. Sync the application

```bash
argocd app sync app-2 --grpc-web
```

## 6. Verify app is synced

```bash
argocd app list --grpc-web
```

</p>
</details>
