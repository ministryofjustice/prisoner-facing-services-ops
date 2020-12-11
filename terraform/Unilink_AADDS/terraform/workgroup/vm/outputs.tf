

output "azurerm_network_interface" {
  value = azurerm_network_interface.primary[*].id
}
