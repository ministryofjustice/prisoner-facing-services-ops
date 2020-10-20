
variable "storage_name" { 
  default = "pfsterraformstate"
}


variable "location" {
    default = "uk south"
}

variable "rg-name" {
    default = "prisoner-facing-tfstate"
}

##tags

variable "usage" {
  default = "terraform_state"
}

variable "environment" {
  default = "prod"
}

variable "rg-count"{
    default = 1
}

variable "containers" {
  type = map(string)
  default = {
    "1"  = "prod"
    "2"  = "stage"
    "3"  = "dev"

  }
}