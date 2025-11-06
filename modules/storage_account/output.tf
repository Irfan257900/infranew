output "name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.storage.name
}
output "primary_access_key" {
  description = "The primary access key for the storage account."
  value       = azurerm_storage_account.storage.primary_access_key
  sensitive   = true
}