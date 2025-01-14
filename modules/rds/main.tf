module "db" {
  source = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = var.name

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine                = var.engine
  engine_version        = var.engine_version
  family                = var.family               # DB parameter group
  major_engine_version  = var.major_engine_version # DB option group
  instance_class        = var.instance_class
  apply_immediately     = var.apply_immediately

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage

  name     = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.port

  multi_az               = var.multi_az
  subnet_ids             = var.subnet_ids
  vpc_security_group_ids = [module.security_group.this_security_group_id]

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  maintenance_window              = var.maintenance_window
  backup_window                   = var.backup_window
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection

  create_monitoring_role  = var.create_monitoring_role
  monitoring_interval     = var.monitoring_interval
  monitoring_role_name    = var.monitoring_role_name

  parameters = var.parameters

  options = var.options
  tags    = var.tags
  db_instance_tags = var.db_instance_tags
  db_option_group_tags = var.db_option_group_tags
  db_parameter_group_tags = var.db_parameter_group_tags
  db_subnet_group_tags = var.db_subnet_group_tags
}
