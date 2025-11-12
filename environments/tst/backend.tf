terraform {
  backend "azurerm" {
    resource_group_name  = "VolticTfdemo-RG"
    storage_account_name = "volticatfstorage771231"
    container_name       = "tfstate"
    key                  = "tst.terraform.tfstate" 
  }

}

