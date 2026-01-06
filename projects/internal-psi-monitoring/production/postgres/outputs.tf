output "db_instance_endpoint" {
  description = "The endpoint of the PostgreSQL instance."
  value       = module.postgres.db_instance_endpoint
}

output "db_instance_identifier" {
  description = "The identifier of the PostgreSQL instance."
  value       = module.postgres.db_instance_identifier
}
