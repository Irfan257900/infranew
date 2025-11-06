output "subnet_ids" {
  description = "Map of subnet names to their IDs."
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "private_endpoint_subnet_id" {
  description = "The ID of the Private Endpoint subnet."
  value       = azurerm_subnet.subnets["PrivateEndpointsSubnet"].id
}

# --- ADD THIS MISSING OUTPUT BLOCK ---
output "private_dns_zone_ids" {
  description = "A map of Private DNS Zone IDs for linking private endpoints."
  value = {
    # NOTE: This assumes you have these private_dns_zone resources
    # in your modules/networking/main.tf file.
    app_service  = azurerm_private_dns_zone.app_service.id
    acr          = azurerm_private_dns_zone.acr.id
    storage_blob = azurerm_private_dns_zone.storage_blob.id
    servicebus   = azurerm_private_dns_zone.servicebus.id
  }
}