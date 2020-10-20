data "azurerm_key_vault" "keyvault" {
  name                = var.keyvault_name
  resource_group_name = var.keyvault_resourcegroup_name
}

variable "storage_account_name" {
  default = "default"
}

variable "container_name" {
  default = "default"
}

variable "key" {
  default = "default"
}

variable "access_key" {
  default = "default"
}

module "certificate-services" {
  source         = "../../modules/certificate-services"
  rg_name        = var.rg_name
  keyvault_name  = var.keyvault_name
  environment    = var.environment
  keyvault_uri   = data.azurerm_key_vault.keyvault.id
  prefix         = var.prefix
  vnet_rg        = var.vnet_rg
  mgmt_vnet      = var.management_vnet
  mgmt_subnet    = var.management_subnet
  public_ip_name = var.public_ip_name
}

module "domain-controllers" {
  source        = "../../modules/domain-controllers"
  rg_name       = var.rg_name
  keyvault_name = var.keyvault_name
  environment   = var.environment
  keyvault_uri  = data.azurerm_key_vault.keyvault.id
  prefix        = var.prefix
  vnet_rg       = var.vnet_rg
  mgmt_vnet     = var.management_vnet
  mgmt_subnet   = var.management_subnet
  av_set        = var.availability_set
}

module "automation_account" {
  source             = "../../modules/automation-account"
  rg_name            = var.rg_name
  automation_account = var.automation_account
  automation_module  = var.azurerm_automation_module
  environment        = var.environment
  keyvault_uri       = data.azurerm_key_vault.keyvault.id
}

# The following is not required when adding to an existing vNET #
/* module "vnets" {
    source = "../../modules/vnets"
    rg_name = var.rg_name
    keyvault_name = var.keyvault_name
    cert_service_address_space = var.vnet-cert-service-address-prefix
    keyvault_uri = data.azurerm_key_vault.keyvault.id
    prefix = var.prefix
} */