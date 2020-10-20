### This function is to set the environment variables for Terraform Backend ###

function Set-TFBackend {
    param (
        [Parameter(Mandatory=$true)][string] $env, 
        [Parameter(Mandatory=$true)][string] $keyvault, 
        [Parameter(Mandatory=$false)][boolean] $init,
        [Parameter(Mandatory=$false)][boolean] $plan
    )

    Write-host "Present working directory: "$pwd

    if ( $pwd -notlike "*/environments/master" ) { # Checking that pwd is correct
        write-host "Please change to environments/master"
    }elseif ( $env -And $keyvault ){ # Ensuring that values have been set for the Mandatory Parameters
        
        "Presenting working directory is correct."
    
        Write-host "Obtaining storage details secrets from KeyVault: "$keyvault

        # Assigning Environment variables, some of which are obtained from keyvault, in order to securely run Terraform init, 
        # Terraform plan and Terraform apply, etc
        # This is to securely set the backend settings for state file which uses an Access Key associate with a Storage Account 

        try {

            $ENV:access_key=(az keyvault secret show --vault-name prisoner-ops-vault --name tfstateaccesskey --query value --output tsv)
            $ENV:key="00-$env.terraform.tfstate"
            $ENV:storage_account_name=(az keyvault secret show --vault-name prisoner-ops-vault --name tfstatestorageaccountname --query value --output tsv)
            $ENV:container_name="$env"

            Write-host ">access_key: $ENV:access_key"
            Write-host ">key: $ENV:key"
            Write-host ">storage_account_name: $ENV:storage_account_name"
            Write-host ">container_name: $ENV:container_name"

        } catch {
            Write-host $_.ScriptStackTrace;
        }

        # Linking to environment variables
        Write-host "Creating symlink to variables for $env environment...";

        if (Test-Path "./00-vars.tf") { # If a symlink exists, remove it
            Write-host "Remove existing symlink"
            unlink "./00-vars.tf"
        }
        
        Write-host "Creating symlink to ./$env/00-vars.tf"
        ln -s "../$env/00-vars.tf"

    }else { # Notify that Mandatory parameters have not been supplied
        Write-Host "Please provide both Environment (dev or prod); and, Keyvault name in the form of 'Set-tf -env your_env -keyvault your_keyvault_name'"
        exit;
    }

    # If true, run Terraform init with the context of the backend configuration obtained above
    if ($init) {

        terraform init -backend-config="access_key=$ENV:access_key" -backend-config="storage_account_name=$ENV:storage_account_name" -backend-config="key=$ENV:key" -backend-config=“container_name=$ENV:container_name”
    
    }

    # If true, run Terraform plan with the context of the backend configuration obtained above
    if ($plan) {

        terraform plan -var="access_key=$ENV:access_key,key=$ENV:key,storage_account_name=$ENV:storage_account_name,container_name=$ENV:container_name"

    }

}
