variable "project" {
  type    = string
  default = "taller4"
}

variable "environment" {
  type        = string
  description = "dev o prod"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment debe ser 'dev' o 'prod'."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group pre-creado por bootstrap.sh"
}

variable "sku_name" {
  type    = string
  default = "B1"
}

variable "image_name" {
  type    = string
  default = "taller4-app"
}

variable "app_message" {
  type        = string
  description = "Variable (no secreta) distinta por ambiente."
  default     = ""
}

variable "app_secret" {
  type        = string
  description = "Secreto distinto por ambiente. Llega por TF_VAR_app_secret."
  default     = ""
  sensitive   = true
}
