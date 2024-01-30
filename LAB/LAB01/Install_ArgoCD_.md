# Install ArgoCD

This exercise guides you through the installation of Argo CD, a declarative, GitOps continuous delivery tool for Kubernetes. Follow these steps:

<details>
<summary><b>Solution</b></summary>
<p>

## 1. Install Argo CD using Non-HA manifests in the argocd namespace

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## 2. After installing Argo CD, ensure that pods are running and ready

```bash
kubectl get po -n argocd
```

## 3. Show admin password for ArgoCD WebUI

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

## 4. Forward port for Argo CD WebUI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## 5. For login, provide `admin`, and as the password, use the one obtained in step 3

</p>
</details>
