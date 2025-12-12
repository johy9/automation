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

## Referencing modules by git tag

When consuming modules from this repository via Git (instead of the Terraform Registry), include the repository URL, the module subdirectory and a `ref` query parameter. The `ref` value may be a branch name, a tag, or a commit SHA. It's recommended to use tags for reproducible builds.

Example (HTTPS, using a tag):

```hcl
module "module_name" {
  source = "git::https://github.com/RingCentral-Pro-Services/psi-terraform.git//modules/vpc?ref=v1.2.0"

  # module input variables (example)
}
```

- CI/CD & PR checks
  - Run `terraform fmt`, `terraform validate`, `tflint`, `tfsec`/`checkov`, and `terraform plan` in PR pipelines.
  - Require successful plan and reviews before merging.
  - Apply from CI/CD pipelines (avoid manual developer applies to shared state).

- Secrets and sensitive data
  - Never commit secrets or tfvars with secrets.
  - Use Vault / AWS SSM / Secrets Manager and inject secrets via CI or runtime.
  - Mark sensitive variables with `sensitive = true`.

## Example consumer snippet (pin by tag)
```hcl
module "vpc" {
  source = "git::https://github.com/RingCentral-Pro-Services/psi-terraform.git//modules/vpc?ref=v1.2.0"
  # inputs...
}