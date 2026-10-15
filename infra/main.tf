data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

locals {
  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

module "webapp" {
  source = "./modules/webapp"

  project             = var.project
  environment         = var.environment
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  sku_name            = var.sku_name
  image_name          = var.image_name
  tags                = local.tags

  app_settings = {
    APP_ENV     = var.environment
    APP_MESSAGE = var.app_message
    APP_SECRET  = var.app_secret
  }
}
