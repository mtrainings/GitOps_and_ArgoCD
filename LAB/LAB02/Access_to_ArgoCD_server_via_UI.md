# Access to ArgoCD Server via UI

This exercise guides you on accessing the Argo CD Server via the WebUI. Follow these steps:

<details>
<summary><b>Solution</b></summary>
<p>

## 1. Retrieve the admin password for ArgoCD WebUI

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

## 2. Forward the port for ArgoCD WebUI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## 3. To log in, use the following credentials

* Username: admin
* Password: [Password obtained from step 1]

</p>
</details>
