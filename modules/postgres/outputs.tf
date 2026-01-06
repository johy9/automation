################################################################################
# Connection Details
################################################################################

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.this.address
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.this.port
}

output "db_instance_endpoint" {
  description = "The connection endpoint (address:port)"
  value       = aws_db_instance.this.endpoint
}

output "db_name" {
  description = "The name of the database"
  value       = aws_db_instance.this.db_name
}

################################################################################
# Security & Credentials
################################################################################

output "db_master_user_secret_arn" {
  description = "The ARN of the master user secret (contains username and password) created by RDS"
  value       = try(aws_db_instance.this.master_user_secret[0].secret_arn, null)
}

output "db_security_group_id" {
  description = "The ID of the Security Group attached to the RDS instance"
  value       = aws_security_group.this.id
}

################################################################################
# Instance Metadata
################################################################################

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance (useful for CloudWatch/Performance Insights)"
  value       = aws_db_instance.this.resource_id
}