terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }

  required_version = ">= 1.11.0"

  backend "s3" {
    bucket       = "oyegokeodev-terraform-states"
    key          = "internal-psi-monitoring/staging/vpc/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "us-east-2"
}
