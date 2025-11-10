terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
   # sendgrid = {
      # --- THIS IS THE FIX ---
      # This is the correct, short path
     # source  = "sendgrid/sendgrid"
     # version = "~> 0.2.1"
   # }
  }
}

provider "azurerm" {
  features {}
}

#provider "sendgrid" {
 # api_key = var.sendgrid_api_key
#}

