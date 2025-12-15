variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.32"
}

# VPC Variables
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "availability_zone" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidr" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}
