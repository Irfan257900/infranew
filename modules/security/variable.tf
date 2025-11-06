variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "key_vault_name" { type = string }
variable "key_vault_admin_object_ids" { type = list(string) }
variable "vm_admin_password" {
  type      = string
  sensitive = true
}