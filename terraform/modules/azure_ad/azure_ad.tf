

terraform {

  backend "azurerm" {
    resource_group_name  = "prisoner-facing-tfstate"
    storage_account_name = "pfsterraformstate"
    container_name       = "prod"
    key                  = "azure_ad_prod.tfstate"
  }
}

resource "random_string" "password" {
  length = 16
  special = true
  override_special = "/@\" "  
}


data "azurerm_subscription" "primary" {
}

/*

Not used yet
resource "azuread_user" "user" {
  for_each              = var.prison_user
  display_name          = each.value["display_name"]
  password              = random_string.password.result
  user_principal_name   = each.value["user_principal_name"]
}
*/

##These values are captured from the portal or running 
## $userpn = Get-AzureADUser
## $userpn.userprincipalname



### I will find a better way of doing this, but at the moment limited as the API isn't supporting some functions
data "azuread_users" "users" {
  user_principal_names = ["AbdulWahid_nomsdigitechoutlook.onmicrosoft.com#EXT#@PrisonerIdentityServices.onmicrosoft.com", "agoney.garcia-deniz_nomsdigitechoutlook.onmicrosoft.co#EXT#@PrisonerIdentityServices.onmicrosoft.com",
"BillKennett_nomsdigitechoutlook.onmicrosoft.com#EXT#@PrisonerIdentityServices.onmicrosoft.com", "DominicRobinson_nomsdigitechoutlook.onmicrosoft.com#EXT#@PrisonerIdentityServices.onmicrosoft.com",
"EwaStempel_nomsdigitechoutlook.onmicrosoft.com#EXT#@PrisonerIdentityServices.onmicrosoft.com", "KarenMoss_nomsdigitechoutlook.onmicrosoft.com#EXT#@PrisonerIdentityServices.onmicrosoft.com",
"LibanMohamed_nomsdigitechoutlook.onmicrosoft.com#EXT#@PrisonerIdentityServices.onmicrosoft.com", "OrlandoCoombs_nomsdigitechoutlook.onmicrosoft.com#EXT#@PrisonerIdentityServices.onmicrosoft.com",
"RoyMorgan_nomsdigitechoutlook.onmicrosoft.com#EXT#@PrisonerIdentityServices.onmicrosoft.com", "SandhyaGandalwar_nomsdigitechoutlook.onmicrosoft.com#EXT#@PrisonerIdentityServices.onmicrosoft.com",
"VinitMehta_nomsdigitechoutlook.onmicrosoft.com#EXT#@PrisonerIdentityServices.onmicrosoft.com"

   ]
}


resource "azuread_group" "dso" {
  name    = "DSO"
  description = "Group for DSO users only"
}

resource "azuread_group_member" "dso" {
  for_each = toset(data.azuread_users.users.object_ids)
  group_object_id   = azuread_group.dso.id
  member_object_id  = each.value
}

data "azurerm_client_config" "example" {
}

resource "azurerm_role_assignment" "owner_role" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Owner"
  principal_id         = azuread_group.dso.id

}


