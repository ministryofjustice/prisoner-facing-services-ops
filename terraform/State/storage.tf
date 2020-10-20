

terraform {

  backend "azurerm" {
    resource_group_name  = "prisoner-facing-tfstate"
    storage_account_name = "pfsterraformstate"
    container_name       = "prod"
    key                  = "prisoner-facing-ops.tfstate"
  }
}

module "resource-group" {
  source      = "..\\modules\\resource_groups"
  rg-count    = var.rg-count
  rg-name     = var.rg-name
  usage       = var.usage
  location    = var.location
  environment = var.environment 
}

module "storage" {
  source       = "..\\modules\\storage"
  storage_name = var.storage_name
  location     = var.location
  rg-name      = var.rg-name
  usage        = var.usage
  environment  = var.environment
  containers  =  var.containers

}
