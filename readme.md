# EKS Monitoring Cluster

This Terraform project deploys a comprehensive EKS (Elastic Kubernetes Service) cluster on AWS, specifically designed for monitoring purposes. It includes a dedicated VPC, necessary IAM roles, the EKS cluster itself, and an Application Load Balancer configured for services like Grafana.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

*   **Terraform:** Version 1.0 or higher.
*   **AWS CLI:** Configured with the necessary credentials and permissions to create the resources defined in this project.
*   **AWS Account:** An active AWS account.

## Configuration

This project is structured to support multiple environments (e.g., `staging`, `production`) through a dedicated `environments` directory. Each environment has its own backend configuration and variable definitions.

### Environment Setup

1.  **Backend Configuration:**
    Each environment directory (e.g., `environments/production`) contains a `backend.config` file. This file is used to configure the Terraform backend, specifying where the state file should be stored. You will need to update this file with your S3 bucket details.

    Example `environments/production/backend.config`:
    ```
    bucket         = "your-terraform-state-bucket"
    key            = "monitoring-eks/production/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "your-terraform-lock-table"
    ```

2.  **Environment Variables:**
    Each environment directory also contains a `terraform.tfvars` file. This file is used to set the values for the input variables required by the Terraform modules.

    The following variables should be defined in each `terraform.tfvars` file:

    *   `aws_region`: The AWS region for the environment.
    *   `environment`: The name of the environment (e.g., `"production"`).
    *   `project_name`: A name for the project in this environment.
    *   `grafana_domain_name`: The domain name for the Grafana dashboard.
    *   `route53_zone_id`: The ID of the Route 53 hosted zone for the domain.
    *   `acm_certificate_arn`: The ARN of the ACM certificate for the domain.

## Usage

All Terraform commands should be run from the root of the project.

### Deployment

1.  **Initialize Terraform for a specific environment:**
    Replace `production` with the desired environment (`staging`, etc.).

    ```bash
    terraform init -backend-config=environments/production/backend.config
    ```

2.  **Plan the deployment:**
    ```bash
    terraform plan -var-file="environments/production/terraform.tfvars"
    ```

3.  **Apply the changes:**
    ```bash
    terraform apply -var-file="environments/production/terraform.tfvars"
    ```

### Destroy

To tear down the infrastructure for a specific environment, run the following command:

```bash
terraform destroy -var-file="environments/production/terraform.tfvars"
```

## Resources Created

This Terraform project will create the following resources in your AWS account:

### VPC Module

*   **aws_vpc:** The main VPC for the EKS cluster.
*   **aws_subnet (public):** Public subnets for the VPC.
*   **aws_subnet (private):** Private subnets for the VPC.
*   **aws_internet_gateway:** Internet gateway for the VPC.
*   **aws_eip (NAT):** Elastic IP for the NAT gateway.
*   **aws_nat_gateway:** NAT gateway for the private subnets.
*   **aws_route_table (public):** Route table for the public subnets.
*   **aws_route_table (private):** Route table for the private subnets.
*   **aws_route_table_association (public):** Associations for the public route table.
*   **aws_route_table_association (private):** Associations for the private route table.

### EKS IAM Module

*   **aws_iam_role (cluster):** IAM role for the EKS cluster.
*   **aws_iam_policy_attachment (cluster_policy):** Attaches the `AmazonEKSClusterPolicy` to the cluster role.
*   **aws_iam_role (node_group):** IAM role for the EKS node group.
*   **aws_iam_policy_attachment (node_worker_policy):** Attaches the `AmazonEKSWorkerNodePolicy` to the node group role.
*   **aws_iam_policy_attachment (node_cni_policy):** Attaches the `AmazonEKS_CNI_Policy` to the node group role.
*   **aws_iam_policy_attachment (node_ecr_readonly_policy):** Attaches the `AmazonEC2ContainerRegistryReadOnly` policy to the node group role.
*   **aws_iam_openid_connect_provider:** OIDC provider for IRSA (IAM Roles for Service Accounts).

### EKS Cluster Module

*   **aws_security_group (cluster):** Security group for the EKS cluster control plane.
*   **aws_security_group (nodes):** Security group for the EKS worker nodes.
*   **aws_security_group_rule:** Rules for communication between the cluster and nodes.
*   **aws_eks_cluster:** The EKS cluster.
*   **aws_eks_node_group:** The EKS node group.
*   **aws_eks_addon (vpc-cni):** EKS addon for VPC CNI.
*   **aws_eks_addon (kube-proxy):** EKS addon for kube-proxy.
*   **aws_eks_addon (coredns):** EKS addon for CoreDNS.

### Monitoring Ingress Module

*   **aws_security_group (alb):** Security group for the Application Load Balancer.
*   **aws_lb:** The Application Load Balancer.
*   **aws_lb_target_group (grafana):** Target group for the Grafana service.
*   **aws_lb_listener (http_redirect):** Listener for HTTP to HTTPS redirection.
*   **aws_lb_listener (https):** Listener for HTTPS traffic.
*   **aws_route53_record (grafana):** Route 53 record for the Grafana dashboard.
