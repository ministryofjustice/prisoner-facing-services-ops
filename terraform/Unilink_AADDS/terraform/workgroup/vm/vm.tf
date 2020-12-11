

resource "azurerm_availability_set" "isavailabilityset" {
  name                         = var.avs
  resource_group_name          = var.rg-name
  location                     = var.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
  tags = {
    environment = var.env
  }
}




resource "azurerm_virtual_machine" "vm" {
  name = lookup(var.internal-dns-name, count.index + 1, "Default")
  #name                         =  format("%s-%s", var.prefix, lookup(var.short-code, count.index + 1, "Default"))
  location                      = var.location
  availability_set_id           = azurerm_availability_set.isavailabilityset.id
  resource_group_name           = var.rg-name
  network_interface_ids         = [element(azurerm_network_interface.primary.*.id, count.index)]
  vm_size                       = "Standard_B2ms"
  delete_os_disk_on_termination = true
  count                         = var.vm-count


  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = format("%s-%s", lookup(var.internal-dns-name, count.index + 1, "Default"), "osdisk")
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = format("%s-%s", lookup(var.internal-dns-name, count.index + 1, "Default"), "storage-disk")
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "256"

  }

  os_profile {
    computer_name  = lookup(var.internal-dns-name, count.index + 1, "Default")
    admin_username = data.azurerm_key_vault_secret.localadmin-username.value
    admin_password = data.azurerm_key_vault_secret.localadmin.value
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
    timezone                  = "Greenwich Standard Time"
    winrm {
      protocol = "HTTP"
    }


    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = file("${path.module}/files/FirstLogonCommands.xml")
    }
  }



  identity {
    type = "SystemAssigned"
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = data.azurerm_storage_account.bootdiagstorageact.primary_blob_endpoint
  }


  tags = {
    environment = var.environment
    prison      = lookup(var.prison, count.index + 1, "Default")

  }
}

resource "azurerm_virtual_machine_extension" "network-watcher" {
  count                      = var.vm-count
  name                       = "NetworkWatcherAgentWindows"
  virtual_machine_id         = azurerm_virtual_machine.vm[count.index].id
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentWindows"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
}


resource "azurerm_virtual_machine_extension" "anti-malware" {
  count                = var.vm-count
  name                 = "IaaSAntimalware"
  virtual_machine_id   = azurerm_virtual_machine.vm[count.index].id
  publisher            = "Microsoft.Azure.Security"
  type                 = "IaaSAntimalware"
  type_handler_version = "1.3"

  settings = <<SETTINGS
    {
      "AntimalwareEnabled": "true",
      "RealtimeProtectionEnabled": "true",
      "ScheduledScanSettings": {
        "isEnabled": "true",
        "day": "7",
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

resource "azurerm_backup_protected_vm" "vm1" {
  count               = var.vm-count
  resource_group_name = data.azurerm_backup_policy_vm.policy.resource_group_name
  recovery_vault_name = data.azurerm_backup_policy_vm.policy.recovery_vault_name
  source_vm_id        = azurerm_virtual_machine.vm.*.id[count.index]
  backup_policy_id    = data.azurerm_backup_policy_vm.policy.id
  depends_on          = [azurerm_virtual_machine.vm]
}

