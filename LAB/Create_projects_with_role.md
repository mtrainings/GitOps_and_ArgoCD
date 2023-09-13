# Create projects with role
1. Create an Argo CD project declaratively with below specs

Example manifest:
---
```
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
2. Apply this manifest with kubectl
```
kubectl apply -f project-with-role.yaml -n argocd
```
3. Verify if project are deployed in ArgoCD
```
kubectl get appproject -n argocd
```
4. Create a token related to project using CLI.
```
argocd proj role create-token project-with-role ci-role --grpc-web
```
5. Try to delete the application using the generated token.
```
argocd app delete demo --grpc-web --auth-token TOKEN_VALUE
```
📓 Deleting should be denied because the roles does not grant delete permission

6. Try to sync the application using the token
```
argocd app sync demo --grpc-web --auth-token TOKEN_VALUE
```
📓 Sync should work because role has the sync permission
