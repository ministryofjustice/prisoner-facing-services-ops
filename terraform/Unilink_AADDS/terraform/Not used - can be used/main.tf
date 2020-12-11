#terraform apply -target azurerm_resource_group.pfs-rg
#terraform apply -target module.vm
#terraform apply --auto-approve


terraform {
  backend "azurerm" {
    storage_account_name = "pfsprodbesa"              #
    container_name       = "pfs-state"                #
    key                  = "pfs_unilink_core.tfsprod" #
  }
}

provider "azurerm" {
  # whilst the `version` attribute is optional, recommend pinning to a given version of the Provider
  version = "2.0.0"
  features {}
}
resource "azurerm_resource_group" "pfs-rg" { ##Must be updated
  name     = "${var.rg-name}"
  location = "${var.location}"
}

##########################################################
## Create VM
####################################### ###################
module "vm" {
  source               = ".\\workgroup\\vm"
  vm-count             = "${var.vm-count}"
  location             = "${var.location}"
  usage                = "${var.usage}"
  rg-name              = "${var.rg-name}"
  env                  = "${var.env}"
  environment          = "${var.environment}"
  prefix               = "${var.prefix}"
  existing-subnet-name = "${var.existing-subnet-name}"
  existing-vnet-name   = "${var.existing-vnet-name}"
  network-rg           = "${var.network-rg}"
  ipallocation         = "${var.ipallocation}"
  sku                  = "${var.sku}"
  manageddisktype      = "${var.manageddisktype}"
  disk_size_gb         = "${var.disk_size_gb}"
  vm_size              = "${var.vm_size}"
  private_ip_address   = "${var.private_ip_address}"
  workgroup_pass       = "${var.workgroup_password}"
  workgroup_user       = "${var.workgroup_user}"
}

module "azure_lb" {
  source               = ".\\azure_lb"
  existing-subnet-name = "${var.existing-subnet-name}"
  existing-vnet-name   = "${var.existing-vnet-name}"
  network-rg           = "${var.network-rg}"
  location             = "${var.location}"
  rg-name              = "${var.rg-name}"
  nic_id               = "${module.vm.azurerm_network_interface}"
}



module "storage" {
  source   = ".\\storage"
  location = "${var.location}"
  rg-name  = "${var.rg-name}"
  ips      = "${var.ips}"
  subnets  = "${var.subnets}"
}

