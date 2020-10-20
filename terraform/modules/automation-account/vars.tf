variable "rg_name" {
  type    = string
  default = "default"
}

variable "environment" {
  default = "environment"
}

variable "automation_account" {
  default = "dsc-aa"
}

variable "automation_module" {
  default = "dsc-aa-module"
}

variable "keyvault_name" {
  default = "defaultkeyvaultname"
}

variable "keyvault_uri" {
  default = "defaultkeyvaulturi"
}