resource "azurerm_resource_group" "resource_group" {
  count    = var.rg-count 
  name     = var.rg-name
  location = var.location
    tags = {
    environment = var.environment
    creation = "terraform"
    usage = var.usage
  }
}