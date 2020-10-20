## Use this to do common stuff

## Get Tenant Id, Subscription Id, SPN Info
## https://www.terraform.io/docs/providers/azurerm/d/client_config.html
data "azurerm_client_config" "current" {
}

## Get Subscription Info
## https://www.terraform.io/docs/providers/azurerm/d/subscription.html
data "azurerm_subscription" "current" {
}


## Dev

data "azurerm_subnet" "dev_sns" {
  for_each             = toset(var.dev_subnets)
  name                 = each.value
  virtual_network_name = "pfs-dev-core-vn"
  resource_group_name  = "pfs-dev-core-rg"
}


###Stage
data "azurerm_subnet" "stage_sns" {
  for_each             = toset(var.stage_subnets)
  name                 = each.value
  virtual_network_name = "pfs-stage-core-vn"
  resource_group_name  = "pfs-stage-core-rg"
}


## Prod access

data "azurerm_subnet" "prodacc_sns" {
  for_each             = toset(var.prodacc_subnets)
  name                 = each.value
  virtual_network_name = "pfs-prod-access-vn"
  resource_group_name  = "pfs-prod-access-rg"
}


## Prod Core VN

data "azurerm_subnet" "prod_sns" {
  for_each             = toset(var.prod_subnets)
  name                 = each.value
  virtual_network_name = "pfs-prod-core-vn"
  resource_group_name  = "pfs-prod-core-rg"
}

data "azurerm_key_vault" "keyvault" {
  name                = var.keyvault_name
  resource_group_name = var.rg_name
}

