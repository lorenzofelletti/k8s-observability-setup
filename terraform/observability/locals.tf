locals {
  kubeconfig_path = (
    var.local_kubeconfig_path != null ?
    pathexpand(var.local_kubeconfig_path.path) :
    # This is a temporary workaround until MinIO provider supports the required operations
    null
  )

  config_context = (
    var.local_kubeconfig_path != null ?
    var.local_kubeconfig_path.context_name :
    var.remote_kubeconfig_path.context_name
  )
}
