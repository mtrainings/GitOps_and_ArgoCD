# Installing Argo CD CLI

<details>
<summary><b>Solution</b></summary>
<p>
## 1. Install Argo CD CLI using the following commands

```bash
wget -O /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.8.1/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
```

## 2. Verify that the CLI is installed

```bash
argocd
```

## 3. Forward port for Argo CD

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## 4. Login using the CLI and start using commands

```bash
argocd login 127.0.0.1:8080
```

## 5. Check connection

```bash
argocd cluster list --grpc-web
```

</p>
</details>
