project_name    = "internal-psi-monitoring"
environment     = "production"
cluster_version = "1.32"

# ArgoCD Authentication Configuration
# The AWS-managed ArgoCD Capability currently requires AWS IAM Identity Center (SSO)
# configuration via aws_idc. When enabled, local admin is still available as a
# break-glass option (password stored in AWS Secrets Manager).

# Set these to enable the managed ArgoCD capability:
# idc_instance_arn = "arn:aws:sso:::instance/ssoins-xxxxxxxxxxxxxxxx"
# idc_region       = "us-east-1"
