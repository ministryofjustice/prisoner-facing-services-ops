#refer to a subnet
data "azurerm_subnet" "core" {
  name                 = var.existing-subnet-name
  virtual_network_name = var.existing-vnet-name
  resource_group_name  = var.network-rg
}



data "azurerm_backup_policy_vm" "policy" {
  recovery_vault_name = "pfs-winvm-prod-recovery-vault"
  name                = "pfs-winvm-prod-content-bkp-policy"
  resource_group_name = "pfs-prod-winvm-content-backup-services"

}

data "azurerm_storage_account" "bootdiagstorageact" {
  name                = "bootdiagstorageactwinvm"
  resource_group_name = "pfs-all-bootdiag-rg"
}


data "azurerm_key_vault_secret" "localadmin" {
  name         = var.workgroup_pass
  key_vault_id = data.azurerm_key_vault.pfs-key.id
}
#username
data "azurerm_key_vault_secret" "localadmin-username" {
  name         = var.workgroup_user
  key_vault_id = data.azurerm_key_vault.pfs-key.id
}


data "azurerm_key_vault" "pfs-key" {
  name                = "prisoner-ops-vault"
  resource_group_name = "prisoner-facing-ops-vault"
}


data "azurerm_key_vault_secret" "domain_password" {
  name         = var.domain_join_password
  key_vault_id = data.azurerm_key_vault.pfs-key.id
}
#username
data "azurerm_key_vault_secret" "domain_join_username" {
  name         = var.domain_join_username
  key_vault_id = data.azurerm_key_vault.pfs-key.id
}
