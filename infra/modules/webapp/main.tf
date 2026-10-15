data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

locals {
  base     = "${var.project}-${var.environment}"
  acr_name = "acr${var.project}${var.environment}${random_string.suffix.result}"
}

resource "azurerm_container_registry" "this" {
  name                = local.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false # sin usuario/contraseña de admin
  tags                = var.tags
}

resource "azurerm_service_plan" "this" {
  name                = "asp-${local.base}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = var.tags
}

resource "azurerm_linux_web_app" "this" {
  name                = "app-${local.base}-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = true
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                               = true
    ftps_state                              = "Disabled"
    http2_enabled                           = true
    minimum_tls_version                     = "1.2"
    health_check_path                       = "/health"
    health_check_eviction_time_in_min       = 5
    container_registry_use_managed_identity = true

    application_stack {
      docker_registry_url = "https://${azurerm_container_registry.this.login_server}"
      docker_image_name   = "${var.image_name}:${var.initial_image_tag}"
    }
  }

  app_settings = merge(
    {
      WEBSITES_PORT = "3000"
    },
    var.app_settings
  )

  # La imagen (tag = commit) la actualiza el pipeline, no Terraform.
  lifecycle {
    ignore_changes = [site_config[0].application_stack]
  }
}

# El App Service descarga imágenes con su identidad administrada
resource "azurerm_role_assignment" "app_acr_pull" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.this.identity[0].principal_id
}

# La identidad del pipeline (la que ejecuta terraform) puede publicar imágenes
resource "azurerm_role_assignment" "pipeline_acr_push" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPush"
  principal_id         = data.azurerm_client_config.current.object_id
}
