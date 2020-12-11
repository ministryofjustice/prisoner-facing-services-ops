#Define variables

variable "vm-count" {
  default = "3"
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
    "1" = "10.42.1.104"
    "2" = "10.42.1.105"
  }
}

variable "ips" {
  type    = list(string)
  default = ["217.33.148.210", "81.134.202.29", "78.33.10.50"]
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
  default = "wli-domain-admin"
}

variable "domain_join_password" {
  default = "wli-domain-join-pass"
}

variable "domain-to-join" {
  default = "wli.dpn.gov.uk"
}

variable "internal-dns-name" {
  type = map(string)
  default = {
    "1" = "pfspulwswli1"
    "2" = "pfspulwswli2"
    "3" = "pfspulapiwli1"
  }
}

variable "prison" {
  type = map(string)
  default = {
    "1" = "Wayland - Unilink Web Server 1 - Kiosk"
    "2" = "Wayland - Unilink Web Server 2 - Kiosk"
    "3" = "Wayland - Unilink API Server 1 - API"
  }
}

variable "lb-name" {
  default = "Unilink-web-lb-wli"
}

variable "lb-private-ip" {
  default = "10.42.1.106"
}

variable "private-ip-name" {
  default = "FE-WLI-Private-IP"
}

variable "avs" {
  default = "wli-ul-avs"
}

variable "containers" {
  type = map(string)
  default = {
    "1"  = "bt-pin-phone-interface"
    "2"  = "cms-executables"
    "3"  = "emap-service"
    "4"  = "interface-services"
    "5"  = "interface-web-service"
    "6"  = "nominal-kiosk-executables"
    "7"  = "nominal-kiosk-web-service"
    "8"  = "utility-kiosk-executables"
    "9"  = "utility-kiosk-web-service"
    "10" = "web-ss-api"
    "11" = "web-ss-client"
  }
}

variable "asg_rg" {
  default = "pfs-prod-core-rg"
}

variable "asg" {
  default = "pfs-ul-ws-wli"
}

variable "dns_servers" {

  type = list(string)
  default = [ "10.42.1.4",
            "10.42.1.5",
            "10.52.94.67",
            "10.52.94.68"]
}
