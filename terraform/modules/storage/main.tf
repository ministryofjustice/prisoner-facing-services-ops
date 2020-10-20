

###
resource "azurerm_storage_account" "storage-acct" {
  name                      = var.storage_name
  resource_group_name       = var.rg-name
  location                  = var.location
  account_tier              = "standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  enable_https_traffic_only = true
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    environment = var.environment
    creation = "terraform"
    usage = var.usage
  }
}

resource "azurerm_storage_container" "containers" {
  for_each              = var.containers
  name                  = each.value
  storage_account_name  = azurerm_storage_account.storage-acct.name
  container_access_type = "private"
}