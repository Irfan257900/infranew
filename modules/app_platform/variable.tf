# File: modules/app_platform/variables.tf

variable "resource_group_name" {
  description = "Name of the resource group for these resources."
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
}

variable "app_service_plan_name" {
  description = "Name for the App Service Plan."
  type        = string
}

variable "app_service_plan_sku" {
  description = "SKU for the App Service Plan."
  type        = string
}

variable "acr_name" {
  description = "Globally unique name for the Azure Container Registry."
  type        = string
}

variable "acr_sku" {
  description = "SKU for the Azure Container Registry."
  type        = string
}

variable "storage_account_name" {
  description = "Name for the Azure Storage Account."
  type        = string
}


variable "servicebus_namespace_name" {
  description = "Name for the Azure Service Bus Namespace."
  type        = string
}

variable "app_insights_name" {
  description = "Name for the Application Insights instance."
  type        = string
}
variable "function_app_names" {
  description = "A list of names for the code-based Function Apps."
  type        = list(string)
}

# --- Container Configuration Variables ---
variable "app_service_docker_images" {
  description = "A map of App Service names to their Docker image repository names."
  type        = map(string)
}


variable "docker_image_tag" {
  description = "The tag for the Docker images (e.g., 'latest')."
  type        = string
}

# --- Networking Variables ---
variable "private_endpoint_subnet_id" {
  description = "The ID of the subnet where private endpoints will be deployed."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "A map of Private DNS Zone IDs for linking private endpoints."
  type = object({
    app_service  = string
    acr          = string
    storage_blob = string
    servicebus   = string
  })
}
