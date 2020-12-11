provider "azurerm" {
  # whilst the `version` attribute is optional, recommend pinning to a given version of the Provider
  version = "2.0.0"
  features {}
}
###Prod
data "azurerm_subnet" "prod-data-sn" {
  name                 = "pfs-prod-data-sn"
  virtual_network_name = "pfs-prod-core-vn"
  resource_group_name  = "pfs-prod-core-rg"
}

output "subnet_id_prod_data" {
  value = "${data.azurerm_subnet.prod-data-sn.id}"

}


data "azurerm_subnet" "prod-web-sn" {
  name                 = "pfs-prod-web-sn"
  virtual_network_name = "pfs-prod-core-vn"
  resource_group_name  = "pfs-prod-core-rg"
}

output "subnet_id_prod_web" {
  value = "${data.azurerm_subnet.prod-web-sn.id}"

}


data "azurerm_subnet" "prod-app-sn" {
  name                 = "pfs-prod-app-sn"
  virtual_network_name = "pfs-prod-core-vn"
  resource_group_name  = "pfs-prod-core-rg"
}

output "subnet_id_prod_app" {
  value = "${data.azurerm_subnet.prod-app-sn.id}"

}





####Stage --- stage
data "azurerm_subnet" "stage-app-sn" {
  name                 = "pfs-stage-app-sn"
  virtual_network_name = "pfs-stage-core-vn"
  resource_group_name  = "pfs-stage-core-rg"
}

output "subnet_id_stage_app" {
  value = "${data.azurerm_subnet.stage-app-sn.id}"

}

data "azurerm_subnet" "stage-web-sn" {
  name                 = "pfs-stage-web-sn"
  virtual_network_name = "pfs-stage-core-vn"
  resource_group_name  = "pfs-stage-core-rg"
}

output "subnet_id_stage_web" {
  value = "${data.azurerm_subnet.stage-web-sn.id}"

}


data "azurerm_subnet" "stage-data-sn" {
  name                 = "pfs-stage-data-sn"
  virtual_network_name = "pfs-stage-core-vn"
  resource_group_name  = "pfs-stage-core-rg"
}

output "subnet_id_stage_data" {
  value = "${data.azurerm_subnet.stage-data-sn.id}"

}

####Dev

data "azurerm_subnet" "dev-app-sn" {
  name                 = "pfs-dev-app-sn"
  virtual_network_name = "pfs-dev-core-vn"
  resource_group_name  = "pfs-dev-core-rg"
}

output "subnet_id_dev_app" {
  value = "${data.azurerm_subnet.dev-app-sn.id}"

}

data "azurerm_subnet" "dev-web-sn" {
  name                 = "pfs-dev-web-sn"
  virtual_network_name = "pfs-dev-core-vn"
  resource_group_name  = "pfs-dev-core-rg"
}

output "subnet_id_dev_web" {
  value = "${data.azurerm_subnet.dev-web-sn.id}"

}


data "azurerm_subnet" "dev-data-sn" {
  name                 = "pfs-dev-data-sn"
  virtual_network_name = "pfs-dev-core-vn"
  resource_group_name  = "pfs-dev-core-rg"
}

output "subnet_id_dev_data" {
  value = "${data.azurerm_subnet.dev-data-sn.id}"

}


###
resource "azurerm_storage_account" "pfs-unilink-storage" {
  name                      = "pfsunilinkstorage"
  resource_group_name       = "${var.rg-name}"
  location                  = "${var.location}"
  account_tier              = "standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  enable_https_traffic_only = true
  lifecycle {
    prevent_destroy = false
  }
  tags = {
    environment = "prod"
  }

  network_rules {
    default_action             = "Deny"
    ip_rules                   = "${var.ips}"
    virtual_network_subnet_ids = "${var.subnets}"

  }
}

resource "azurerm_storage_container" "v35" {
  for_each              = var.containers
  name                  = each.value
  storage_account_name  = azurerm_storage_account.pfs-unilink-storage.name
  container_access_type = "private"
}