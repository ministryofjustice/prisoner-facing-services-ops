
terraform {

  backend "azurerm" {
    resource_group_name  = "prisoner-facing-tfstate"
    storage_account_name = "pfsterraformstate"
    container_name       = "prod"
    key                  = "azure_vault_prod.tfstate"
  }
}


module "resource-group" {
  source      = "..\\resource_groups"
  rg-count    = var.rg-count
  rg-name     = var.rg-name
  usage       = var.usage
  location    = var.location
  environment = var.environment
}


resource "azurerm_key_vault" "vault" {
  tenant_id           = data.azurerm_client_config.current.tenant_id
  name                = var.vault-name
  location            = var.location
  resource_group_name = var.rg-name


  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  enabled_for_deployment      = true
  soft_delete_enabled         = true

  enabled_for_template_deployment = false
  tags = {
    "environment" = "Prod"
  }
  /* ## Removed the network ACL for now so we can use Azure Dev Ops
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = var.ips
    
    
virtual_network_subnet_ids  = concat(
    [for subnet in data.azurerm_subnet.dev_sns : subnet.id],
    [for subnet in data.azurerm_subnet.prod_sns : subnet.id],
    [for subnet in data.azurerm_subnet.prodacc_sns : subnet.id],
    [for subnet in data.azurerm_subnet.stage_sns : subnet.id],

  )

      
  }
  */
}



module "keyvault_access_policy" {
  source             = "..\\..\\Modules\\keyvault_access_policy"
  keyvault_id        = data.azurerm_key_vault.keyvault.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  user_objectid_list = var.admin_objectid_list

  keyvault_key_permissions     = var.keyvault_admin_key_permissions
  keyvault_secret_permissions  = var.keyvault_admin_secret_permissions
  keyvault_cert_permissions    = var.keyvault_admin_cert_permissions
  keyvault_storage_permissions = var.keyvault_admin_storage_permissions
}

