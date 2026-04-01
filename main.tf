terraform {
    required_version = ">= 1.0"
    required_providers {
      kubernetes = {
        source  = "hashicorp/kubernetes"
        version = "~> 2.0"
      }
    }
  }

  provider "kubernetes" {
    config_path = "~/.kube/config"
  }

  module "dev" {
    source       = "./modules/namespace"
    environment  = "dev"
    app_name     = "medicare"
    cpu_limit    = "2"
    memory_limit = "4Gi"
    pod_limit    = "10"
  }

  module "staging" {
    source       = "./modules/namespace"
    environment  = "staging"
    app_name     = "medicare"
    cpu_limit    = "4"
    memory_limit = "8Gi"
    pod_limit    = "20"
  }

  module "production" {
    source                  = "./modules/namespace"
    environment             = "prod"
    app_name                = "medicare"
    namespace_name_override = "medicare-prod"
    cpu_limit               = "8"
    memory_limit            = "16Gi"
    pod_limit               = "50"
    container_max_cpu       = "2"
    container_max_memory    = "2Gi"
  }
