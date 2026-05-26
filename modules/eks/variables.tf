variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment identifier"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "VPC ID where EKS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS node groups"
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for managed node groups"
  type        = list(string)
  default     = ["m6i.xlarge"]
}

variable "node_desired_size" {
  description = "Desired number of nodes per AZ"
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum number of nodes per AZ"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes per AZ"
  type        = number
  default     = 10
}

variable "kms_key_arn" {
  description = "KMS key ARN for envelope encryption of Kubernetes secrets"
  type        = string
}
