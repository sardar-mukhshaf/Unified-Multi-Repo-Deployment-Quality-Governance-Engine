# ------------------------------------------------------------------------------
# RDS Aurora PostgreSQL Module — High Availability, Multi-AZ, Encrypted
# ------------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ------------------------------------------------------------------------------
# Random Master Password
# ------------------------------------------------------------------------------
resource "random_password" "master" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ------------------------------------------------------------------------------
# DB Subnet Group (Isolated Subnets Only)
# ------------------------------------------------------------------------------
resource "aws_db_subnet_group" "main" {
  name        = "${local.name_prefix}-aurora-subnet-group"
  description = "Subnet group for Aurora PostgreSQL in isolated subnets"
  subnet_ids  = var.isolated_subnet_ids

  tags = {
    Name        = "${local.name_prefix}-aurora-subnet-group"
    Environment = var.environment
  }
}

# ------------------------------------------------------------------------------
# DB Parameter Group
# ------------------------------------------------------------------------------
resource "aws_rds_cluster_parameter_group" "main" {
  name        = "${local.name_prefix}-aurora-params"
  family      = "aurora-postgresql15"
  description = "Custom parameters for Aurora PostgreSQL"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_duration"
    value = "1"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements,pg_cron"
  }

  parameter {
    name  = "pg_stat_statements.track"
    value = "all"
  }

  tags = {
    Name        = "${local.name_prefix}-aurora-params"
    Environment = var.environment
  }
}

# ------------------------------------------------------------------------------
# DB Cluster Parameter Group
# ------------------------------------------------------------------------------
resource "aws_db_parameter_group" "instance" {
  name        = "${local.name_prefix}-aurora-instance-params"
  family      = "aurora-postgresql15"
  description = "Instance-level parameters for Aurora PostgreSQL"

  parameter {
    name  = "max_connections"
    value = "500"
  }

  tags = {
    Name        = "${local.name_prefix}-aurora-instance-params"
    Environment = var.environment
  }
}

# ------------------------------------------------------------------------------
# Security Group for Aurora
# ------------------------------------------------------------------------------
resource "aws_security_group" "aurora" {
  name        = "${local.name_prefix}-aurora-sg"
  description = "Security group for Aurora PostgreSQL cluster"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from VPC CIDR"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.name_prefix}-aurora-sg"
    Environment = var.environment
  }
}

# ------------------------------------------------------------------------------
# Aurora PostgreSQL Cluster
# ------------------------------------------------------------------------------
resource "aws_rds_cluster" "main" {
  cluster_identifier              = "${local.name_prefix}-aurora-cluster"
  engine                          = "aurora-postgresql"
  engine_version                  = var.engine_version
  engine_mode                     = "provisioned"
  database_name                   = var.database_name
  master_username                 = var.master_username
  master_password                 = random_password.master.result
  db_subnet_group_name            = aws_db_subnet_group.main.name
  vpc_security_group_ids          = [aws_security_group.aurora.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name
  backup_retention_period         = 35
  preferred_backup_window         = "03:00-04:00"
  preferred_maintenance_window    = "sun:04:00-sun:05:00"
  storage_encrypted               = true
  kms_key_id                      = var.kms_key_arn
  deletion_protection             = true
  skip_final_snapshot             = false
  final_snapshot_identifier       = "${local.name_prefix}-aurora-final-snapshot"
  copy_tags_to_snapshot           = true
  enabled_cloudwatch_logs_exports = ["postgresql"]

  # Enable IAM database authentication for service-to-service auth
  iam_database_authentication_enabled = true

  tags = {
    Name        = "${local.name_prefix}-aurora-cluster"
    Environment = var.environment
  }
}

# ------------------------------------------------------------------------------
# Aurora Writer Instance
# ------------------------------------------------------------------------------
resource "aws_rds_cluster_instance" "writer" {
  identifier           = "${local.name_prefix}-aurora-writer"
  cluster_identifier   = aws_rds_cluster.main.id
  instance_class       = var.instance_class
  engine               = aws_rds_cluster.main.engine
  engine_version       = aws_rds_cluster.main.engine_version
  db_parameter_group_name = aws_db_parameter_group.instance.name

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  performance_insights_enabled    = true
  performance_insights_kms_key_id = var.kms_key_arn
  performance_insights_retention_period = 7

  auto_minor_version_upgrade = true

  tags = {
    Name        = "${local.name_prefix}-aurora-writer"
    Environment = var.environment
    Role        = "writer"
  }
}

# ------------------------------------------------------------------------------
# Aurora Reader Instance (Auto-scaling enabled)
# ------------------------------------------------------------------------------
resource "aws_rds_cluster_instance" "reader" {
  identifier           = "${local.name_prefix}-aurora-reader"
  cluster_identifier   = aws_rds_cluster.main.id
  instance_class       = var.instance_class
  engine               = aws_rds_cluster.main.engine
  engine_version       = aws_rds_cluster.main.engine_version
  db_parameter_group_name = aws_db_parameter_group.instance.name

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  performance_insights_enabled    = true
  performance_insights_kms_key_id = var.kms_key_arn
  performance_insights_retention_period = 7

  auto_minor_version_upgrade = true

  tags = {
    Name        = "${local.name_prefix}-aurora-reader"
    Environment = var.environment
    Role        = "reader"
  }
}

# ------------------------------------------------------------------------------
# RDS Enhanced Monitoring IAM Role
# ------------------------------------------------------------------------------
resource "aws_iam_role" "rds_monitoring" {
  name = "${local.name_prefix}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${local.name_prefix}-rds-monitoring-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role       = aws_iam_role.rds_monitoring.name
}

# ------------------------------------------------------------------------------
# CloudWatch Alarms — Aurora Monitoring
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${local.name_prefix}-aurora-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alert when Aurora CPU exceeds 80% for 15 minutes"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.main.cluster_identifier
  }

  tags = {
    Name        = "${local.name_prefix}-aurora-cpu-high"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "storage_low" {
  alarm_name          = "${local.name_prefix}-aurora-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeLocalStorage"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5368709120 # 5 GB in bytes
  alarm_description   = "Alert when Aurora free storage drops below 5GB"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.main.cluster_identifier
  }

  tags = {
    Name        = "${local.name_prefix}-aurora-storage-low"
    Environment = var.environment
  }
}

resource "aws_sns_topic" "alarms" {
  name              = "${local.name_prefix}-rds-alarms"
  kms_master_key_id = var.kms_key_arn

  tags = {
    Name        = "${local.name_prefix}-rds-alarms"
    Environment = var.environment
  }
}
