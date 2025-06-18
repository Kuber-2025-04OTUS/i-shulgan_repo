output "kubernetes_cluster_id" {
  description = "ID of the created Kubernetes cluster"
  value       = yandex_kubernetes_cluster.k8s_cluster.id
}

output "kubernetes_cluster_external_v4_endpoint" {
  description = "External endpoint of the Kubernetes cluster"
  value       = yandex_kubernetes_cluster.k8s_cluster.master[0].external_v4_endpoint
}

output "s3_bucket_name" {
  description = "Name of the created S3 bucket for Loki logs"
  value       = yandex_storage_bucket.loki_logs.bucket
}

output "s3_access_key" {
  description = "Access key for S3 bucket"
  value       = yandex_iam_service_account_static_access_key.s3_access_sa.access_key
  sensitive   = true
}

output "s3_secret_key" {
  description = "Secret key for S3 bucket"
  value       = yandex_iam_service_account_static_access_key.s3_access_sa.secret_key
  sensitive   = true
}
