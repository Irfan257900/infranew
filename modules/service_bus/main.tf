resource "azurerm_servicebus_namespace" "sb_namespace" {
  name                = var.service_bus_namespace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  tags                = var.tags
}