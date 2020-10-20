## The Backend Configuration ##

This implementation of Terraform uses a backend state file stored in a secure location on an Azure Storage Account, using an access key.

Rather than stating the access details to this location inline, a set of environment variables should be defined and passed through the initialisation, plan and apply stages.

### Setting-Up Backend - with Set-TFBackend module ###

* Import the Module
> Import-Module ./Set-TFBackend.psm1

* Run the setup.  Syntax is as follows: Set-TFBackend -env *your_environment* -keyvault *your_keyvault_name* -init $boolean -plan $boolean
> Set-TFBackend -env dev -keyvault markpatton-cloud-keyvault -init $true -plan $true

The parameters ```init``` and ```plan``` are optional but, when $true, they run the respective terraform init and plan commands automatically with the appropriately obtained environment variables.

Note:
1. in order to preserve the integrity of the script, it will require you to have your working directory as ```../environments/master```.  Also, ensure that the backend container, for the respective environment exists on the storage account, and that the appropriate ```00-vars.tf``` exists in the repo under the respective environment heading e.g. dev, prod.5
2. If, when running ```terraform init```, you are asked **"Do you want to copy existing state to the new backend?"** it is important that you choose **No**.

### Obtaining Environment Variables, with Set-TFBackend ###
Part of the mandatory tasks of the module is to obtain and assign environment variables with can be used when intialising, planning, etc the terraform state.  It assigns the environment variables as follows:

``` powershell
$ENV:access_key=(az keyvault secret show --vault-name $keyvault> --name tfstateaccesskey --query value --output tsv) 

$ENV:key=(az keyvault secret show --vault-name $keyvault --name tfstatefile --query value --output tsv)

$ENV:storage_account_name=(az keyvault secret show --vault-name $keyvault --name tfstatestorageaccountname --query value --output tsv)
```

**Note that the state.tf file has been assigned default values** rather than including the sensitive credentials inline:

```terraform
terraform {
  backend "azurerm" {
    storage_account_name = "default"
    container_name       = "default"
    key                  = "default"
    access_key           = "default"
  }
}
```

### Module Reference ###
In order to connect to the backend state file, via the variables in the ***Backend*** block, they have to be declared in the root module.  In this case, you will find these referenced in the ***main.tf*** located at:
> environments/master


```terraform
variable "storage_account_name" {
    default = "default"
}

variable "container_name" {
    default = "default"
}

variable "key" {
    default = "default"
}

variable "access_key" {
    default = "default"
}
```

### Terraform - Initialising with Environment Variables ###

In order to initialise the backend, in addition to the modules and the provider plugins, the following command needs to be run by passing the Environment variables:
```powershell
terraform init -backend-config="access_key=$ENV:access_key" -backend-config="storage_account_name=$ENV:storage_account_name" -backend-config="key=$ENV:key" -backend-config=“$ENV:container_name”
 ```

### Terraform - Running a plan or apply with Environment Variables ###

```powershell
terraform plan -var="access_key=$ENV:access_key,key=$ENV:key,storage_account_name=$ENV:storage_account_name,container_name=$ENV:container_name"
```