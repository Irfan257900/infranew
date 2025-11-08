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
  # All manual login lines (client_id, tenant_id, etc.)
  # have been removed.
}
