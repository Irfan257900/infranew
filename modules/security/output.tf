output "key_vault_uri" { value = azurerm_key_vault.kv.vault_uri }
output "vm_admin_password_secret_id" {
  value     = azurerm_key_vault_secret.vm_password.id
  sensitive = true
}
