terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30, < 6.0" # Required for EKS Access Entries
    }
  }
}
