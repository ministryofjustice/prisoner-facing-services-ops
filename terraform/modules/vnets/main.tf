resource "azurerm_resource_group" "main" {
  name     = "${var.rg_name}-vnet-${var.environment}"
  location = "UK South"
}

resource "azurerm_virtual_network" "vnet-cert-services" {
  name                = "pfs-test-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.cert_service_address_space]

  subnet {
    name           = "default"
    address_prefix = "10.0.1.0/24"
  }

  tags = {
    environment = var.environment
  }
}