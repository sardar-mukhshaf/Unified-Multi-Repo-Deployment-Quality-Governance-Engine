# ------------------------------------------------------------------------------
# Production Environment Root Module
# Unified SaaS Infrastructure — Banking-Grade, SAMA/NCA Compliant
# ------------------------------------------------------------------------------

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Compliance  = "SAMA-NCA"
  }
}

# ------------------------------------------------------------------------------
# KMS Key for Encryption at Rest
# ------------------------------------------------------------------------------
resource "aws_kms_key" "main" {
  description             = "KMS key for ${var.project_name} ${var.environment} encryption at rest"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  multi_region            = false

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow EKS Service"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow RDS Service"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-${var.environment}-key"
  target_key_id = aws_kms_key.main.key_id
}

# ------------------------------------------------------------------------------
# VPC Module
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  isolated_subnet_cidrs = var.isolated_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_flow_logs     = var.enable_vpc_flow_logs
  kms_key_id           = aws_kms_key.main.arn
}

# ------------------------------------------------------------------------------
# EKS Module
# ------------------------------------------------------------------------------
module "eks" {
  source = "../../modules/eks"

  project_name          = var.project_name
  environment           = var.environment
  cluster_version       = var.eks_cluster_version
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  node_instance_types   = var.eks_node_instance_types
  node_desired_size     = var.eks_node_desired_size
  node_min_size         = var.eks_node_min_size
  node_max_size         = var.eks_node_max_size
  kms_key_arn           = aws_kms_key.main.arn
}

# ------------------------------------------------------------------------------
# RDS Aurora Module
# ------------------------------------------------------------------------------
module "rds" {
  source = "../../modules/rds"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  isolated_subnet_ids = module.vpc.isolated_subnet_ids
  allowed_cidr_blocks = [var.vpc_cidr]
  instance_class      = var.aurora_instance_class
  engine_version      = var.aurora_engine_version
  database_name       = var.aurora_database_name
  master_username     = var.aurora_master_username
  kms_key_arn         = aws_kms_key.main.arn
}

# ------------------------------------------------------------------------------
# GuardDuty (Threat Detection)
# ------------------------------------------------------------------------------
resource "aws_guardduty_detector" "main" {
  count = var.enable_guardduty ? 1 : 0

  enable = true

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        enable = true
      }
    }
  }

  tags = local.common_tags
}

# ------------------------------------------------------------------------------
# Secrets Manager — Database Credentials
# ------------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}/${var.environment}/aurora/postgres-credentials"
  description             = "Aurora PostgreSQL master credentials for ${var.environment}"
  kms_key_id              = aws_kms_key.main.arn
  recovery_window_in_days = 7

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.aurora_master_username
    password = module.rds.master_password
    host     = module.rds.cluster_endpoint
    port     = module.rds.cluster_port
    dbname   = var.aurora_database_name
    jdbc_url = "postgresql://${var.aurora_master_username}:${module.rds.master_password}@${module.rds.cluster_endpoint}:${module.rds.cluster_port}/${var.aurora_database_name}"
  })
}

# ------------------------------------------------------------------------------
# ECR Repositories
# ------------------------------------------------------------------------------
resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}-frontend"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.main.arn
  }

  tags = local.common_tags
}

resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}-backend"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.main.arn
  }

  tags = local.common_tags
}

resource "aws_ecr_lifecycle_policy" "frontend" {
  repository = aws_ecr_repository.frontend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Retain last 30 immutable images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "backend" {
  repository = aws_ecr_repository.backend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Retain last 30 immutable images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
