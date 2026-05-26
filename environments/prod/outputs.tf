output "vpc_id" {
  description = "ID of the provisioned VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs for EKS node groups"
  value       = module.vpc.private_subnet_ids
}

output "isolated_subnet_ids" {
  description = "List of isolated subnet IDs for RDS Aurora"
  value       = module.vpc.isolated_subnet_ids
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint URL for the EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64-encoded certificate data for cluster authentication"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "eks_oidc_issuer_url" {
  description = "OIDC issuer URL for IRSA configuration"
  value       = module.eks.oidc_issuer_url
}

output "aurora_cluster_endpoint" {
  description = "Writer endpoint for the Aurora PostgreSQL cluster"
  value       = module.rds.cluster_endpoint
}

output "aurora_reader_endpoint" {
  description = "Reader endpoint for the Aurora PostgreSQL cluster"
  value       = module.rds.reader_endpoint
}

output "aurora_cluster_port" {
  description = "Port number for the Aurora PostgreSQL cluster"
  value       = module.rds.cluster_port
}

output "ecr_frontend_repository_url" {
  description = "URL of the frontend ECR repository"
  value       = aws_ecr_repository.frontend.repository_url
}

output "ecr_backend_repository_url" {
  description = "URL of the backend ECR repository"
  value       = aws_ecr_repository.backend.repository_url
}

output "kms_key_arn" {
  description = "ARN of the primary KMS encryption key"
  value       = aws_kms_key.main.arn
}

output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret containing DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}
