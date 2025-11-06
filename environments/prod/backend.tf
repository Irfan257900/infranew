terraform {
  backend "azurerm" {
    resource_group_name  = "TF-ST-RG"
    storage_account_name = "arthaonestorageone"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate" 
  }
}