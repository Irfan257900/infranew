variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "vm_name" { type = string }
variable "vm_size" { type = string }
variable "admin_username" { type = string }
variable "admin_password" {
  description = "Admin password for the VM."
  type        = string
  sensitive   = true
}
variable "subnet_id" { type = string }
variable "public_ip_name" { type = string }
variable "nsg_name" { type = string }
