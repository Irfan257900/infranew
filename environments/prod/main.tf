
locals {
  env         = "prod"
  project     = "Paybase"
  common_tags = { "Business-owners" = "Project Manager", "Core-function" = "application", "Criticality" = "1", "Environment" = local.env, "Primary-application" = local.project, "Technical-owner" = "DevOps Team" }

  # This block defines the names for container-based App Services
  app_service_docker_images = {
    "Paybaseprd-admin"       = "Paybase/admin-app"
    "Paybasesprd-signalR" = "Paybase/signal-app"
    "Paybaseprd-coreapi" = "Paybase/coreapi-app"
    "Paybaseprd-cardsapi" = "Paybase/cardsapi-app"
    "Paybaseprd-banksapi" = "Paybase/banksapi-app"
    "Paybaseprd-paymentsapi" = "Paybase/paymentsapi-app"
    "Paybaseprd-paylinks" = "Paybase/paylinks-app"
    "Paybaseprd" = "Paybase/user-app"
  }
  

  function_app_names = [
    "PaybaseMarketdataprd",
    "Paybasesubscriberprd",
    "PaybaseSweepfunctionprd"
  ]
}

# ... (the rest of your main.tf file)

# Data source to get the current identity running Terraform
data "azurerm_client_config" "current" {}

# --- RESOURCE GROUPS ---
resource "azurerm_resource_group" "network_rg" {
  name     = "${local.project}-${local.env}-network-rg"
  location = "Switzerland North"
  tags     = local.common_tags
}
resource "azurerm_resource_group" "app_rg" {
  name     = "${local.project}-${local.env}-app-rg"
  location = "Switzerland North"
  tags     = local.common_tags
}
resource "azurerm_resource_group" "vm_rg" {
  name     = "${local.project}-${local.env}-vm-rg"
  location = "Switzerland North"
  tags     = local.common_tags
}
resource "azurerm_resource_group" "security_rg" {
  name     = "${local.project}-${local.env}-security-rg"
  location = "Switzerland North"
  tags     = local.common_tags
}

# --- MODULES ---

module "networking" {
  source = "../../modules/networking"
  resource_group_name = azurerm_resource_group.network_rg.name
  location            = azurerm_resource_group.network_rg.location
  tags                = local.common_tags
  vnet_name           = "${local.project}-${local.env}-vnet"
  vnet_address_space  = ["10.10.0.0/16"]
  subnets = {
    IntegrationvmSubnet       = { address_prefixes = ["10.10.10.0/24"] }
    PrivateEndpointsSubnet = { address_prefixes = ["10.10.11.0/24"] }
    sqlVmSubnet            = { address_prefixes = ["10.10.12.0/24"] }
  }
  private_endpoints_subnet_name = "PrivateEndpointsSubnet"
  
}

module "security" {
  source = "../../modules/security"

  resource_group_name = azurerm_resource_group.security_rg.name
  location            = azurerm_resource_group.security_rg.location
  tags                = local.common_tags
  key_vault_name      = "prd-Paybase-kv"
  vm_admin_password   = var.admin_password
  key_vault_admin_object_ids = [data.azurerm_client_config.current.object_id]
}


 module "sql_vm" {
  source = "../../modules/sql_vm"

   resource_group_name = azurerm_resource_group.vm_rg.name
   location            = azurerm_resource_group.vm_rg.location
   tags                = local.common_tags
   vm_name        = "Paybasesqlstg"
   vm_size        = "Standard_B2ms"
   admin_username = "hswerWjdbds23"
   admin_password = var.admin_password
   public_ip_name = "Paybase-stg-vm-pip"
   nsg_name       = "Paybasesqlstg-nic-nsg"
   subnet_id      = module.networking.subnet_ids["sqlVmSubnet"]
   data_disks = [
     {
       name          = "sql-data-disk-1"
       disk_size_gb  = 32
       lun           = 0
       caching       = "ReadWrite" # Typical for SQL data disks
       create_option = "Empty"
       storage_account_type = "Standard_LRS" # Or "Premium_LRS" for better performance
     },
     {
       name          = "sql-data-disk-2"
       disk_size_gb  = 32
       lun           = 1
       caching       = "ReadOnly" # Typical for SQL log disks, or ReadWrite if also data
       create_option = "Empty"
       storage_account_type = "Standard_LRS"
     }
   ]
   

 }

# module "integration_vm_stg" {
#   source = "../../modules/integration_vm_stg" 

#   resource_group_name = azurerm_resource_group.vm_rg.name
#   location            = azurerm_resource_group.vm_rg.location
#   tags                = local.common_tags
#   vm_name        = "PaybaseintegVm" # Unique name for the new VM
#   vm_size        = "Standard_B2s"    # Example: different size
#   admin_username = "RsgjhsdEintegdfdh"
#   admin_password = var.admin_password
#   public_ip_name = "Paybase-prd-integration-vm-pip"
#   nsg_name       = "PaybaseintegprdVm-nic-nsg"
#   subnet_id      = module.networking.subnet_ids["IntegrationvmSubnet"]
# }
module "app_platform" {
  source = "../../modules/app_platform"
  resource_group_name       = azurerm_resource_group.app_rg.name
  location                  = azurerm_resource_group.app_rg.location
  tags                      = local.common_tags
  app_service_plan_name     = "Paybase-prd-ASP"
  acr_name                  = "Paybaseacr"
  storage_account_name      = "paybasestorageprd"
  servicebus_namespace_name = "Paybasesb"
  app_service_plan_sku      = "P1v2"
  acr_sku                   = "Premium"
  app_insights_name         = "Paybase-appinsides"
  app_service_docker_images  = local.app_service_docker_images
  docker_image_tag           = var.docker_image_tag
  function_app_names         = local.function_app_names
  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id
  private_dns_zone_ids       = module.networking.private_dns_zone_ids


}