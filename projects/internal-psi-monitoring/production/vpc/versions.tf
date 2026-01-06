terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.83.0"
    }
  }

  required_version = ">= 1.11.0"

  backend "s3" {
    bucket       = "oyegokeo-terraform-states"
    key          = "internal-psi-monitoring/production/vpcc/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "us-east-2"
}
