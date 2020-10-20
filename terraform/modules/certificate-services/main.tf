resource "azurerm_resource_group" "main" {
  name     = "${var.rg_name}-certservices-${var.environment}"
  location = "UK South"
}

data "azurerm_key_vault_secret" "admin_username" {
  name         = "pfs-cs-vm-username"
  key_vault_id = var.keyvault_uri
}

data "azurerm_key_vault_secret" "admin_password" {
  name         = "pfs-cs-vm-password"
  key_vault_id = var.keyvault_uri
}

data "azurerm_key_vault_secret" "oms-id" {
  name         = "oms-workspace-id"
  key_vault_id = var.keyvault_uri
}

data "azurerm_key_vault_secret" "oms-key" {
  name         = "oms-key"
  key_vault_id = var.keyvault_uri
}
data "azurerm_subnet" "existing" {
  name                 = var.mgmt_subnet
  resource_group_name  = var.vnet_rg
  virtual_network_name = var.mgmt_vnet
}

resource "azurerm_public_ip" "public_ip" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.main.location
  resource_group_name = "${var.rg_name}-certservices-${var.environment}"
  allocation_method   = "Static"
}

/* output "subnet_id" {
  value = data.azurerm_subnet.existing-subnet.id
} */
resource "azurerm_network_interface" "vm-1-nic" {
  name                = "${var.prefix}-cs-vm-1-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  ip_configuration {
    name                          = "pfs-cs-vm-1-ip"
    subnet_id                     = data.azurerm_subnet.existing.id
    private_ip_address_allocation = "Static"
  }
}

resource "azurerm_network_interface" "vm-2-nic" {
  name                = "${var.prefix}-cs-vm-2-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  ip_configuration {
    name                          = "pfs-cs-vm-2-ip"
    subnet_id                     = data.azurerm_subnet.existing.id
    private_ip_address_allocation = "Static"
  }
}

resource "azurerm_network_interface" "vm-1-ndes" {
  name                = "${var.prefix}-cs-vm-1-ndes"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  ip_configuration {
    name                          = "pfs-cs-vm-ndes-ip"
    subnet_id                     = data.azurerm_subnet.existing.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.42.1.14"
  }
}

resource "azurerm_virtual_machine" "vm-1" {
  name                  = "${var.prefix}-cs-vm-1"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.vm-1-nic.id]
  vm_size               = "Standard_B2ms"
  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true
  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "pfs-cs-vm-1-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "pfs-cs-vm-1"
    admin_username = data.azurerm_key_vault_secret.admin_username.value
    admin_password = data.azurerm_key_vault_secret.admin_password.value
  }
  os_profile_windows_config {
  }
  tags = {
    environment = var.environment
  }
}

resource "azurerm_virtual_machine" "vm-2" {
  name                  = "${var.prefix}-cs-vm-2"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.vm-2-nic.id]
  vm_size               = "Standard_B2ms"
  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true
  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "pfs-cs-vm-2-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "pfs-cs-vm-2"
    admin_username = data.azurerm_key_vault_secret.admin_username.value
    admin_password = data.azurerm_key_vault_secret.admin_password.value
  }
  os_profile_windows_config {
  }
  tags = {
    environment = var.environment
  }
}

