# ------------------------------------------------------------------------------
# EFS File System
# ------------------------------------------------------------------------------
resource "aws_efs_file_system" "this" {
  count          = var.enable_efs_driver ? 1 : 0
  creation_token = "${var.project_name}-${var.environment}-efs"
  encrypted      = true

  tags = merge(
    var.additional_tags,
    {
      Name = "${var.project_name}-${var.environment}-efs"
    }
  )
}

# ------------------------------------------------------------------------------
# EFS Mount Targets
# ------------------------------------------------------------------------------
resource "aws_efs_mount_target" "this" {
  count           = var.enable_efs_driver ? length(var.subnet_ids) : 0
  file_system_id  = aws_efs_file_system.this[0].id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs[0].id]
}

# ------------------------------------------------------------------------------
# EFS Security Group
# ------------------------------------------------------------------------------
resource "aws_security_group" "efs" {
  count       = var.enable_efs_driver ? 1 : 0
  name        = "${var.project_name}-${var.environment}-efs-sg"
  description = "Allow NFS traffic from EKS VPC"
  vpc_id      = aws_eks_cluster.this.vpc_config[0].vpc_id

  ingress {
    description = "NFS from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected[0].cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.additional_tags,
    {
      Name = "${var.project_name}-${var.environment}-efs-sg"
    }
  )
}

# We need to get the VPC CIDR for the security group rule
data "aws_vpc" "selected" {
  count = var.enable_efs_driver ? 1 : 0
  id    = aws_eks_cluster.this.vpc_config[0].vpc_id
}
