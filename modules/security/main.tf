data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                       = var.key_vault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  enable_rbac_authorization  = true
  tags                       = var.tags
}

resource "azurerm_role_assignment" "kv_admin" {
  for_each             = toset(var.key_vault_admin_object_ids)
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.value
}

resource "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-admin-password"
  value        = var.vm_admin_password
  key_vault_id = azurerm_key_vault.kv.id

  # This explicit dependency tells Terraform to wait until the role assignment
  # is successfully created before attempting to write the secret.
  depends_on = [
    azurerm_role_assignment.kv_admin
  ]
}


