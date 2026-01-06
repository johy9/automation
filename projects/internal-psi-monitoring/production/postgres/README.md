# PostgreSQL Project

This project deploys a PostgreSQL instance using the reusable `modules/postgreS` Terraform module.

## Usage

Update the variables in `terraform.tfvars` or provide them via environment variables/CLI.

```
module "postgres" {
  source      = "../../modules/postgreS"
  project_name = "myproject"
  environment  = "dev"
  db_name      = "mydb"
  db_username  = "admin"
  db_password  = "supersecret"
  vpc_id       = "vpc-xxxxxxx"
  subnet_ids   = ["subnet-xxxxxx", "subnet-yyyyyy"]
}
```

## Variables
- `project_name`: Project name for resource naming
- `environment`: Deployment environment (dev, prod, etc.)
- `db_name`: Name of the PostgreSQL database
- `db_username`: Admin username
- `db_password`: Admin password (sensitive)
- `vpc_id`: VPC ID for the database
- `subnet_ids`: List of subnet IDs

## Outputs
- `db_instance_endpoint`: The endpoint of the PostgreSQL instance
- `db_instance_identifier`: The identifier of the PostgreSQL instance

## How to Apply

1. Fill in your variables in `terraform.tfvars`.
2. Run:
   ```
   terraform init
   terraform apply
   ```
