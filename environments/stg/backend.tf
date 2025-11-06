terraform {
  backend "azurerm" {
    resource_group_name  = "STG-TF-RG"
    storage_account_name = "rapidztfstg"
    container_name       = "tfstatestg"
    key                  = "stg.terraform.tfstate" 
  }
}