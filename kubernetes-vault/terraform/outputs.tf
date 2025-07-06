output "kubernetes_cluster_id" {
  description = "ID of the created Kubernetes cluster"
  value       = yandex_kubernetes_cluster.k8s_cluster.id
}

output "kubernetes_cluster_external_v4_endpoint" {
  description = "External endpoint of the Kubernetes cluster"
  value       = yandex_kubernetes_cluster.k8s_cluster.master[0].external_v4_endpoint
}
