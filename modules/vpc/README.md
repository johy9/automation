# AWS VPC Terraform Module

This module creates a flexible AWS VPC suitable for various use cases, including EKS clusters, standard 3-tier web applications, public-only networks, and isolated private networks.

## Features

*   **Flexible Subnetting**: Create Public and Private subnets based on the CIDR lists provided.
*   **EKS Ready**: Optional tagging for EKS Load Balancer discovery (`kubernetes.io/role/elb`).
*   **Cost Optimized**: Support for Single NAT Gateway (Dev) or One NAT Gateway per AZ (Prod).
*   **Security**: Optional Internet Gateway and NAT Gateway creation for isolated networks.
*   **Lifecycle Management**: Ignores manual tag changes to allow for external tagging strategies.

## Usage Examples

### 1. Standard Use Case (EKS / Web App)
Creates a VPC with Public and Private subnets, Internet Gateway, and a Single NAT Gateway (cost-effective).

```hcl
module "vpc" {
  source = "./modules/vpc"

  project_name        = "my-eks-cluster"
  vpc_cidr            = "10.0.0.0/16"
  availability_zone   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  # Subnets
  public_subnet_cidr  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidr = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # EKS Tags (Optional)
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
```

### 2. Production High Availability
Creates a NAT Gateway in *every* Availability Zone for maximum reliability.

```hcl
module "vpc" {
  source = "./modules/vpc"

  # ... other vars ...
  
  single_nat_gateway = false # Default is true
}
```

### 3. Public-Only VPC (Bastion / Static Site)
Creates only public subnets. No NAT Gateway is created because there are no private subnets.

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidr = [] # Empty list = No private subnets
}
```

### 4. Private-Only VPC (Isolated Backend)
Creates a VPC with no internet access (No IGW, No NAT).

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = [] # No public subnets
  private_subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
  
  create_igw          = false
  enable_nat_gateway  = false
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `vpc_cidr` | The IP range for the VPC (e.g., 10.0.0.0/16). | `string` | n/a | **Yes** |
| `public_subnet_cidr` | List of CIDR blocks for public subnets. | `list(string)` | n/a | **Yes** |
| `private_subnet_cidr` | List of CIDR blocks for private subnets. | `list(string)` | n/a | **Yes** |
| `project_name` | Project name used for resource tagging. | `string` | `"learning-terraform"` | No |
| `availability_zone` | List of availability zones to deploy into. | `list(string)` | `["us-east-1a", "us-east-1b", "us-east-1c"]` | No |
| `create_igw` | Controls if an Internet Gateway is created. | `bool` | `true` | No |
| `enable_nat_gateway` | Controls if NAT Gateways are created for private subnets. | `bool` | `true` | No |
| `single_nat_gateway` | If true, a single shared NAT Gateway is used. If false, one per AZ. | `bool` | `true` | No |
| `public_subnet_tags` | Additional tags for public subnets (e.g., for EKS). | `map(string)` | `{}` | No |
| `private_subnet_tags` | Additional tags for private subnets. | `map(string)` | `{}` | No |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | The ID of the VPC. |
| `vpc_cidr_block` | The CIDR block of the VPC. |
| `public_subnet_ids` | List of IDs of public subnets. |
| `private_subnet_ids` | List of IDs of private subnets. |
| `nat_gateway_ids` | List of IDs of NAT Gateways. |
| `internet_gateway_id` | The ID of the Internet Gateway (or null). |

## CI/CD Workflow

This project uses GitHub Actions for Continuous Integration and Deployment. The workflow is defined in `.github/workflows/internal-psi-monitoring.yaml`.

### Workflow Steps
1.  **Plan**: Triggered on Pull Requests, Pushes to main, or manually via `workflow_dispatch`.
2.  **Apply**: Triggered manually via `workflow_dispatch` (requires `plan` to be successful).

### Configuration & Secrets

To ensure security and flexibility, sensitive or environment-specific variables are managed via GitHub Secrets and Variables.

#### 1. AWS Credentials (Secrets)
You must configure the following **Repository Secrets** to allow Terraform to authenticate with AWS:
*   `AWS_ACCESS_KEY_ID`: Your AWS Access Key.
*   `AWS_SECRET_ACCESS_KEY`: Your AWS Secret Key.

#### 2. Terraform Variables (Repository Variables)
If you choose **not** to commit your `terraform.tfvars` file to the repository (recommended for security), you must provide the content of these files via **Repository Variables**. The pipeline will automatically inject these variables into a `terraform.tfvars` file during the build process.

*   **`STAGING_TFVARS`**: Paste the entire content of your staging `terraform.tfvars` file here.
*   **`PROD_TFVARS`**: Paste the entire content of your production `terraform.tfvars` file here.

**Note:** If a `terraform.tfvars` file exists in the repository, the pipeline will use it. The Repository Variable injection only happens if the file is missing.
