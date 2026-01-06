variable "project_name" {
  description = "Project name for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)."
  type        = string
}

variable "db_name" {
  description = "Name of the PostgreSQL database."
  type        = string
}

variable "db_username" {
  description = "PostgreSQL admin username."
  type        = string
}

variable "db_password" {
  description = "PostgreSQL admin password."
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID for the database."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the database."
  type        = list(string)
}
