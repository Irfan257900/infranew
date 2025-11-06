resource "azurerm_service_plan" "asp" {
  name                = var.app_service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.app_service_plan_sku
  tags                = var.tags
}

resource "azurerm_container_registry" "acr" {
  name                          = var.acr_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.acr_sku
  admin_enabled                 = true
  public_network_access_enabled = true
  tags                          = var.tags
}

resource "azurerm_storage_account" "sa" {
  name                          = var.storage_account_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false
  tags                          = var.tags
   
  }
  

resource "azurerm_servicebus_namespace" "sbn" {
  name                          = var.servicebus_namespace_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = "Standard"
  public_network_access_enabled = true
  tags                          = var.tags
}

resource "azurerm_linux_web_app" "app_services" {
  for_each                      = var.app_service_docker_images
  name                          = each.key
  resource_group_name           = var.resource_group_name
  location                      = var.location
  service_plan_id               = azurerm_service_plan.asp.id
  public_network_access_enabled = false
  tags                          = var.tags

  site_config {
    always_on = true
    application_stack {
      docker_image_name = "${azurerm_container_registry.acr.login_server}/${each.value}:${var.docker_image_tag}"
    }
  }

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.appinsights.connection_string
    "DOCKER_REGISTRY_SERVER_URL"            = "https://${azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"       = azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"       = azurerm_container_registry.acr.admin_password
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"   = "false"
  }
}


resource "azurerm_linux_function_app" "function_apps" {
  for_each                      = toset(var.function_app_names)
  name                          = each.value
  resource_group_name           = var.resource_group_name
  location                      = var.location
  service_plan_id               = azurerm_service_plan.asp.id
  public_network_access_enabled = false
  storage_account_name          = azurerm_storage_account.sa.name
  storage_account_access_key    = azurerm_storage_account.sa.primary_access_key
  tags                          = var.tags

  site_config {
    always_on = true
    # For a code-based app, we define the runtime stack directly
    application_stack {
      dotnet_version = "8.0" # Or "8.0" etc.
    }
  }

  app_settings = {
    "AzureWebJobsStorage"                   = azurerm_storage_account.sa.primary_connection_string
    "FUNCTIONS_EXTENSION_VERSION"           = "~4"
    "FUNCTIONS_WORKER_RUNTIME"              = "dotnet" # This now refers to the code language
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.appinsights.connection_string
    
  }
}



resource "azurerm_private_endpoint" "acr_pe" {
  name                = "${var.acr_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids.acr]
  }
  private_service_connection {
    name                           = "${var.acr_name}-psc"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }
}

resource "azurerm_private_endpoint" "storage_pe" {
  name                = "${var.storage_account_name}-blob-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids.storage_blob]
  }
  private_service_connection {
    name                           = "${var.storage_account_name}-blob-psc"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

resource "azurerm_private_endpoint" "web_apps_pe" {
  for_each            = merge(azurerm_linux_web_app.app_services, azurerm_linux_function_app.function_apps)
  name                = "${each.key}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids.app_service]
  }
  private_service_connection {
    name                           = "${each.key}-psc"
    private_connection_resource_id = each.value.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
}
# --- Private Endpoints for Function Apps ---
# resource "azurerm_private_endpoint" "function_apps_pe" {
#   for_each            = azurerm_linux_function_app.function_apps # <-- Loops ONLY over Function Apps
#   name                = "${each.key}-pe"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = var.private_endpoint_subnet_id
#   tags                = var.tags
#   private_dns_zone_group {
#     name                 = "default"
#     private_dns_zone_ids = [var.private_dns_zone_ids.app_service]
#   }
#   private_service_connection {
#     name                           = "${each.key}-psc"
#     private_connection_resource_id = each.value.id
#     is_manual_connection           = false
#     subresource_names              = ["sites"]
#   }
# }

resource "azurerm_application_insights" "appinsights" {
  name                = var.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id # <-- ADD THIS LINE
  tags                = var.tags
}
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.app_insights_name}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}