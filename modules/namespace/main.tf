locals {
    namespace_name = var.namespace_name_override != "" ? var.namespace_name_override : "${var.app_name}-${var.environment}"
  }

  resource "kubernetes_namespace" "this" {
    metadata {
      name = local.namespace_name
      labels = {
        environment = var.environment
        managed-by  = "terraform"
        app         = var.app_name
	team        = "platform"
      }
    }
  }

  resource "kubernetes_resource_quota" "this" {
    metadata {
      name      = "${local.namespace_name}-quota"
      namespace = kubernetes_namespace.this.metadata[0].name
    }
    spec {
      hard = {
        "requests.cpu"    = var.cpu_limit
        "requests.memory" = var.memory_limit
        "pods"            = var.pod_limit
      }
    }
  }

  resource "kubernetes_limit_range" "this" {
    metadata {
      name      = "${local.namespace_name}-limits"
      namespace = kubernetes_namespace.this.metadata[0].name
    }
    spec {
      limit {
        type = "Container"
        default = {
          cpu    = var.container_default_cpu
          memory = var.container_default_memory
        }
        max = {
          cpu    = var.container_max_cpu
          memory = var.container_max_memory
        }
      }
    }
  }

  # HIPAA baseline: deny all ingress by default
  resource "kubernetes_network_policy" "deny_all_ingress" {
    metadata {
      name      = "${local.namespace_name}-deny-all-ingress"
      namespace = kubernetes_namespace.this.metadata[0].name
    }
    spec {
      pod_selector {}
      policy_types = ["Ingress"]
    }
  }

  # Allow intra-namespace traffic (portal → mysql)
  resource "kubernetes_network_policy" "allow_intra_namespace" {
    metadata {
      name      = "${local.namespace_name}-allow-intra-ns"
      namespace = kubernetes_namespace.this.metadata[0].name
    }
    spec {
      pod_selector {}
      ingress {
        from {
          pod_selector {}
        }
      }
      policy_types = ["Ingress"]
    }
  }

  # ServiceAccount for app workloads (least privilege)
  resource "kubernetes_service_account" "app" {
    metadata {
      name      = "${var.app_name}-app"
      namespace = kubernetes_namespace.this.metadata[0].name
      labels = {
        app        = var.app_name
        managed-by = "terraform"
      }
    }
  }

  # Role: minimal permissions only
  resource "kubernetes_role" "app" {
    metadata {
      name      = "${var.app_name}-role"
      namespace = kubernetes_namespace.this.metadata[0].name
    }
    rule {
      api_groups = [""]
      resources  = ["pods", "configmaps"]
      verbs      = ["get", "list", "watch"]
    }
    rule {
      api_groups = [""]
      resources  = ["secrets"]
      verbs      = ["get"]
    }
  }

  resource "kubernetes_role_binding" "app" {
    metadata {
      name      = "${var.app_name}-rolebinding"
      namespace = kubernetes_namespace.this.metadata[0].name
    }
    role_ref {
      api_group = "rbac.authorization.k8s.io"
      kind      = "Role"
      name      = kubernetes_role.app.metadata[0].name
    }
    subject {
      kind      = "ServiceAccount"
      name      = kubernetes_service_account.app.metadata[0].name
      namespace = kubernetes_namespace.this.metadata[0].name
    }
  }
