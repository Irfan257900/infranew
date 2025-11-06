output "name" {
  description = "The name of the created function app."
  value       = azurerm_windows_function_app.function_app.name
}