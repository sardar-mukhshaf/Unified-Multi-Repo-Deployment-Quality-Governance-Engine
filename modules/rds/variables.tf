variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment identifier"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the Aurora cluster"
  type        = string
}

variable "isolated_subnet_ids" {
  description = "Isolated subnet IDs (no internet access) for Aurora"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to Aurora"
  type        = list(string)
}

variable "instance_class" {
  description = "Instance class for Aurora writer and readers"
  type        = string
  default     = "db.r6g.xlarge"
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.4"
}

variable "database_name" {
  description = "Default database name"
  type        = string
}

variable "master_username" {
  description = "Master database username"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption at rest"
  type        = string
}
