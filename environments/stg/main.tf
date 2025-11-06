
locals {
  env         = "stg"
  project     = "Rapidz"
  common_tags = { "Business-owners" = "Project Manager", "Core-function" = "application", "Criticality" = "2", "Environment" = local.env, "Primary-application" = local.project, "Technical-owner" = "DevOps Team" }

  # This block defines the names for container-based App Services
  app_service_docker_images = {
    "Rapidzstg-admin"       = "Rapidz/admin-app"
    "Rapidzestg-api"     = "Rapidz/api-app"
    "Rapidzstg-signalR" = "Rapidz/signal-app"
    "Rapidzstg-coreapi" = "Rapidz/coreapi-app"
    "Rapidzstg-cardsapi" = "Rapidz/cardsapi-app"
    "Rapidzstg-banksapi" = "Rapidz/banksapi-app"
    "Rapidzstg-paymentsapi" = "Rapidz/paymentsapi-app"
    "Rapidzstg-paylinks" = "Rapidz/paylinks-app"
    "Rapidzstg" = "Rapidz/user-app"
  }
  

  function_app_names = [
    "RapidzstgMarketdata",
    "Rapidzstgsubscriber",
    "RapidzstgSweepfunction"
  ]
}

# ... (the rest of your main.tf file)

# Data source to get the current identity running Terraform
data "azurerm_client_config" "current" {}

# --- RESOURCE GROUPS ---
resource "azurerm_resource_group" "network_rg" {
  name     = "${local.project}-${local.env}-network-rg"
  location = "Southeast Asia"
  tags     = local.common_tags
}
resource "azurerm_resource_group" "app_rg" {
  name     = "${local.project}-${local.env}-app-rg"
  location = "Southeast Asia"
  tags     = local.common_tags
}
resource "azurerm_resource_group" "vm_rg" {
  name     = "${local.project}-${local.env}-vm-rg"
  location = "Southeast Asia"
  tags     = local.common_tags
}
resource "azurerm_resource_group" "security_rg" {
  name     = "${local.project}-${local.env}-security-rg"
  location = "Southeast Asia"
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
    sqlVmSubnet               = { address_prefixes = ["10.10.1.0/24"] }
    IntegrationvmSubnet       = { address_prefixes = ["10.10.2.0/24"] }
    PrivateEndpointsSubnet = { address_prefixes = ["10.10.3.0/24"] }
  }
  private_endpoints_subnet_name = "PrivateEndpointsSubnet"
  
}

module "security" {
  source = "../../modules/security"

  resource_group_name = azurerm_resource_group.security_rg.name
  location            = azurerm_resource_group.security_rg.location
  tags                = local.common_tags
  key_vault_name      = "Rapidzstg-kv"
  vm_admin_password   = var.admin_password
  key_vault_admin_object_ids = [data.azurerm_client_config.current.object_id]
}


module "sql_vm" {
  source = "../../modules/sql_vm"

  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  tags                = local.common_tags
  vm_name        = "Rapidzsqlstg"
  vm_size        = "Standard_B2ms"
  admin_username = "hswerWjdbds23"
  admin_password = var.admin_password
  public_ip_name = "Rapidz-stg-vm-pip"
  nsg_name       = "Rapidzsqlstg-nic-nsg"
  subnet_id           = module.networking.subnet_ids["sqlVmSubnet"]
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
  # ----------------------------------------

}

module "integration_vm_stg" {
  source = "../../modules/integration_vm_stg" 

  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  tags                = local.common_tags
  vm_name        = "RapidintegStgVm" # Unique name for the new VM
  vm_size        = "Standard_B2s"    # Example: different size
  admin_username = "RsgjhsdEintegdfdh"
  admin_password = var.admin_password
  public_ip_name = "Rapidz-stg-integration-vm-pip"
  nsg_name       = "RapidzntegStgVm-nic-nsg"
  subnet_id      = module.networking.subnet_ids["IntegrationvmSubnet"]
}
module "app_platform" {
  source = "../../modules/app_platform"
  resource_group_name       = azurerm_resource_group.app_rg.name
  location                  = azurerm_resource_group.app_rg.location
  tags                      = local.common_tags
  app_service_plan_name     = "Rapidz-stg-ASP"
  acr_name                  = "Rapidzstgacr"
  storage_account_name      = "rapidzstgstorage"
  servicebus_namespace_name = "Rapidzpestgsb"
  app_service_plan_sku      = "P1v2"
  acr_sku                   = "Premium"
  app_insights_name         = "Rapidzstg-appinsides"
  app_service_docker_images  = local.app_service_docker_images
  docker_image_tag           = var.docker_image_tag
  function_app_names         = local.function_app_names
  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id
  private_dns_zone_ids       = module.networking.private_dns_zone_ids
}