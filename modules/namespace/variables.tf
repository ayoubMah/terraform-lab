variable "environment" {
    description = "Deployment environment"
    type        = string
  }

  variable "app_name" {
    description = "Application name"
    type        = string
  }

  variable "namespace_name_override" {
    description = "Override namespace name. If empty, uses {app_name}-{environment}"
    type        = string
    default     = ""
  }

  variable "cpu_limit" {
    description = "Total CPU limit for the namespace (ResourceQuota)"
    type        = string
    default     = "2"
  }

  variable "memory_limit" {
    description = "Total memory limit for the namespace (ResourceQuota)"
    type        = string
    default     = "4Gi"
  }

  variable "pod_limit" {
    description = "Maximum number of pods"
    type        = string
    default     = "10"
  }

  variable "container_default_cpu" {
    type    = string
    default = "500m"
  }

  variable "container_default_memory" {
    type    = string
    default = "256Mi"
  }

  variable "container_max_cpu" {
    type    = string
    default = "1"
  }

  variable "container_max_memory" {
    type    = string
    default = "1Gi"
  }
