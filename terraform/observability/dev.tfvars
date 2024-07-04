observability = {
  kube_prometheus_version = "61.2.0"
}
# remote_kubeconfig_path = {
#   bucket_name = "cluster-kubeconfig"
#   object_name = "kubeconfig"
# }
local_kubeconfig_path = {
  path = "~/.kube/kind-config"
}
