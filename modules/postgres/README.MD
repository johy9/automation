# AWS PostgreSQL RDS Terraform Module

This module provisions a secure, production-ready AWS RDS PostgreSQL instance, including networking, security, and outputs for integration with other infrastructure components.

## Features
- Creates a DB subnet group for high availability
- Configures a security group with fine-grained ingress controls
- Supports access via Security Groups and/or CIDR blocks
- Outputs all connection details and resource ARNs
- Tags all resources for governance and cost allocation

## Usage Example
```hcl
module "postgres" {
  source     = "./modules/postgres"
  identifier = "my-db"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  # Security
  allowed_security_groups = [module.eks.node_group_sg_id]
  allowed_cidr_blocks    = ["10.0.0.0/16"]

  # Optional tags
  tags = {
    Project     = "PSI"
    Environment = "Production"
  }
}
```

## Inputs
| Name                    | Description                                              | Type         | Default   | Required |
|-------------------------|----------------------------------------------------------|--------------|-----------|:--------:|
| identifier              | The name of the RDS instance                            | string       | n/a       | **Yes**  |
| vpc_id                  | VPC ID for the RDS instance                             | string       | n/a       | **Yes**  |
| subnet_ids              | List of subnet IDs for the DB subnet group               | list(string) | n/a       | **Yes**  |
| allowed_security_groups | Security Group IDs allowed to connect                    | list(string) | []        | No       |
| allowed_cidr_blocks     | CIDR blocks allowed to connect                           | list(string) | []        | No       |
| tags                    | Map of tags to apply to all resources                    | map(string)  | {}        | No       |
| engine_version          | PostgreSQL engine version                                | string       | "15.3"   | No       |

## Outputs
| Name                      | Description                                 |
|---------------------------|---------------------------------------------|
| db_instance_address       | The address of the RDS instance             |
| db_instance_port          | The database port                           |
| db_instance_endpoint      | The connection endpoint (address:port)      |
| db_name                   | The name of the database                    |
| db_master_user_secret_arn | ARN of the master user secret               |
| db_security_group_id      | Security Group ID attached to the instance  |
| db_instance_id            | The RDS instance ID                        |
| db_instance_arn           | The ARN of the RDS instance                |
| db_instance_resource_id   | RDS Resource ID (for CloudWatch, Insights)  |

## Deployment & Authentication
1. Ensure AWS credentials are configured (via AWS CLI or environment variables).
2. Run `terraform init` and `terraform apply` in your project directory.
3. Retrieve connection details from Terraform outputs.
4. Use the `db_master_user_secret_arn` to fetch credentials securely from AWS Secrets Manager.

## How-To: Connect to the Database
- Use the endpoint and port from outputs.
- Fetch credentials from Secrets Manager:
  ```bash
  aws secretsmanager get-secret-value --secret-id <db_master_user_secret_arn>
  ```
- Connect using any PostgreSQL client:
  ```bash
  psql -h <db_instance_address> -U <username> -d <db_name> -p <db_instance_port>
  ```

## Notes
- Only private subnets should be used for production deployments.
- Security group and CIDR rules should be as restrictive as possible.
- All resources are tagged for cost allocation and governance.
