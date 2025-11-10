terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
    # --- ADD THIS BLOCK ---
    sendgrid = {
      source  = "sendgrid/sendgrid"
      version = "~> 0.2.1"
    }
  }
}

provider "azurerm" {
  features {}
}

# --- ADD THIS BLOCK ---
provider "sendgrid" {
  api_key = var.sendgrid_api_key
}
