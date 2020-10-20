##Azure container registry
variable "vault-name" {
  default = "prisoner-ops-vault"

}
variable "ips" {

  default = ["217.33.148.210/32", "81.134.202.29/32", "62.254.63.52/32", "62.254.63.50/32"]
}



variable "location" {
  default = "uk south"
}

variable "rg-name" {
  default = "prisoner-facing-ops-vault"
}

##tags

variable "usage" {
  default = "vault-secrets"
}

variable "environment" {
  default = "prod"
}

variable "rg-count" {
  default = 1
}


variable "dev_subnets" {
  default = ["pfs-dev-app-sn", "pfs-dev-data-sn", "pfs-dev-management-sn", "pfs-dev-web-sn"]
}


variable "stage_subnets" {
  default = ["pfs-stage-app-sn", "pfs-stage-web-sn", "pfs-stage-data-sn", "pfs-stage-management-sn"]
}

variable "prodacc_subnets" {
  default = ["pfs-prod-vm-sn", "pfs-prod-spare-sn"]
}


variable "prod_subnets" {
  default = ["pfs-prod-app-sn", "pfs-prod-management-sn", "pfs-prod-web-sn", "pfs-prod-data-sn"]
}


variable "rg_name" {
  description = "Specifies the Resource Group where the resource should exist"
  default     = "prisoner-facing-ops-vault"
}

variable "keyvault_name" {
  type    = string
  default = "prisoner-ops-vault"
}

#### vault permissions
#https://docs.microsoft.com/en-us/azure/healthcare-apis/find-identity-object-ids - or Use Azure AD GUI, I find that far easier
variable "admin_objectid_list" {
  type        = list(string)
  description = "List of Admin user email addresses."
  default     = ["0826935c-631b-4505-a299-7dda44a95c4e", "262044b1-e2ce-469f-a196-69ab7ada62d3"]
}

variable "keyvault_admin_key_permissions" {
  type    = list(string)
  default = ["backup", "create", "decrypt", "delete", "encrypt", "get", "import", "list", "purge", "recover", "restore", "sign", "unwrapKey", "update", "verify", "wrapKey"]
}

variable "keyvault_admin_secret_permissions" {
  type    = list(string)
  default = ["backup", "delete", "get", "list", "purge", "recover", "restore", "set"]
}

variable "keyvault_admin_cert_permissions" {
  type    = list(string)
  default = ["backup", "create", "delete", "deleteissuers", "get", "getissuers", "import", "list", "listissuers", "managecontacts", "manageissuers", "purge", "recover", "restore", "setissuers", "update"]
}

variable "keyvault_admin_storage_permissions" {
  description = "description"
  default     = ["backup", "delete", "get", "list", "purge", "recover", "restore", "set"]


}