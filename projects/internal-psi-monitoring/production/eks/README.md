# EKS Cluster with ArgoCD Capability

This configuration deploys an EKS cluster with the AWS-managed ArgoCD Capability.

## ArgoCD Authentication

**Local Admin (Always Enabled):**
A built-in admin account is always available for break-glass access. Password is stored in AWS Secrets Manager.

**AWS IAM Identity Center (SSO):**
The AWS-managed ArgoCD Capability requires IAM Identity Center configuration (aws_idc). Local admin remains available as a break-glass option.

---

### Accessing ArgoCD with Local Admin

**Always available regardless of SSO configuration.**

1. Get the URL: `terraform output argocd_url`
2. Get the password from Secrets Manager:
   ```bash
   aws secretsmanager get-secret-value \
     --secret-id <argocd-secret-name> \
     --region us-east-2 \
     --query SecretString --output text
   ```
3. Login with username `admin` and the retrieved password

**Best For:** 
- Break-glass admin access
- Initial setup
- Troubleshooting when SSO fails

---

### Enabling AWS IAM Identity Center

Enables team SSO while keeping local admin as backup.

**Prerequisites:**
- AWS IAM Identity Center configured in your account
- IDC instance ARN (find it in IAM Identity Center console)

**Configuration:**
```hcl
# In terraform.tfvars
idc_instance_arn = "arn:aws:sso:::instance/ssoins-xxxxxxxxxxxxxxxx"
idc_region       = "us-east-1"  # Region where your IDC is deployed
```

**Access ArgoCD:**
1. Get the URL: `terraform output argocd_url`
2. Navigate to the URL - you'll be redirected to AWS SSO login
3. Login with your IAM Identity Center credentials

**Post-Deployment:**
1. Go to AWS Console → IAM Identity Center → Applications
2. Find the ArgoCD application (auto-created)
3. Assign users/groups to the application
4. Configure role mappings (Admin, ReadOnly, etc.)

**Best For:**
- Production team access
- Centralized access management
- Audit logging

---

## Required Variables

### With IAM Identity Center (Required for Managed Capability)
```hcl
project_name     = "internal-psi-monitoring"
environment      = "production"
cluster_version  = "1.32"
idc_instance_arn = "arn:aws:sso:::instance/ssoins-xxxxxxxxxxxxxxxx"
idc_region       = "us-east-1"
```

---

## Hub-and-Spoke Architecture

This ArgoCD instance acts as a **Hub** that can manage multiple **Spoke** clusters.

**To add a Spoke cluster:**
1. Deploy the spoke cluster with the EKS module
2. Grant ArgoCD IAM role access to the spoke:
   ```hcl
   access_entries = {
     (data.terraform_remote_state.hub_eks.outputs.capabilities["argocd"].role_arn) = {
       policy_associations = {
         cluster_admin = {
           policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
           access_scope = { type = "cluster" }
         }
       }
     }
   }
   ```
3. Register the spoke cluster in ArgoCD UI or via CLI

---

## Outputs

- `argocd_url` - The ArgoCD web interface URL
- `cluster_name` - EKS cluster name
- `cluster_endpoint` - Kubernetes API endpoint
