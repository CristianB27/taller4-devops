output "acr_name" {
  value = azurerm_container_registry.this.name
}

output "acr_login_server" {
  value = azurerm_container_registry.this.login_server
}

output "app_name" {
  value = azurerm_linux_web_app.this.name
}

output "app_url" {
  value = "https://${azurerm_linux_web_app.this.default_hostname}"
}