resource "azurerm_virtual_machine" "vm-ndes" {
  name                  = "${var.prefix}-ndes-1"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.vm-1-ndes.id]
  vm_size               = "Standard_B2ms"
  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true
  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "pfs-ndes-1-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "pfs-ndes-1"
    admin_username = data.azurerm_key_vault_secret.admin_username.value
    admin_password = data.azurerm_key_vault_secret.admin_password.value
  }
  os_profile_windows_config {
  }
  tags = {
    environment = var.environment
  }
}
resource "azurerm_virtual_machine_extension" "Antimalware" {
  name                 = "Antimalware"
  virtual_machine_id   = azurerm_virtual_machine.vm-ndes.id
  publisher            = "Microsoft.Azure.Security"
  type                 = "IaaSAntimalware"
  type_handler_version = "1.3"
  settings             = <<SETTINGS
    {
      "AntimalwareEnabled": true,
      "RealtimeProtectionEnabled": "true",
      "ScheduledScanSettings": {
      "isEnabled": "true",
      "day": "1",
      "time": "120",
      "scanType": "Quick"
      },
      "Exclusions": {
      "Extensions": "",
      "Paths": "",
      "Processes": ""
      }
    }
  SETTINGS
}
resource "azurerm_virtual_machine_extension" "Antimalware-cs2" {
  name                 = "Antimalware"
  virtual_machine_id   = azurerm_virtual_machine.vm-2.id
  publisher            = "Microsoft.Azure.Security"
  type                 = "IaaSAntimalware"
  type_handler_version = "1.3"
  settings             = <<SETTINGS
    {
      "AntimalwareEnabled": true,
      "RealtimeProtectionEnabled": "true",
      "ScheduledScanSettings": {
      "isEnabled": "true",
      "day": "1",
      "time": "120",
      "scanType": "Quick"
      },
      "Exclusions": {
      "Extensions": "",
      "Paths": "",
      "Processes": ""
      }
    }
  SETTINGS
}
resource "azurerm_virtual_machine_extension" "Antimalware-cs1" {
  name                 = "Antimalware"
  virtual_machine_id   = azurerm_virtual_machine.vm-1.id
  publisher            = "Microsoft.Azure.Security"
  type                 = "IaaSAntimalware"
  type_handler_version = "1.3"
  settings             = <<SETTINGS
    {
      "AntimalwareEnabled": true,
      "RealtimeProtectionEnabled": "true",
      "ScheduledScanSettings": {
      "isEnabled": "true",
      "day": "1",
      "time": "120",
      "scanType": "Quick"
      },
      "Exclusions": {
      "Extensions": "",
      "Paths": "",
      "Processes": ""
      }
    }
  SETTINGS
}
resource "azurerm_virtual_machine_extension" "OMS-1" {
  name                 = "MicrosoftMonitoringAgent"
  virtual_machine_id   = azurerm_virtual_machine.vm-1.id
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "MicrosoftMonitoringAgent"
  type_handler_version = "1.0"
  settings             = <<-BASE_SETTINGS
 {
  "workspaceId": "${data.azurerm_key_vault_secret.oms-id.value}"
 }
 BASE_SETTINGS

  protected_settings = <<-PROTECTED_SETTINGS
 {
   "workspaceKey": "${data.azurerm_key_vault_secret.oms-key.value}"
 }
 PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "OMS" {
  name                 = "MicrosoftMonitoringAgent"
  virtual_machine_id   = azurerm_virtual_machine.vm-ndes.id
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "MicrosoftMonitoringAgent"
  type_handler_version = "1.0"
  settings             = <<-BASE_SETTINGS
 {
  "workspaceId": "${data.azurerm_key_vault_secret.oms-id.value}"
 }
 BASE_SETTINGS

  protected_settings = <<-PROTECTED_SETTINGS
 {
   "workspaceKey": "${data.azurerm_key_vault_secret.oms-key.value}"
 }
 PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "OMS-2" {
  name                 = "MicrosoftMonitoringAgent"
  virtual_machine_id   = azurerm_virtual_machine.vm-2.id
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "MicrosoftMonitoringAgent"
  type_handler_version = "1.0"
  settings             = <<-BASE_SETTINGS
 {
  "workspaceId": "${data.azurerm_key_vault_secret.oms-id.value}"
 }
 BASE_SETTINGS

  protected_settings = <<-PROTECTED_SETTINGS
 {
   "workspaceKey": "${data.azurerm_key_vault_secret.oms-key.value}"
 }
 PROTECTED_SETTINGS
}