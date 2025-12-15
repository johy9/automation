# ------------------------------------------------------------------------------
# EFS Storage Class
# ------------------------------------------------------------------------------
resource "kubernetes_storage_class_v1" "efs" {
  metadata {
    name = "efs-sc"
  }

  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = "Delete"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = data.terraform_remote_state.eks.outputs.efs_file_system_id
    directoryPerms   = "700"
  }

  # Note: Dynamic provisioning for EFS usually requires a File System to exist first.
  # The CSI driver doesn't create the EFS File System itself, it creates Access Points.
  # If you want Terraform to create the EFS File System, we should add it here or in the EKS module.
}
