terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.24"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
  }

  required_version = ">= 1.11.0"

  backend "s3" {
    bucket = "oyegokeo-terraform-states"
    # bucket       = "ringcentral-terraform-states"
    key          = "internal-psi-monitoring/production/addons/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "us-east-2"
}
