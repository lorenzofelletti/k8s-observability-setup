terraform {
  required_version = "~> 1.9"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    # minio = {
    #   source  = "aminueza/minio"
    #   version = "~> 2.3.2"
    # }
  }

  backend "s3" {}
}

provider "kubernetes" {
  config_path    = local.kubeconfig_path
  config_context = local.config_context
}

provider "helm" {
  kubernetes {
    config_path    = local.kubeconfig_path
    config_context = local.config_context
  }
}

# provider "minio" {
#   minio_server   = var.minio_server
#   minio_user     = local.minio_credentials.access_key
#   minio_password = local.minio_credentials.secret_key
# }
