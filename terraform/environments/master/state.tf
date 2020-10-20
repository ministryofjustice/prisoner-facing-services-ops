# These settings should be obtained from KeyVault

/* data "azurerm_key_vault_secret" "tf_storage_account_name" {
  name = "terraformstatestore"
  key_vault_id = data.azurerm_key_vault.keyvault.id
} */

terraform {
  backend "azurerm" {
    storage_account_name = "default"
    container_name       = "default"
    key                  = "default"
    access_key           = "default"
  }
}

provider "azurerm" {
  version = "=2.0"

  features {}

  /*    client_id                               = ""
    client_secret                           = ""
    subscription_id                         = ""
    tenant_id                               = "" */


}
