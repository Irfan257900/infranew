resource "azurerm_windows_function_app" "function_app" {
  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.app_service_plan_id
  tags                = var.tags

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  site_config {
    application_stack {
      dotnet_version = "v8.0"
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = var.app_insights_instrumentation_key
  }
lifecycle {
    ignore_changes = [
      app_settings # Prevents overwriting manual environment variables
    ]
  }
}