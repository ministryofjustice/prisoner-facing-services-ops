#Define variables

variable "vm-count" {
  default = "2"
}

variable "env" {
  default = "prod"
}

variable "usage" {
  default = "ul-ws"
}

variable "environment" {
  type        = string
  description = "tag for env"
  default     = "prod"
}

variable "rg-name" {
  type        = string
  description = "resource group name"
  default     = "pfs-unlink-core-rg"
}

variable "vm_size" {
  type        = string
  description = "size of the vm from t-shirts in Azure"
  default     = "Standard_DS2_v2"
}

variable "prefix" {
  default = "pfs-prd"
}

variable "location" {
  default = "UK South"
}

variable "existing-subnet-name" {
  default = "pfs-prod-web-sn"
}

variable "existing-vnet-name" {
  default = "pfs-prod-core-vn"
}

variable "network-rg" {
  default = "pfs-prod-core-rg"
}

variable "ipallocation" {
  default = "static"
}

variable "bootdiagstorage" {
  default = "bootdiagstorageact"
}

variable "recovery_vault_name" {
  description = "recovery_vault_name"
  default     = "prisoner-ops-vault"
}

variable "manageddisktype" {
  description = "type of disk, premium or standard - ssd or hdd"
  default     = "Premium_LRS"
}

variable "disk_size_gb" {
  description = "Size of managed disk"
  default     = "256"
}

variable "sku" {
  description = "The sku for the NIC"
  default     = "Standard"
}

variable "workgroup_user" {
  description = "workgroup username"
  default     = "unilink-local-admin"
}

variable "workgroup_password" {
  description = "The default wg password"
  default     = "unilink-admin-pass"
}

variable "private_ip_address" {
  type = map(string)
  default = {
    "1" = "10.42.1.108"
    "2" = "10.42.1.109"
  }
}

variable "subnets" {
  type = list(string)
  default = [
    "/subscriptions/340944f4-b60c-46ba-9377-5668bba83ecd/resourceGroups/pfs-prod-core-rg/providers/Microsoft.Network/virtualNetworks/pfs-prod-core-vn/subnets/pfs-prod-app-sn",
    "/subscriptions/340944f4-b60c-46ba-9377-5668bba83ecd/resourceGroups/pfs-prod-core-rg/providers/Microsoft.Network/virtualNetworks/pfs-prod-core-vn/subnets/pfs-prod-web-sn",
    "/subscriptions/340944f4-b60c-46ba-9377-5668bba83ecd/resourceGroups/pfs-stage-core-rg/providers/Microsoft.Network/virtualNetworks/pfs-stage-core-vn/subnets/pfs-stage-web-sn",
    "/subscriptions/340944f4-b60c-46ba-9377-5668bba83ecd/resourceGroups/pfs-stage-core-rg/providers/Microsoft.Network/virtualNetworks/pfs-stage-core-vn/subnets/pfs-stage-data-sn",
    "/subscriptions/340944f4-b60c-46ba-9377-5668bba83ecd/resourceGroups/pfs-stage-core-rg/providers/Microsoft.Network/virtualNetworks/pfs-stage-core-vn/subnets/pfs-stage-app-sn",
    "/subscriptions/340944f4-b60c-46ba-9377-5668bba83ecd/resourceGroups/pfs-dev-core-rg/providers/Microsoft.Network/virtualNetworks/pfs-dev-core-vn/subnets/pfs-dev-web-sn",
    "/subscriptions/340944f4-b60c-46ba-9377-5668bba83ecd/resourceGroups/pfs-dev-core-rg/providers/Microsoft.Network/virtualNetworks/pfs-dev-core-vn/subnets/pfs-dev-data-sn",
    "/subscriptions/340944f4-b60c-46ba-9377-5668bba83ecd/resourceGroups/pfs-dev-core-rg/providers/Microsoft.Network/virtualNetworks/pfs-dev-core-vn/subnets/pfs-dev-app-sn",
  ]
}

variable "domain_join_username" {
  default = "aadds-joindomain-username"
}

variable "domain_join_password" {
  default = "aadds-joindomain-pass"
}

variable "domain_to_join" {
  default = "identity.prisoner.service.justice.gov.uk "
}



variable "internal-dns-name" {
  type = map(string)
  default = {
    "1" = "pfspulwsaadds1"
    "2" = "pfspulwsaadds2"

  }
}

variable "prison" {
  type = map(string)
  default = {
    "1" = "aadds - Unilink Web Server 1 - Kiosk"
    "2" = "aadds - Unilink Web Server 2 - Kiosk"
  }
}

variable "lb-name" {
  default = "pfs-lb-web-ul-adds"
}

variable "lb-private-ip" {
  default = "10.42.1.107"
}

variable "private-ip-name" {
  default = "FE-aadds-Private-IP"
}

variable "avs" {
  default = "aadds-ul-avs"
}

variable "dns_servers" {

  type = list(string)
  default = [ "10.42.4.4",
            "10.42.4.5"]
}
