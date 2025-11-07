terraform {
  backend "azurerm" {
    resource_group_name  = "Voltica-stg-tf-rg"
    storage_account_name = "volticatfstg771"
    container_name       = "tfstatestg"
    key                  = "stg.terraform.tfstate"  
  }
}
