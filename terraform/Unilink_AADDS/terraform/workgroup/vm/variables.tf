

#Define variables
variable "env" {
  description = "env: dev or stage or prod"
}

variable "vm-count" {
  description = "How many VM's are required"
  type        = string
}

variable "environment" {
  type        = string
  description = "what the environment is"
}

variable "location" {
  default = "UK South"
}


variable "rg-name" {
  type        = string
  description = "resource group name"
}


variable "vm_size" {
  type        = string
  description = "size of the vm from t-shirts in Azure"
}

variable "prefix" {
  type        = string
  description = "prefix for environment"
}

variable "existing-subnet-name" {
  description = "name of the existing subnet"
  type        = string
}

variable "existing-vnet-name" {
  description = "name of existing vnet"
  type        = string
}

variable "network-rg" {
  description = "name of the existing network rg"
  type        = string
}


variable "ipallocation" {
  description = "Ip allocation range"
  type        = string
}


variable "manageddisktype" {
  description = "type of disk, premium or standard - ssd or hdd"
  type        = string
}

variable "disk_size_gb" {
  description = "Size of managed disk"
  type        = string
}


variable "sku" {}

variable "prison" {
  type = map
}

variable "usage" {

}

variable "recovery_vault_name" {
  description = "recovery_vault_name"
  default     = "prisoner-ops-vault"
}

variable "private_ip_address" {

}

variable "workgroup_pass" {
  type = string

}

variable "workgroup_user" {
  type = string
}



variable "domain_join_password" {

}

variable "domain_join_username" {

}
variable "domain_to_join" {

}

variable "internal-dns-name" {

}


variable "avs" {

}


variable "dns_servers" {

}
