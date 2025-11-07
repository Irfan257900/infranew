terraform {
  backend "azurerm" {
    resource_group_name  = "Voltica-prod-tf-rg"
    storage_account_name = "volticatfprod882"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"  
  }
}
