variable "rg_name" {
  type    = string
  default = "default"
}

variable "environment" {
  default = "environment"
}

variable "prefix" {
  default = "defaultprefix"
}

variable "keyvault_name" {
  default = "defaultkeyvaultname"
}

variable "keyvault_uri" {
  default = "defaultkeyvaulturi"
}

variable "vnet_rg" {
  default = "defaultvnetrg"
}

variable "mgmt_vnet" {
  default = "defaultmgmtvnet"
}

variable "mgmt_subnet" {
  default = "defaultmgmtsubnet"
}

variable "public_ip_name" {
  default = "defaultpublicip"
}