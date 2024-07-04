terraform {
  required_version = "~> 1.9"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.5.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "~> 2.3.2"
    }
  }

  backend "s3" {}
}

provider "kind" {}

provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = "kind-${kind_cluster.this.name}"
}

provider "minio" {
  minio_server   = var.minio_server
  minio_user     = local.minio_credentials.access_key
  minio_password = local.minio_credentials.secret_key
}
