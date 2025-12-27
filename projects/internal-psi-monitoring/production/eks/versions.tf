terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30"
    }
  }

  required_version = ">= 1.11.0"

  backend "s3" {
    bucket = "oyegokeodev-terraform-states"
    # bucket       = "ringcentral-terraform-states"
    key          = "internal-psi-monitoring/production/eks/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "us-east-2"
}
