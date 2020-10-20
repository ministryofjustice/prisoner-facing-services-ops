data "azurerm_resource_group" "main" {
  name = "${var.rg_name}-certservices-${var.environment}"
}

data "azurerm_key_vault_secret" "domaincred_username" {
  name         = "domaincred-username"
  key_vault_id = var.keyvault_uri
}

data "azurerm_key_vault_secret" "domaincred_password" {
  name         = "domaincred-password"
  key_vault_id = var.keyvault_uri
}

data "azurerm_key_vault_secret" "dsrm_username" {
  name         = "dsrm-username"
  key_vault_id = var.keyvault_uri
}

data "azurerm_key_vault_secret" "dsrm_password" {
  name         = "dsrm-password"
  key_vault_id = var.keyvault_uri
}

data "azurerm_key_vault_secret" "ad_username" {
  name         = "ad-username"
  key_vault_id = var.keyvault_uri
}

data "azurerm_key_vault_secret" "ad_password" {
  name         = "ad-password"
  key_vault_id = var.keyvault_uri
}

data "azurerm_key_vault_secret" "recyclebin_username" {
  name         = "recyclebin-username"
  key_vault_id = var.keyvault_uri
}

data "azurerm_key_vault_secret" "recyclebin_password" {
  name         = "recyclebin-password"
  key_vault_id = var.keyvault_uri
}

resource "azurerm_automation_account" "dsc-aa" {
  name                = "DSCAutomation"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  sku_name            = "Basic"
}

resource "azurerm_automation_module" "AD" {
  name                    = "xActiveDirectory"
  resource_group_name     = data.azurerm_resource_group.main.name
  automation_account_name = var.automation_account

  module_link {
    uri = "https://devopsgallerystorage.blob.core.windows.net/packages/xactivedirectory.2.19.0.nupkg"
  }
}

resource "azurerm_automation_credential" "domaincred" {
  name                    = "domaincred"
  resource_group_name     = data.azurerm_resource_group.main.name
  automation_account_name = var.automation_account
  username                = data.azurerm_key_vault_secret.domaincred_username.value
  password                = data.azurerm_key_vault_secret.domaincred_password.value
}

resource "azurerm_automation_credential" "dsrm" {
  name                    = "dsrm"
  resource_group_name     = data.azurerm_resource_group.main.name
  automation_account_name = var.automation_account
  username                = data.azurerm_key_vault_secret.dsrm_username.value
  password                = data.azurerm_key_vault_secret.dsrm_password.value
}

resource "azurerm_automation_credential" "ad" {
  name                    = "ad"
  resource_group_name     = data.azurerm_resource_group.main.name
  automation_account_name = var.automation_account
  username                = data.azurerm_key_vault_secret.ad_username.value
  password                = data.azurerm_key_vault_secret.ad_password.value
}

resource "azurerm_automation_credential" "recyclebin" {
  name                    = "recyclebin"
  resource_group_name     = data.azurerm_resource_group.main.name
  automation_account_name = var.automation_account
  username                = data.azurerm_key_vault_secret.recyclebin_username.value
  password                = data.azurerm_key_vault_secret.recyclebin_password.value
}
