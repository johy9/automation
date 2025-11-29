variable "vpc_cidr" {
  description = "The IP range for the VPC"
  type        = string
  default     = "10.0.0.0/22"
}

variable "project_name" {
  description = "Project name to be used for tagging resources"
  type        = string
  default     = "learning-terraform"
}

variable "availability_zone" {
  description = "The list of availability zones"
  type = list(string)
  default = [ "us-east-1a", "us-east-1b", "us-east-1c" ]
}

variable "public_subnet_cidr" {
  description = "The list of public subnet CIDRs"
  type = list(string)
  default = [ "10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24" ]
}

variable "private_subnet_cidr" {
  description = "The list of private subnet CIDRs"
  type = list(string)
  default = [ "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24" ]
}