cluster_name       = "some-cluster-eks"
vpc_id             = "some_id"
region             = "us-east-2"
private_subnet_ids = ["jsjsj", "hshhs", "sjsjsk"]

argocd_namespace     = "argocd"
argocd_chart_version = "7.7.3"
create_namespace     = true

controller_replicas     = 3
server_replicas         = 3
repo_server_replicas    = 3
redis_ha_replicas       = 3
applicationset_replicas = 2

argocd_domain      = "argocd.example.com"
route53_zone_id    = "Z1234567890ABC"
certificate_arn    = ""    # If you have an ACM cert, add ARN
create_certificate = false # Set true to create ACM cert

enable_okta_auth     = true
okta_issuer_url      = "https://yourcompany.okta.com"
okta_client_id       = "your-okta-client-id"
okta_client_secret   = "your-okta-client-secret"
enable_github_auth   = false
github_org           = ""
github_client_id     = ""
github_client_secret = ""

admin_groups     = ["argocd-admins"]
developer_groups = ["argocd-developers"]
readonly_groups  = ["argocd-readonly"]

enable_metrics       = true
enable_notifications = true
additional_tags      = {}