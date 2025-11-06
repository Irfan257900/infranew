output "vm_public_ip_address" {
  description = "The public IP address of the SQL VM."
  value       = azurerm_public_ip.pip.ip_address
}