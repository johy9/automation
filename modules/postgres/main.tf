################################################################################
# 1. Network: Subnet Group
################################################################################

resource "aws_db_subnet_group" "this" {
  name        = "${var.identifier}-subnet-group"
  description = "Database subnet group for ${var.identifier}"
  subnet_ids  = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.identifier}-subnet-group"
  })
}

################################################################################
# 2. Security: DB Security Group & Rules
################################################################################

# The Security Group attached to the RDS instance itself
resource "aws_security_group" "this" {
  name_prefix = "${var.identifier}-sg-"
  description = "Security Group for ${var.identifier} RDS instance"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.identifier}-sg"
  })

  # Ensure the SG is created before the RDS instance tries to use it
  lifecycle {
    create_before_destroy = true
  }
}

# Rule: Allow traffic from specific Application Security Groups
resource "aws_security_group_rule" "ingress_security_groups" {
  count = length(var.allowed_security_groups) > 0 ? length(var.allowed_security_groups) : 0

  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_groups[count.index]
  security_group_id        = aws_security_group.this.id
  description              = "Allow Postgres access from App SG"
}

# Rule: Allow traffic from specific CIDR blocks (e.g., VPN)
resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count = length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.this.id
  description       = "Allow Postgres access from CIDRs"
}

# Rule: Allow all egress (RDS usually needs to talk to AWS services)
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

################################################################################
# 3. Configuration: Parameter Group
################################################################################

resource "aws_db_parameter_group" "this" {
  name_prefix = "${var.identifier}-pg-"
  family      = var.family
  description = "Postgres parameter group for ${var.identifier}"

  # Example of a common tuning parameter (logging slow queries)
  # You can make this dynamic later if you want to pass parameters via variables
  parameter {
    name  = "log_min_duration_statement"
    value = "2000" # Log queries taking longer than 2s
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# 4. Compute: The RDS Instance
################################################################################

resource "aws_db_instance" "this" {
  identifier = var.identifier

  # Engine
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class
  db_name        = var.db_name # The name of the initial database to create

  # Storage
  storage_type          = var.storage_type
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage # Enables Autoscaling
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  # Network & Security
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  parameter_group_name   = aws_db_parameter_group.this.name
  publicly_accessible    = false # Best practice: Always false for DBs

  # Auth (Secrets Manager handled natively by RDS)
  username                    = var.username
  manage_master_user_password = var.manage_master_user_password

  # High Availability & Backup
  multi_az                  = var.multi_az
  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  copy_tags_to_snapshot     = true
  
  # Protection
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = "${var.identifier}-final-snap"

  # Observability
  performance_insights_enabled = var.performance_insights_enabled
  # Valid values for retention are 7 (free tier) or 731 (2 years, paid)
  performance_insights_retention_period = var.performance_insights_enabled ? 7 : null 
  
  # Logs to export to CloudWatch
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = var.tags
}