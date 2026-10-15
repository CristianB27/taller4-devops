output "resource_group_name" {
  value = data.azurerm_resource_group.this.name
}

output "acr_name" {
  value = module.webapp.acr_name
}

output "acr_login_server" {
  value = module.webapp.acr_login_server
}

output "app_name" {
  value = module.webapp.app_name
}

output "app_url" {
  value = module.webapp.app_url
}
