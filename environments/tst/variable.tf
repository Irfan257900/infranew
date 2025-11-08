variable "app_rg_name" { type = string }
variable "vm_rg_name" { type = string }
variable "location" { type = string }
variable "storage_account_name" { type = string }
variable "app_insights_name" { type = string }
variable "app_service_plan_name" { type = string }
variable "service_bus_namespace_name" { type = string }
variable "key_vault_name" { type = string }
variable "function_app_names" { type = list(string) }
variable "dotnet_version" { type = string }
variable "vnet_name" { type = string }
variable "nsg_name" { type = string }
variable "vm_name" { type = string }
variable "vm_admin_username" { type = string }
variable "vm_admin_password" {
  description = "Administrator password for the VM. To be provided via CI/CD."
  type        = string
  sensitive   = true
}
variable "log_analytics_workspace_name" {
  description = "Custom name for the shared Log Analytics Workspace."
  type        = string
}
variable "web_app_names" {
  description = "A list of names for the web apps to be created."
  type        = list(string)
  default     = []

}
variable "sendgrid_api_key" {
  description = "Master SendGrid API Key"
  type        = string
  sensitive   = true
}

variable "sendgrid_template_id" {
  description = "The ID of the SendGrid email template (e.g., d-123...)"
  type        = string
  sensitive   = true
}
