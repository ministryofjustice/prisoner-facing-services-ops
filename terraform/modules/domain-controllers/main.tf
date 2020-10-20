data "azurerm_resource_group" "main" {
  name = "${var.rg_name}-certservices-${var.environment}"
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

resource "azurerm_availability_set" "dc_as" {
  name                         = "${var.prefix}dc-as"
  location                     = data.azurerm_resource_group.main.location
  resource_group_name          = data.azurerm_resource_group.main.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_network_interface" "dc-1-nic" {
  name                = "${var.prefix}dc-1-nic"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_servers = [
    "10.42.1.13",
    "10.42.1.12"
  ]
  ip_configuration {
    name      = "${var.prefix}dc-1-ip"
    subnet_id = data.azurerm_subnet.existing.id

    private_ip_address_allocation = "Static"
    private_ip_address            = "10.42.1.12"
  }
}

resource "azurerm_network_interface" "dc-2-nic" {
  name                = "${var.prefix}dc-2-nic"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_servers = [
    "10.42.1.12",
    "10.42.1.13"
  ]
  ip_configuration {
    name      = "${var.prefix}dc-2-ip"
    subnet_id = data.azurerm_subnet.existing.id

    private_ip_address_allocation = "Static"
    private_ip_address            = "10.42.1.13"
  }
}

resource "azurerm_virtual_machine" "dc-1" {
  name                  = "${var.prefix}dc-1"
  location              = data.azurerm_resource_group.main.location
  availability_set_id   = azurerm_availability_set.dc_as.id
  resource_group_name   = data.azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.dc-1-nic.id]
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
    name              = "${var.prefix}dc-1-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.prefix}dc-1"
    admin_username = data.azurerm_key_vault_secret.admin_username.value
    admin_password = data.azurerm_key_vault_secret.admin_password.value
  }
  os_profile_windows_config {
  }
  tags = {
    environment = var.environment
  }
}

resource "azurerm_virtual_machine" "dc-2" {
  name                  = "${var.prefix}dc-2"
  location              = data.azurerm_resource_group.main.location
  availability_set_id   = azurerm_availability_set.dc_as.id
  resource_group_name   = data.azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.dc-2-nic.id]
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
    name              = "${var.prefix}dc-2-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.prefix}dc-2"
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
  name                 = "dc-1-AV"
  virtual_machine_id   = azurerm_virtual_machine.dc-1.id
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

resource "azurerm_virtual_machine_extension" "Antimalware-dc2" {
  name                 = "dc-2-AV"
  virtual_machine_id   = azurerm_virtual_machine.dc-2.id
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
  name                 = "OMS-Extension"
  virtual_machine_id   = azurerm_virtual_machine.dc-1.id
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
  name                 = "OMS-Extension"
  virtual_machine_id   = azurerm_virtual_machine.dc-2.id
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