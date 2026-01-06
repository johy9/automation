################################################################################
# General
################################################################################

variable "identifier" {
  description = "The name of the RDS instance (will also be used for tags and related resources)"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Network
################################################################################

variable "vpc_id" {
  description = "The VPC ID where the RDS instance will be created (used for Security Group creation)"
  type        = string
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs (Private subnets recommended)"
  type        = list(string)
}

variable "allowed_security_groups" {
  description = "List of Security Group IDs allowed to connect to the DB (e.g. App SG)"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect to the DB (Use with caution)"
  type        = list(string)
  default     = []
}

################################################################################
# Database Engine & Compute
################################################################################

variable "engine_version" {
  description = "Postgres engine version (e.g., '14.7', '15.3')"
  type        = string
  default     = "15.3"
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "family" {
  description = "The family of the DB parameter group (must match engine version, e.g., 'postgres15')"
  type        = string
  default     = "postgres15"
}

################################################################################
# Storage
################################################################################

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Upper limit for storage autoscaling (set to 0 to disable)"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "One of 'standard' (magnetic), 'gp2', 'gp3', or 'io1'"
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. If null, default is used"
  type        = string
  default     = null
}

################################################################################
# Credentials & Security
################################################################################

variable "db_name" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
  default     = "appdb"
}

variable "username" {
  description = "Username for the master DB user"
  type        = string
  default     = "postgres"
}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the password in Secrets Manager (Recommended)"
  type        = bool
  default     = true
}

################################################################################
# High Availability & Maintenance
################################################################################

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

variable "maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'"
  type        = string
  default     = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created"
  type        = string
  default     = "03:00-06:00"
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted"
  type        = bool
  default     = true
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled"
  type        = bool
  default     = true
}