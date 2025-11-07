terraform {
  backend "azurerm" {
    resource_group_name  = "VolticTf-RG"
    storage_account_name = "volticatfstorage77123"
    container_name       = "tfstate"
    key                  = "tst.terraform.tfstate" 
  }

}
