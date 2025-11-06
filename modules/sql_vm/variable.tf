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
variable "data_disks" {
  description = "A list of maps defining data disks to attach to the SQL Server VM."
  type = list(object({
    name                 = string
    disk_size_gb         = number
    lun                  = number
    caching              = string # "None", "ReadOnly", "ReadWrite"
    create_option        = string # "Empty", "Attach", "FromImage"
    storage_account_type = string
  }))
  default = [] # Make it optional; no disks by default if not specified
}