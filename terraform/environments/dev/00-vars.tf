variable "environment" {
  type    = string
  default = "dev"
}

variable "prefix" {
  type    = string
  default = "pfs"
}

variable "rg_name" {
  type    = string
  default = "pfs"
}

variable "vnet-cert-service-address-prefix" {
  default = "10.0.0.0/16"
}

variable "keyvault_name" {
  default = "prisoner-ops-vault"
}

variable "keyvault_resourcegroup_name" {
  default = "prisoner-facing-ops-vault"
}

variable "management_vnet" {
  default = "pfs-dev-core-vn"
}

variable "management_subnet" {
  default = "pfs-dev-management-sn"
}

variable "vnet_rg" {
  default = "pfs-dev-core-rg"
}

variable "availability_set" {
  default = "pfs-cs-dc-as-dev"
}

variable "automation_account" {
  default = "dsc-aa"
}

variable "azurerm_automation_module" {
  default = "DSCAutomationModule"
}
