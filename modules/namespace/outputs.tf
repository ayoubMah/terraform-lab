output "namespace_name" {
    description = "Name of the created namespace"
    value       = kubernetes_namespace.this.metadata[0].name
  }

  output "namespace_uid" {
    description = "UID of the created namespace"
    value       = kubernetes_namespace.this.metadata[0].uid
  }

  output "service_account_name" {
    description = "ServiceAccount name for app workloads"
    value       = kubernetes_service_account.app.metadata[0].name
  }
