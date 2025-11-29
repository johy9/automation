output "vpc_id" {
  description = "The ID of the VPC created"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "The Public Subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnets" {
  description = "The Private Subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "vpc_arn" {
  description = "The ARN of the VPC created"
  value       = module.vpc.vpc_arn
}