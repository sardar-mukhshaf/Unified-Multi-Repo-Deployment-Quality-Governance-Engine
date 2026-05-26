variable "aws_region" {
  description = "AWS region for production deployment"
  type        = string
  default     = "me-central-1"
}

variable "environment" {
  description = "Deployment environment identifier"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Global project name used for resource naming and tagging"
  type        = string
  default     = "unified-saas"
}

variable "vpc_cidr" {
  description = "CIDR block for the production VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones for multi-AZ deployment"
  type        = list(string)
  default     = ["me-central-1a", "me-central-1b", "me-central-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (ALB ingress only)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (EKS node groups)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "isolated_subnet_cidrs" {
  description = "CIDR blocks for isolated subnets (RDS Aurora, no internet)"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS control plane"
  type        = string
  default     = "1.29"
}

variable "eks_node_instance_types" {
  description = "EC2 instance types for EKS managed node groups"
  type        = list(string)
  default     = ["m6i.xlarge", "m6i.2xlarge"]
}

variable "eks_node_desired_size" {
  description = "Desired number of worker nodes per AZ"
  type        = number
  default     = 3
}

variable "eks_node_min_size" {
  description = "Minimum number of worker nodes per AZ"
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Maximum number of worker nodes per AZ"
  type        = number
  default     = 10
}

variable "aurora_instance_class" {
  description = "Instance class for Aurora PostgreSQL writer and readers"
  type        = string
  default     = "db.r6g.xlarge"
}

variable "aurora_engine_version" {
  description = "PostgreSQL engine version for Aurora"
  type        = string
  default     = "15.4"
}

variable "aurora_database_name" {
  description = "Default database name created in the Aurora cluster"
  type        = string
  default     = "unified_saas_db"
}

variable "aurora_master_username" {
  description = "Master username for Aurora PostgreSQL cluster"
  type        = string
  default     = "saas_admin"
}

variable "domain_name" {
  description = "Primary application domain for Route53 and ingress"
  type        = string
  default     = "app.unified-saas.example.com"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateways for private subnet outbound connectivity"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway (false for HA multi-AZ)"
  type        = bool
  default     = false
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs for network traffic auditing"
  type        = bool
  default     = true
}

variable "enable_guardduty" {
  description = "Enable AWS GuardDuty for threat detection"
  type        = bool
  default     = true
}
