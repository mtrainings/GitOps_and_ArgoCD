# GitOps and ArgoCD Labs
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![alt text](images/argocd.png)

## Introduction
Welcome to the ArgoCD Labs repository! These labs are designed to guide you through various aspects of ArgoCD, a declarative, GitOps continuous delivery tool for Kubernetes.

## Content
1. [Install ArgoCD](LAB/Install_ArgoCD_.md)
    - Follow the instructions to install ArgoCD on your Kubernetes cluster.

2. [Access to ArgoCD server via UI](LAB/Access_to_ArgoCD_server_via_UI.md)
    - Learn how to access the ArgoCD server through the web-based user interface.

3. [Install ArgoCD CLI](LAB/Install_ArgoCD_CLI.md)
    - Set up and configure the ArgoCD Command Line Interface for managing applications.

4. [Create application declaratively with YAML](LAB/Create_application_declaratively_with_yaml.md)
    - Understand how to define and create applications using YAML manifests.

5. [Create application from CLI](LAB/Create_application_from_CLI.md)
    - Create applications using the ArgoCD CLI for command-line enthusiasts.

6. [Create application from UI](LAB/Create_application_from_UI.md)
    - Explore the process of creating applications via the ArgoCD web UI.

7. [HELM](LAB/HELM.md)
    - Learn how ArgoCD interacts with Helm charts for Kubernetes application deployment.

8. [Directory of files](LAB/Directory_of_files.md)
    - Understand the structure and organization of files within ArgoCD.

9. [Kustomize](LAB/Kustomize.md)
    - Dive into using Kustomize for customizing Kubernetes manifests.

10. [Create projects](LAB/Create_projects.md)
    - Explore the concept of projects in ArgoCD and how to create them.

11. [Create projects with role](LAB/Create_projects_with_role.md)
    - Learn how to create projects with specific roles for access control.

12. [Use private git repo using HTTPS/SSH](LAB/Private_git_repo.md)
    - Configure ArgoCD to work with private Git repositories using HTTPS or SSH.

13. [Tracking strategies Git tag/Git SHA](LAB/Tracking_strategies.md)
    - Understand different strategies for tracking changes using Git tags or Git SHAs.

14. [Diff customization](LAB/Diff_customization.md)
    - Customize the display of differences between application versions.

## Prerequisites
Ensure you meet the following prerequisites before starting the labs:
- A running Kubernetes cluster
- kubectl installed and configured
- Git installed
- Helm (optional, based on lab requirements)

## License
This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).

## Contribution
Feel free to contribute by opening issues or pull requests. Your feedback and improvements are highly appreciated!
