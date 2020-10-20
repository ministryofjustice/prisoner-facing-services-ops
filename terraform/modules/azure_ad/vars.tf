
#defined, but not used yet
variable "prison_user" {
  type = map(object({
    display_name        = string
    user_principal_name = string
  }))
 }

