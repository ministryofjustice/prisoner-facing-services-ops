variable "environment" {
  type    = string
  default = "prod"
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
  default = "pfs-prod-core-vn"
}

variable "management_subnet" {
  default = "pfs-prod-management-sn"
}

variable "vnet_rg" {
  default = "pfs-prod-core-rg"
}

variable "availability_set" {
  default = "pfs-cs-dc-as-prod"
}

variable "public_ip_name" {
  default = "pfs-certservices-prod-vm-1"
}

variable "automation_account" {
  default = "DSCAutomation"
}

variable "azurerm_automation_module" {
  default = "DSCAutomationModule"
}

variable "azurerm_virtual_machine_extension" {
  default = "AVExtension"
}
