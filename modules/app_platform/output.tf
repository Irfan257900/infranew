output "acr_login_server" {
  description = "The login server for the Azure Container Registry."
  value       = azurerm_container_registry.acr.login_server
}

output "app_service_hostnames" {
  description = "A map of the app services and their default hostnames."
  value       = { for k, v in azurerm_linux_web_app.app_services : k => v.default_hostname }
}

output "function_app_hostnames" {
  description = "A map of the function apps and their default hostnames."
  value       = { for k, v in azurerm_linux_function_app.function_apps : k => v.default_hostname }
}