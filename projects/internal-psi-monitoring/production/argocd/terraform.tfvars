region             = "us-east-2"

argocd_namespace     = "argocd"
argocd_chart_version = "9.1.10"
create_namespace     = true

controller_replicas     = 3
server_replicas         = 3
repo_server_replicas    = 3
redis_ha_replicas       = 3
applicationset_replicas = 2

argocd_domain      = "games.oyegokeodev.com"
route53_zone_id    = "Z04422903TL2OJKQ4IG26"
certificate_arn    = "arn:aws:acm:us-east-2:172316546414:certificate/71a02a73-170c-40cc-aad3-f86897a0290d"
create_certificate = false # Set true to create ACM cert

enable_okta_auth     = true
okta_issuer_url      = "" #https://yourcompany.okta.com
okta_client_id       = ""
okta_client_secret   = ""
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