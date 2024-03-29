#terraform apply -target azurerm_resource_group.pfs-rg
#terraform apply -target module.vm
#terraform apply -target module.azure_lb
#terraform apply --auto-approve

#terraform destroy 
terraform {
  backend "azurerm" {
    storage_account_name = "pfsterraformstate"                 #
    container_name       = "prod"                              #
    key                  = "pfs_unilink_core_azure_ad.tfsprod" #
  }
}

provider "azurerm" {
  # whilst the `version` attribute is optional, recommend pinning to a given version of the Provider
  version = "2.0.0"
  features {
  }
}



##########################################################
## Create VM
####################################### ###################
module "vm" {
  source               = "..\\workgroup\\vm"
  vm-count             = var.vm-count
  location             = var.location
  usage                = var.usage
  rg-name              = var.rg-name
  env                  = var.env
  environment          = var.environment
  prefix               = var.prefix
  existing-subnet-name = var.existing-subnet-name
  existing-vnet-name   = var.existing-vnet-name
  network-rg           = var.network-rg
  ipallocation         = var.ipallocation
  sku                  = var.sku
  manageddisktype      = var.manageddisktype
  disk_size_gb         = var.disk_size_gb
  vm_size              = var.vm_size
  private_ip_address   = var.private_ip_address
  workgroup_pass       = var.workgroup_password
  workgroup_user       = var.workgroup_user
  domain_to_join       = var.domain_to_join
  domain_join_password = var.domain_join_password # Not used, but passed
  domain_join_username = var.domain_join_username # Not used, but passed
  internal-dns-name    = var.internal-dns-name
  prison               = var.prison
  avs                  = var.avs
  dns_servers          = var.dns_servers
}

module "azure_lb" {
  source               = "..\\azure_lb"
  lb-name              = var.lb-name
  lb-private-ip        = var.lb-private-ip
  existing-subnet-name = var.existing-subnet-name
  existing-vnet-name   = var.existing-vnet-name
  network-rg           = var.network-rg
  location             = var.location
  rg-name              = var.rg-name
  nic_id               = module.vm.azurerm_network_interface
  private-ip-name      = var.private-ip-name
}


/*
module "storage" {
  source   = "..\\storage"
  location = var.location
  rg-name  = var.rg-name
  ips      = var.ips
  subnets  = var.subnets
}

*/