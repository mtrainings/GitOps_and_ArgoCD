# Creating Argo CD Application from UI

This exercise guides you through the process of creating an Argo CD application using the Web User Interface (UI). Follow these steps:

<details>
<summary><b>Solution</b></summary>
<p>

## 1. Create an Argo CD application using the Web UI by clicking the `New App` button

   **Specification:**

- Name: `app-1`
- Project: `default`
- Sync options: Select `auto create namespace`.
- Source repo: `https://github.com/spy86/argocd-example-apps.git`
- Source path: `guestbook`
- Source branch: `master`
- Destination cluster URL: `https://kubernetes.default.svc`
- Destination namespace: `app-1`

</p>
</details>
