# --- Resource Group Configuration ---
app_rg_name    = "rg-Voltica-tst-apps"
vm_rg_name     = "rg-Voltica-tst-vm"
location       = "Southeast Asia"

# --- Application Services Names ---
storage_account_name         = "volticastoragetstirfan77" # <-- UPDATED
app_insights_name            = "Voltica-APiUI-insides-tst"
app_service_plan_name        = "Voltica-tst-Plan"
service_bus_namespace_name = "Volticapubsubtst-irfan771" # <-- UPDATED
key_vault_name               = "Voltica-tst-kv-irfan771" # <-- UPDATED
dotnet_version               = "8.0"
log_analytics_workspace_name = "log-Voltica-tst-appinsides"
function_app_names = [
  "Voltica-Marketdatatst-irfan771",
  "Voltica-Subscribertst-irfan771",
  "Voltica-SweepFunapptst-irfan771",
  # "Voltica-kraken-tst" # 4th function app
]

# --- ADDED: Web App Configuration ---
web_app_names = [
  "Voltica-TST-App",
  "Voltica-TST-Admin",
  "Voltica-TST-coreapi",
  "Voltica-TST-Cardsapi",
  "Voltica-TST-Signalr",
  "Voltica-TST-Integration",
]

# --- Infrastructure Services Names ---
vnet_name           = "vnet-Voltica-tst"
nsg_name            = "nsg-Voltica-tst-default"
vm_name             = "Volticatstsql"
vm_admin_username   = "Volticatstadmin"
# vm_admin_password is NOT set here. It will be provided via CI/CD.





