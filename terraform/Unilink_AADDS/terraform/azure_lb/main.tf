provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "2.0.0"
  features {}
}


data "azurerm_subnet" "core" {
  name                 = var.existing-subnet-name
  virtual_network_name = var.existing-vnet-name
  resource_group_name  = var.network-rg
}


resource "azurerm_lb" "ulweb" {
  name                = var.lb-name
  location            = var.location
  resource_group_name = var.rg-name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = var.private-ip-name
    private_ip_address_allocation = "static"
    private_ip_address            = var.lb-private-ip
    subnet_id                     = data.azurerm_subnet.core.id
  }
}

resource "azurerm_lb_backend_address_pool" "ulweb_backend" {
  resource_group_name = azurerm_lb.ulweb.resource_group_name
  loadbalancer_id     = azurerm_lb.ulweb.id
  name                = "BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "ulweb_be_asso" {
  for_each                = toset(var.nic_id)
  network_interface_id    = each.value
  ip_configuration_name   = "primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ulweb_backend.id
}




resource "azurerm_lb_probe" "port_80" {
  resource_group_name = azurerm_lb.ulweb.resource_group_name
  loadbalancer_id     = azurerm_lb.ulweb.id
  name                = "port-443"
  port                = 443
}

resource "azurerm_lb_rule" "unilink-web-rule" {
  resource_group_name            = azurerm_lb.ulweb.resource_group_name
  loadbalancer_id                = azurerm_lb.ulweb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = var.private-ip-name
  probe_id                       = azurerm_lb_probe.port_80.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.ulweb_backend.id
  load_distribution              = "SourceIPProtocol"
  idle_timeout_in_minutes        = 30
}


/*

check dns config tomorrow is working
Ask why this is 80 dp_pfs_load_balancer_integration
http://10.43.210.5/CMSInterfacePnomisWS/CMSInterfacePNomisWS.asmx allowed through


*/