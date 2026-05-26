output "cluster_endpoint" {
  description = "Writer endpoint for the Aurora cluster"
  value       = aws_rds_cluster.main.endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint for the Aurora cluster"
  value       = aws_rds_cluster.main.reader_endpoint
}

output "cluster_port" {
  description = "Port number for the Aurora cluster"
  value       = aws_rds_cluster.main.port
}

output "master_password" {
  description = "Randomly generated master password"
  value       = random_password.master.result
  sensitive   = true
}

output "cluster_arn" {
  description = "ARN of the Aurora cluster"
  value       = aws_rds_cluster.main.arn
}

output "cluster_identifier" {
  description = "Cluster identifier"
  value       = aws_rds_cluster.main.cluster_identifier
}

output "security_group_id" {
  description = "Security group ID attached to Aurora"
  value       = aws_security_group.aurora.id
}
