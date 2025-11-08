terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
    # --- ADD THIS NEW BLOCK ---
    sendgrid = {
      source  = "sendgrid/sendgrid"
      version = "~> 0.2.1" # Use the latest version
    }
  }
}

provider "azurerm" {
  features {}
}

# --- ADD THIS NEW PROVIDER CONFIG ---
provider "sendgrid" {
  api_key = var.sendgrid_api_key
}
