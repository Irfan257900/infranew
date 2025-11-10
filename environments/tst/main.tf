# --- Standardized Tagging Definition & Data ---
locals {
  env       = "tst"
  project   = "Voltica"
  common_tags = {
    "Business-owners"     = "Project Manager"
    "Core-function"       = "application"
    "Criticality"         = "3"
    "Environment"         = local.env
    "Primary-application" = local.project
    "Technical-owner"     = "DevOps Team"
  }
}
data "azurerm_client_config" "current" {}

# --- Resource Group Definitions ---
resource "azurerm_resource_group" "rg_apps" {
  name     = var.app_rg_name
  location = var.location
  tags     = local.common_tags
}
resource "azurerm_resource_group" "rg_infra" {
  name     = var.vm_rg_name
  location = var.location
  tags     = local.common_tags
}

# --- Infrastructure Resources (in rg_infra) ---
module "networking" {
  source              = "../../modules/networking_tst"
  vnet_name           = var.vnet_name
  nsg_name            = var.nsg_name
  location            = azurerm_resource_group.rg_infra.location
  resource_group_name = azurerm_resource_group.rg_infra.name
  tags                = local.common_tags
}
module "windows_vm_sql" {
  source              = "../../modules/windows_vm_sql"
  vm_name             = var.vm_name
  location            = azurerm_resource_group.rg_infra.location
  resource_group_name = azurerm_resource_group.rg_infra.name
  subnet_id           = module.networking.subnet_id
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  tags                = local.common_tags
}

# --- Application Resources (in rg_apps) ---
module "storage_account" {
  source               = "../../modules/storage_account"
  storage_account_name = var.storage_account_name
  location             = azurerm_resource_group.rg_apps.location
  resource_group_name  = azurerm_resource_group.rg_apps.name
  tags                 = local.common_tags
}

# --- THIS BLOCK WAS MOVED UP ---
resource "azurerm_log_analytics_workspace" "shared_workspace" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.rg_apps.location
  resource_group_name = azurerm_resource_group.rg_apps.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

# --- THIS BLOCK NOW CORRECTLY DEPENDS ON THE WORKSPACE ABOVE ---
resource "azurerm_application_insights" "shared_insights" {
  name                = var.app_insights_name
  location            = azurerm_resource_group.rg_apps.location
  resource_group_name = azurerm_resource_group.rg_apps.name
  workspace_id        = azurerm_log_analytics_workspace.shared_workspace.id
  application_type    = "web"
  tags                = local.common_tags
}

module "app_service_plan" {
  source                = "../../modules/app_service_plan"
  app_service_plan_name = var.app_service_plan_name
  location              = azurerm_resource_group.rg_apps.location
  resource_group_name   = azurerm_resource_group.rg_apps.name
  sku_name              = "B1"
  os_type               = "Windows"
  tags                  = local.common_tags
}
module "service_bus" {
  source                     = "../../modules/service_bus"
  service_bus_namespace_name = var.service_bus_namespace_name
  location                   = azurerm_resource_group.rg_apps.location
  resource_group_name        = azurerm_resource_group.rg_apps.name
  sku                        = "Standard"
  tags                       = local.common_tags
}
module "key_vault" {
  source              = "../../modules/key_vault"
  key_vault_name      = var.key_vault_name
  location            = azurerm_resource_group.rg_apps.location
  resource_group_name = azurerm_resource_group.rg_apps.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = local.common_tags
}
resource "azurerm_role_assignment" "kv_admin_rbac" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}
module "function_apps" {
  for_each = toset(var.function_app_names)
  source   = "../../modules/function_app"

  location                       = azurerm_resource_group.rg_apps.location
  resource_group_name            = azurerm_resource_group.rg_apps.name
  tags                           = local.common_tags
  function_app_name              = each.key
  dotnet_version                 = var.dotnet_version
  app_service_plan_id            = module.app_service_plan.id
  app_insights_instrumentation_key = azurerm_application_insights.shared_insights.instrumentation_key
  storage_account_name           = module.storage_account.name
  storage_account_access_key     = module.storage_account.primary_access_key

}

