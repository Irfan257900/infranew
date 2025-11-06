variable "client_id" {
  description = "Azure AD App Client ID"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Azure AD App Client Secret"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

# --- ADD THIS MISSING VARIABLE ---
variable "admin_password" {
  description = "Admin password for the Windows VM. Must meet Azure complexity requirements."
  type        = string
  sensitive   = true
}

## -- ADDED: The missing docker_image_tag variable -- ##
variable "docker_image_tag" {
  description = "The specific, unique tag for the Docker images to be deployed (e.g., a git commit SHA or 'latest')."
  type        = string
  default     = "latest" # Providing a default for easy local testing
}