# pfs-unilink-infrastructure

Templates are for future usage, they are not used in the deployment

How to run this TF build

#terraform apply -target azurerm_resource_group.pfs-rg
#terraform apply -target module.vm
#terraform apply --auto-approve

#terraform apply -target azurerm_resource_group.pfs-rg
#terraform apply -target module.vm
#terraform apply --auto-approve

terraform apply -target module.azure_lb --auto-approve
terraform apply  -target module.vm --auto-approve     
terraform destroy -target module.vm                   
terraform destroy -target module.vm.azurerm_network_interface.primary
terraform destroy -target module.vm.azurerm_virtual_machine.vm

