variable "rg_name" {
  type    = string
  default = "default"
}

variable "environment" {
  default = "environment"
}


variable "prefix" {
  default = "pfs-cs-"
}

variable "username" {
  type    = string
  default = "pfs-cs-vm-username"
}
variable "keyvault_name" {
  default = "defaultkeyvaultname"
}

variable "keyvault_uri" {
  default = "defaultkeyvaulturi"
}

variable "av_set" {
  default = "defaultas"
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
variable "dc-1-AV" {
  default = "AVExtension"
}
