# ------------------------------------------------------------------------------
# Terraform tfvars — Production Environment
# These are the concrete values for the production workspace.
# IMPORTANT: This file is gitignored in real deployments. Sensitive values
# (passwords, secrets) must be supplied via Terraform Cloud / AWS SSM / Vault.
# This file serves as a documented reference for non-sensitive overrides.
# ------------------------------------------------------------------------------

# AWS Region — UAE / Middle East (SAMA regulatory data residency)
aws_region = "me-central-1"

# Environment tag applied to all resources
environment = "prod"

# Global project name used for resource naming prefixes
project_name = "unified-saas"

# -------------------------
# Network Configuration
# -------------------------

# Primary VPC CIDR block
vpc_cidr = "10.0.0.0/16"

# Multi-AZ deployment across 3 availability zones
availability_zones = [
  "me-central-1a",
  "me-central-1b",
  "me-central-1c"
]

# Public subnets — ALB, NAT Gateway attachment only
public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]

# Private subnets — EKS node groups, application workloads
private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24",
  "10.0.13.0/24"
]

# Isolated subnets — RDS Aurora, no internet gateway route
isolated_subnet_cidrs = [
  "10.0.21.0/24",
  "10.0.22.0/24",
  "10.0.23.0/24"
]

# One NAT Gateway per AZ for HA (3 total)
enable_nat_gateway = true
single_nat_gateway = false

# VPC Flow Logs to S3 for SAMA CS-9.1 compliance
enable_vpc_flow_logs = true

# -------------------------
# EKS Configuration
# -------------------------

# Kubernetes control plane version (patch version managed by AWS)
eks_cluster_version = "1.29"

# Graviton2 (ARM64) for cost/performance + Intel fallback for compatibility
eks_node_instance_types = [
  "m6i.xlarge",
  "m6i.2xlarge"
]

# Steady-state: 3 nodes per AZ = 9 total across 3 AZs
eks_node_desired_size = 3

# Minimum: 2 per AZ = 6 total (protects against AZ drain during maintenance)
eks_node_min_size = 2

# Maximum: 10 per AZ = 30 total (headroom for traffic spikes)
eks_node_max_size = 10

# -------------------------
# Aurora PostgreSQL Configuration
# -------------------------

# Graviton2-optimized instance for Aurora
aurora_instance_class = "db.r6g.xlarge"

# PostgreSQL 15 LTS engine on Aurora
aurora_engine_version = "15.4"

# Default database created at cluster initialization
aurora_database_name = "unified_saas_db"

# Master username — password is managed by Secrets Manager (NOT stored here)
aurora_master_username = "saas_admin"

# -------------------------
# Domain Configuration
# -------------------------

# Primary application FQDN (must have a corresponding ACM certificate)
domain_name = "app.unified-saas.example.com"

# -------------------------
# Security & Compliance
# -------------------------

# AWS GuardDuty — threat intelligence and anomaly detection (SAMA CS-9.1)
enable_guardduty = true
