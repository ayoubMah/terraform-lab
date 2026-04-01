output "dev_namespace" {
    value = module.dev.namespace_name
  }

  output "staging_namespace" {
    value = module.staging.namespace_name
  }

  output "production_namespace" {
    value = module.production.namespace_name
  }

  output "production_service_account" {
    value = module.production.service_account_name
  }
