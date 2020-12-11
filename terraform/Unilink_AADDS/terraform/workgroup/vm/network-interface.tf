
resource "azurerm_network_interface" "primary" {
  name                    = format("%s-%s", lookup(var.internal-dns-name, count.index + 1, "Default"), "int")
  location                = var.location
  resource_group_name     = var.rg-name
  internal_dns_name_label = lookup(var.internal-dns-name, count.index + 1, "Default")
  count                   = var.vm-count

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.azurerm_subnet.core.id
    private_ip_address_allocation = "static"
    private_ip_address            = lookup(var.private_ip_address, count.index + 1, "Default")
  
  }
    dns_servers                   = var.dns_servers

}
