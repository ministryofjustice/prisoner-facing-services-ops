

#Define variables


variable "location" {
  default = "UK South"
}


variable "rg-name" {
  type        = string
  description = "resource group name"
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

variable "nic_id" {

}


variable "lb-name" {

}

variable "lb-private-ip" {

}

variable "private-ip-name" {

}
