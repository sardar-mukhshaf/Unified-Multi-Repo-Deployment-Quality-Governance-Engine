output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate data"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for IRSA"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS control plane"
  value       = aws_security_group.cluster.id
}

output "node_group_role_arn" {
  description = "ARN of the EKS node group IAM role"
  value       = aws_iam_role.node_group.arn
}

output "alb_controller_role_arn" {
  description = "ARN of the IRSA role for AWS Load Balancer Controller"
  value       = aws_iam_role.alb_controller.arn
}

output "external_dns_role_arn" {
  description = "ARN of the IRSA role for External DNS"
  value       = aws_iam_role.external_dns.arn
}

output "cluster_autoscaler_role_arn" {
  description = "ARN of the IRSA role for Cluster Autoscaler"
  value       = aws_iam_role.cluster_autoscaler.arn
}
