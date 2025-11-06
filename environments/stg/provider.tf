terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
  }
}

provider "azurerm" {
  features {}
  # BEST PRACTICE: Use variables for credentials, not hardcoded values.
  # These will be set by environment variables in your pipeline (e.g., ARM_CLIENT_ID).
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  
  skip_provider_registration = true
}