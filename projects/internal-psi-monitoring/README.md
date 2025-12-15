# Internal PSI Monitoring Infrastructure

This project manages the infrastructure for the Internal PSI Monitoring system on AWS. It utilizes a layered Terraform approach to provision networking, the Kubernetes cluster (EKS), and essential cluster add-ons.

## Architecture Overview

The infrastructure is designed with modularity and separation of concerns in mind:

1.  **VPC Layer**: Establishes the networking foundation (VPC, Subnets, NAT Gateways) with strict tagging compliance.
2.  **EKS Layer**: Provisions the Amazon EKS cluster (v1.32), Node Groups, and IAM roles using **EKS Pod Identity**.
3.  **Add-ons Layer**: Deploys operational software via Helm, including **Karpenter** for autoscaling and **AWS Load Balancer Controller** for ingress management.

## Prerequisites

Before you begin, ensure you have the following installed:

*   [Terraform](https://www.terraform.io/downloads) (v1.11.0+)
*   [AWS CLI](https://aws.amazon.com/cli/) (configured with appropriate credentials)
*   [kubectl](https://kubernetes.io/docs/tasks/tools/)

## Repository Structure

```
projects/internal-psi-monitoring/
├── production/
│   ├── vpc/          # Layer 1: Networking
│   ├── eks/          # Layer 2: Kubernetes Cluster & IAM
│   ├── addons/       # Layer 3: Helm Charts (Karpenter, ALB)
│   └── eks-test/     # Independent test fixture
└── staging/          # (Structure mirrors production)
```

## Deployment Guide

The infrastructure must be deployed in a specific sequence due to dependencies (State files are shared via remote state).

### Step 1: Networking (VPC)

This layer creates the VPC, subnets, and applies the `psi_*` tagging policy required for cost allocation and resource management.

1.  Navigate to the VPC directory:
    ```bash
    cd projects/internal-psi-monitoring/production/vpc
    ```
2.  Initialize and Apply:
    ```bash
    terraform init
    terraform apply
    ```
    *Review the plan to ensure tags and CIDR blocks are correct before confirming.*

### Step 2: Kubernetes Cluster (EKS)

This layer creates the EKS Control Plane (v1.32) and Managed Node Groups. It also configures **EKS Pod Identity** associations for the add-ons.

1.  Navigate to the EKS directory:
    ```bash
    cd ../eks
    ```
2.  Initialize and Apply:
    ```bash
    terraform init
    terraform apply
    ```
    *Note: This step may take 15-20 minutes.*

3.  **Configure kubectl**:
    After the cluster is created, update your local kubeconfig to interact with it:
    ```bash
    aws eks update-kubeconfig --region us-east-2 --name internal-psi-monitoring-production-cluster
    ```

### Step 3: Cluster Add-ons

This layer installs software into the cluster. It uses the IAM roles created in Step 2.

*   **Karpenter**: High-performance Kubernetes autoscaler.
*   **AWS Load Balancer Controller**: Manages ALBs/NLBs for Ingress and Services.

1.  Navigate to the Addons directory:
    ```bash
    cd ../addons
    ```
2.  Initialize and Apply:
    ```bash
    terraform init
    terraform apply
    ```

## Key Features & Configuration

### Tagging Policy
All resources are automatically tagged with the following standard tags for governance:
*   `psi_environment`: production
*   `psi_cost_center`: internal
*   `psi_application_name`: internal_psi_monitoring
*   `psi_managed_by`: terraform

### EKS Pod Identity
We use EKS Pod Identity (instead of IRSA) to grant AWS permissions to Kubernetes workloads.
*   **Karpenter**: Uses a Pod Identity association to manage EC2 instances.
*   **ALB Controller**: Uses a Pod Identity association to manage Elastic Load Balancers.

### Karpenter Configuration
Karpenter is configured with:
*   **EC2NodeClass**: Defines AWS-specific settings (Subnets, Security Groups, AMI).
*   **NodePool**: Defines scheduling constraints (Instance types, Zones, Capacity type).

## Troubleshooting

*   **State Locking**: If you encounter a state lock error, ensure no other team member is running a deployment.
*   **Karpenter Nodes**: If Karpenter fails to launch nodes, check the controller logs:
    ```bash
    kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter
    ```
*   **ALB Not Created**: If Ingress resources don't create ALBs, check the controller logs:
    ```bash
    kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
    ```
