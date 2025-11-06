variable "vm_name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "subnet_id" { type = string }
variable "admin_username" { type = string }
variable "admin_password" {
  description = "Administrator password for the VM. Provided via CI/CD."
  type        = string
  sensitive   = true
}
variable "tags" { type = map(string) }