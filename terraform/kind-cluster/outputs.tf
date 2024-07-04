output "kubeconfig" {
  description = "Kubeconfig file for the cluster"
  value       = kind_cluster.this.kubeconfig
}

output "cluster_provider" {
  description = "Provider of the cluster"
  value       = "local"
}
