variable "storage_account_name" {
  description = "The specific name of the storage account."
  type        = string
}
variable "location" {
  description = "The Azure region for the storage account."
  type        = string
}
variable "resource_group_name" {
  description = "The name of the resource group for the storage account."
  type        = string
}
variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}