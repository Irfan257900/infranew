variable "function_app_name" {
  description = "The specific name for the Function App."
  type        = string
}
variable "location" {
  description = "The Azure region for the function app."
  type        = string
}
variable "resource_group_name" {
  description = "The name of the resource group for the function app."
  type        = string
}
variable "app_service_plan_id" {
  description = "The ID of the shared App Service Plan to host the function app."
  type        = string
}

variable "app_insights_instrumentation_key" {
  description = "The instrumentation key from the shared Application Insights instance."
  type        = string
  sensitive   = true
}
variable "storage_account_name" {
  description = "The name of the shared storage account."
  type        = string
}
variable "storage_account_access_key" {
  description = "The primary access key for the shared storage account."
  type        = string
  sensitive   = true
}
variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
variable "dotnet_version" {
  description = "The version of the .NET stack for the function app (e.g., '8.0' for Linux)."
  type        = string
}