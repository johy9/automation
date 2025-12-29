module "postgres" {
  source = "../../modules/postgreS"

  # Example variables - update as needed
  project_name = var.project_name
  environment  = var.environment
  db_name      = var.db_name
  db_username  = var.db_username
  db_password  = var.db_password
  vpc_id       = var.vpc_id
  subnet_ids   = var.subnet_ids
  # ...add other required variables
}
