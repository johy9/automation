# Centralized Terraform Infrastructure Repository

This repository serves as the single source of truth for all **Terraform modules** and **project configurations** used to provision and manage infrastructure across all environments (e.g. staging, prod).

## Getting Started

To use this repository, you'll need the following installed:

  * **Terraform** (latest stable version)
  * **A configured cloud provider CLI** (e.g., AWS CLI)
  * **Git**

### Repository Structure

This standardized structure ensures consistency and separation of concerns:

| Directory | Purpose |
| :--- | :--- |
| **`modules/`** | Contains reusable, opinionated infrastructure components (e.g., VPC, EKS Cluster, Lambda Function). These are the building blocks. |
| **`projects/`** | Contains environment-specific configurations that consume the modules to provision a complete application or service. |

-----

## Managing a Project

A "project" is the instantiation of your infrastructure for a specific application or service in a given environment.

1.  **Navigate** to the desired project directory (e.g., `cd projects/api-service/staging`).
2.  **Initialize** the backend and plugins:
    ```bash
    terraform init
    ```
3.  **Review** the execution plan:
    ```bash
    terraform plan -var-file="staging.tfvars" -out=tfplan
    ```
4.  **Apply** the changes:
    ```bash
    terraform apply "tfplan"
    ```

### State Management

  * **Backend:** All Terraform state is configured to use a remote backend (e.g., AWS S3) for collaboration and security. The backend is configured within the `versions.tf` file of each project directory.
  * **Locking:** State locking is enforced by the configured backend to prevent concurrent updates.

-----

## Contribution Guidelines

We enforce **standardized module conventions** to maintain code quality and reusability.

1.  **Branching:** Use a feature branch for all changes (e.g., `feat/add-new-module`).
2.  **PRs:** All changes must be reviewed and approved via a **Pull Request** before merging into the main branch and creating a tag
