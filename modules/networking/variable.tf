variable "resource_group_name" {
  description = "The name of the Resource Group to deploy networking resources into."
  type        = string
}

variable "location" {
  description = "The Azure region."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to all resources."
  type        = map(string)
}

variable "vnet_name" {
  description = "The name for the Virtual Network."
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the VNet (e.g., [\"10.0.0.0/16\"])."
  type        = list(string)
}

variable "subnets" {
  description = "A map of subnets to create. e.g., { subnet_name = { address_prefixes = [] } }"
  type        = map(object({ address_prefixes = list(string) }))
}

variable "private_endpoints_subnet_name" {
  description = "The name of the subnet for private endpoints (must be a key in the 'subnets' map)."
  type        = string
}


