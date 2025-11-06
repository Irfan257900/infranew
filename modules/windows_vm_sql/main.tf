# --- Core VM Networking ---
resource "azurerm_public_ip" "pip" {
  name                = "pip-${var.vm_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-${var.vm_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# --- Virtual Machine Definition ---
resource "azurerm_windows_virtual_machine" "vm" {
  name                  = var.vm_name
  computer_name         = var.vm_name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_B2ms"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic.id]
  tags                  = var.tags

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2022-ws2022"
    sku       = "sqldev-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
}

# 1. Create the first managed disk resource
resource "azurerm_managed_disk" "data_disk_1" {
  name                 = "${var.vm_name}-datadisk1"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS" # HDD
  create_option        = "Empty"
  disk_size_gb         = 32
  tags                 = var.tags
}

# 2. Attach the first disk to the VM
resource "azurerm_virtual_machine_data_disk_attachment" "attachment_1" {
  managed_disk_id    = azurerm_managed_disk.data_disk_1.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = 0 # Logical Unit Number 0
  caching            = "ReadWrite"
}

# 3. Create the second managed disk resource
resource "azurerm_managed_disk" "data_disk_2" {
  name                 = "${var.vm_name}-datadisk2"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS" # HDD
  create_option        = "Empty"
  disk_size_gb         = 32
  tags                 = var.tags
}

# 4. Attach the second disk to the VM
resource "azurerm_virtual_machine_data_disk_attachment" "attachment_2" {
  managed_disk_id    = azurerm_managed_disk.data_disk_2.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = 1 # Logical Unit Number 1
  caching            = "ReadWrite"
}