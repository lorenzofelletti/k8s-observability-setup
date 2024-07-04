variable "observability" {
  description = "Configuration for the observability module (based on kube-prometheus-stack)"
  type = object({
    namespace               = optional(string, "monitoring")
    kube_prometheus_name    = optional(string, "kube-prometheus-stack")
    kube_prometheus_version = string
    values                  = optional(list(string), [])
  })
  nullable = false

  validation {
    condition     = can(regex("\\d\\.\\d{1,3}.\\d{1,3}", var.observability.kube_prometheus_version))
    error_message = "cluster_spec.k8s_version don't match regex `\\d\\.\\d{1,3}.\\d{1,3}`"
  }

  validation {
    condition = alltrue([
      for value in var.observability.values : can(yamldecode(value))
    ])
    error_message = "All values must be valid YAML"
  }
}

variable "local_kubeconfig_path" {
  description = "Local path to the kubeconfig file"
  type = object({
    path         = string
    context_name = optional(string)
  })
}

variable "remote_kubeconfig_path" {
  description = <<-EOT
  Not supported yet, use local_kubeconfig_path instead.
  Remote path to the kubeconfig file. Must be a MinIO path.
  Fields:
  - bucket_name: The name of the bucket
  - object_name: The name of the object
  - context_name: The name of the context to use in the kubeconfig file (optional)
  - store_locally: The local path to store the kubeconfig file (default: /tmp/kubeconfig)
  EOT
  type = object({
    bucket_name   = string
    object_name   = string
    context_name  = optional(string)
    store_locally = optional(string, "/tmp/kubeconfig")
  })
  default = null

  validation {
    condition = (
      var.remote_kubeconfig_path != null || var.local_kubeconfig_path != null
      ) && !(
      var.remote_kubeconfig_path != null && var.local_kubeconfig_path != null
    )
    error_message = "Either local_kubeconfig_path or remote_kubeconfig_path must be set, but not both"
  }

  validation {
    condition     = var.remote_kubeconfig_path == null
    error_message = "remote_kubeconfig_path is not implemented yet, because MinIO provider does not support required operations yet"
  }
}

# variable "minio_key_file" {
#   description = "Path to the file containing the MinIO access key and secret key"
#   type        = string
# }

# variable "minio_server" {
#   description = "The MinIO server to use for the S3 backend (e.g. localhost:9000)"
#   type        = string
# }
