# Create Projects with Role

<details>
<summary><b>Solution</b></summary>
<p>
## 1. Create an Argo CD Project Declaratively with the Following Specifications

**Example Manifest:**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: project-with-role
  namespace: argocd
spec:
  description: project with ci-role
  sourceRepos:
    - '*'
  destinations:
    - namespace: '*'
      server: '*'
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  namespaceResourceWhitelist:
    - group: '*'
      kind: '*'
  roles:
    - name: ci-role
      description: Sync privileges for project-with-role
      policies:
        - p, proj:project-with-role:ci-role, applications, sync, project-with-role/*, allow
        - p, proj:project-with-role:ci-role, applications, get, project-with-role/*, allow
```

## 2. Apply this Manifest with kubectl

```bash
kubectl apply -f project-with-role.yaml -n argocd
```

## 3. Verify if Projects are Deployed in ArgoCD

```bash
kubectl get appproject -n argocd
```

## 4. Create a Token Related to the Project Using CLI

```bash
argocd proj role create-token project-with-role ci-role --grpc-web
```

## 5. Try to Delete the Application Using the Generated Token

```bash
argocd app delete demo --grpc-web --auth-token TOKEN_VALUE
```

📓 Deleting should be denied because the roles do not grant delete permission

</p>
</details>
