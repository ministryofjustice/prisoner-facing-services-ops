
# PFS Terraform

The Terraform here is designed for Azure Dev Ops usage. But can be run locally as well. The wrapper is `Powershell` based (at the moment)


#### Folders & Files

| Folder | Purpose |
|---------------------|----------------------|
| /modules         | terraform module housing
| /State           | state / azure storage for terraform state |


`cmd list /modules/azure_ad`

`terraform init`
`terraform plan --var-file=users.tfvars`

`terraform apply --var-file=users.tfvars`

`terraform destroy --var-file=users.tfvars`

### State

`terraform init`
`terraform plan`

`terraform apply`

`terraform destroy`