variable "project" {
  type        = string
  description = "Nombre corto del proyecto (usado en nombres de recursos)."
}

variable "environment" {
  type        = string
  description = "Ambiente: dev o prod."
}

variable "location" {
  type        = string
  description = "Región de Azure."
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group donde se crean los recursos."
}

variable "sku_name" {
  type        = string
  description = "SKU del App Service Plan (B1 es el mínimo con contenedores)."
  default     = "B1"
}

variable "image_name" {
  type        = string
  description = "Nombre de la imagen Docker (sin tag)."
  default     = "taller4-app"
}

variable "initial_image_tag" {
  type        = string
  description = "Tag inicial; el pipeline lo reemplaza con el SHA del commit."
  default     = "bootstrap"
}

variable "app_settings" {
  type        = map(string)
  description = "Variables de entorno de la aplicación."
  default     = {}
  sensitive   = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
