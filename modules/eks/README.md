# AWS EKS Terraform Module

This module provisions an Amazon EKS (Elastic Kubernetes Service) cluster with the following features:
- EKS Control Plane with API authentication enabled.
- Managed Node Groups with customizable scaling and instance types.
- OIDC Identity Provider for IAM Roles for Service Accounts (IRSA).
- Standard EKS Add-ons (VPC CNI, CoreDNS, Kube-proxy, EBS CSI Driver).
- IAM Roles for Node Groups and Add-ons (e.g., EBS CSI Driver).
- Standardized naming and tagging conventions (`psi-{project}-{env}-{resource}`).

## Usage

```hcl
module "eks" {
  source = "../../modules/eks"

  project_name = "psi"
  environment  = "staging"
  cluster_name = "psi-staging-cluster"
  
  # Networking
  subnet_ids = ["subnet-12345678", "subnet-87654321"] # Private subnets recommended

  # Node Groups
  node_groups = {
    general = {
      desired_size   = 2
      max_size       = 3
      min_size       = 1
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  # Add-ons (Optional customization)
  addons = {
    vpc-cni            = {}
    coredns            = {}
    kube-proxy         = {}
    aws-ebs-csi-driver = {}
  }

  additional_tags = {
    Project     = "PSI"
    Environment = "Staging"
    Owner       = "DevOps"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.30 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_name` | Project name to be used for tagging resources | `string` | n/a | yes |
| `environment` | Environment name (e.g., staging, production) | `string` | n/a | yes |
| `cluster_name` | Name of the EKS cluster | `string` | n/a | yes |
| `cluster_version` | Kubernetes version to use for the EKS cluster | `string` | `"1.30"` | no |
| `subnet_ids` | List of subnet IDs. Must be in at least two different AZs. | `list(string)` | n/a | yes |
| `endpoint_private_access` | Whether the Amazon EKS private API server endpoint is enabled | `bool` | `true` | no |
| `endpoint_public_access` | Whether the Amazon EKS public API server endpoint is enabled | `bool` | `false` | no |
| `public_access_cidrs` | List of CIDR blocks which can access the Amazon EKS public API server endpoint | `list(string)` | `["0.0.0.0/0"]` | no |
| `node_groups` | Map of node group configurations | `map(object)` | `{}` | no |
| `addons` | Map of EKS add-ons to enable | `map(object)` | `{...}` | no |
| `additional_tags` | Additional tags to be applied to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_name` | The name of the EKS cluster |
| `cluster_endpoint` | The endpoint for the EKS cluster API server |
| `cluster_certificate_authority_data` | Base64 encoded certificate data required to communicate with the cluster |
| `cluster_arn` | The Amazon Resource Name (ARN) of the cluster |
| `cluster_oidc_issuer_url` | The URL on the EKS cluster for the OpenID Connect identity provider |
| `oidc_provider_arn` | The ARN of the OIDC Provider |
| `node_group_arns` | List of ARNs of the EKS Node Groups |
| `node_group_role_arn` | IAM Role ARN for the Node Groups |

## Notes

- **Authentication**: This module sets `authentication_mode = "API"`. Ensure you configure access entries if you need to grant access to other IAM principals.
- **Add-ons**: The `aws-ebs-csi-driver` add-on automatically creates the necessary IAM role for Service Accounts (IRSA) with the `AmazonEBSCSIDriverPolicy`.
