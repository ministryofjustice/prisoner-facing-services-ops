Write-host "choose an environment: sandpit, pfsdev, pfsstage, pfsprod, pfsnetwork, pfsad"

$environment = Read-Host -Prompt 'What environment'


If ($environment -eq ("sandpit"))
{


$ENV:ARM_SUBSCRIPTION_ID = "Add"
$ENV:ARM_CLIENT_ID       = "Add"
$ENV:ARM_CLIENT_SECRET   = "Add" # 
$ENV:ARM_TENANT_ID       = "Add"#
$env:ARM_ACCESS_KEY      = "Add" # This needs to go into vault and be called through az  $env:ARM_ACCESS_KEY=(az keyvault secret show --name secret_name --vault-name yourKeyvault_name --query value -o tsv)

}

elseif ($environment -eq ("pfsdev"))
{ 



$env:ARM_ACCESS_KEY      = "Add" 


}

elseif ($environment -eq ("pfsstage"))
{ 


$env:ARM_ACCESS_KEY      = "Add" 

}

elseif ($environment -eq ("pfsprod"))
{ 


$ENV:ARM_TENANT_ID       = "Add"
$env:ARM_ACCESS_KEY      = "Add" 

}

elseif ($environment -eq ("pfsnetwork"))

{

$env:ARM_ACCESS_KEY     = "Add"

}

elseif ($environment -eq ("pfsad"))

{

$env:ARM_ACCESS_KEY     = "Add"

}







