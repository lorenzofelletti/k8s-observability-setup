locals {
  non_default_cluster_config_detected = (
    var.cluster_spec.containerd_config_patches != [] ||
    length(keys(var.cluster_spec.nodes)) > 0 ||
    var.cluster_spec.networking != null
  )

  minio_key_file = sensitive(
    jsondecode(file(pathexpand(var.minio_key_file)))
  )
  minio_credentials = {
    access_key = sensitive(local.minio_key_file.accessKey)
    secret_key = sensitive(local.minio_key_file.secretKey)
  }


  kubeconfig_path = pathexpand(var.kubeconfig_path)
  kubeconfig      = kind_cluster.this.kubeconfig
  context_name    = "kind-${kind_cluster.this.name}"
}
