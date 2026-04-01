variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "medicare"
}

variable "namespace_cpu_limit" {
  description = "Total CPU limit for the namespace (ResourceQuota)"
  type        = string
  default     = "2"
}

variable "namespace_memory_limit" {
  description = "Total memory limit for the namespace (ResourceQuota)"
  type        = string
  default     = "4Gi"
}

variable "namespace_pod_limit" {
  description = "Maximum number of pods in the namespace"
  type        = string
  default     = "10"
}

variable "container_default_cpu" {
  description = "Default CPU limit per container (LimitRange)"
  type        = string
  default     = "500m"
}

variable "container_default_memory" {
  description = "Default memory limit per container (LimitRange)"
  type        = string
  default     = "256Mi"
}

variable "container_max_cpu" {
  description = "Max CPU a single container can request"
  type        = string
  default     = "1"
}

variable "container_max_memory" {
  description = "Max memory a single container can request"
  type        = string
  default     = "1Gi"
}
