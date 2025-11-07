locals {
  env       = "prod"
  project   = "Voltica" # Project is now Voltica
  common_tags = { "Business-owners" = "Project Manager", "Core-function" = "application", "Criticality" = "1", "Environment" = local.env, "Primary-application" = local.project, "Technical-owner" = "DevOps Team" }

  # All app service names and docker paths are now based on "Voltica"
  app_service_docker_images = {
    "volticaprd-admin"       = "voltica/admin-app"
    "volticaprd-signalR"     = "voltica/signal-app"
    "volticaprd-coreapi"     = "voltica/coreapi-app"
    "volticaprd-cardsapi"    = "voltica/cardsapi-app"
    "volticaprd-banksapi"    = "voltica/banksapi-app"
    "volticaprd-paymentsapi" = "voltica/paymentsapi-app"
    "volticaprd-paylinks"    = "voltica/paylinks-app"
    "volticaprd-user"        = "voltica/user-app"
  }
  
  # All function names are now based on "Voltica"
  function_app_names = [
    "VolticaMarketdataprd",
    "Volticasubscriberprd",
    "VolticaSweepfunctionprd"
  ]
}

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
    IntegrationvmSubnet    = { address_prefixes = ["10.10.10.0/24"] }
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
  key_vault_name      = "voltica-prod-kv-prod882" # <-- Unique name
  vm_admin_password   = var.admin_password
  key_vault_admin_object_ids = [data.azurerm_client_config.current.object_id]
}

module "sql_vm" {
  source = "../../modules/sql_vm"
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  tags                = local.common_tags
  vm_name             = "volticasqlprod" # <-- Name based on Voltica
  vm_size             = "Standard_B2ms"
  admin_username      = "voltica_admin"
  admin_password      = var.admin_password
  public_ip_name      = "voltica-prod-vm-pip" # <-- Name based on Voltica
  nsg_name            = "volticasqlprod-nic-nsg" # <-- Name based on Voltica
  subnet_id           = module.networking.subnet_ids["sqlVmSubnet"]
  data_disks = [
    {
      name                 = "sql-data-disk-1"
      disk_size_gb         = 32
      lun                  = 0
      caching              = "ReadWrite"
      create_option        = "Empty"
      storage_account_type = "Standard_LRS"
    },
    {
      name                 = "sql-data-disk-2"
      disk_size_gb         = 32
      lun                  = 1
      caching              = "ReadOnly"
      create_option        = "Empty"
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
  resource_group_name         = azurerm_resource_group.app_rg.name
  location                    = azurerm_resource_group.app_rg.location
  tags                        = local.common_tags
  app_service_plan_name       = "voltica-prod-asp" # <-- Name based on Voltica
  acr_name                    = "volticaacrprod882" # <-- Unique name
  storage_account_name        = "volticastorageprod882" # <-- Unique name
  servicebus_namespace_name   = "volticasbprod882" # <-- Unique name
  app_service_plan_sku        = "P1v2"
  acr_sku                     = "Premium"
  app_insights_name           = "voltica-prod-appinsides" # <-- Name based on Voltica
  app_service_docker_images   = local.app_service_docker_images
  docker_image_tag            = var.docker_image_tag
  function_app_names          = local.function_app_names
  private_endpoint_subnet_id  = module.networking.private_endpoint_subnet_id
  private_dns_zone_ids        = module.networking.private_dns_zone_ids
}
