terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.142"
    }
    #    kubernetes = {
    #      source  = "hashicorp/kubernetes"
    #      version = ">= 2.37"
    #    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.17"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

provider "helm" {
  kubernetes {
    config_path = "${path.module}/kubeconfig.yaml"
  }
}
