variable "prefix" {
  description = "Team name"
  type        = string
  default     = "tname"
}

variable "name" {
  description = "Project name"
  type        = string
  default     = "myproje"
}

variable "region_shortname" {
  type    = string
  default = "EUC1"
}

variable "costcenter" {
  type    = string
  default = "dummyXYZ"
}

variable "environment" {
  type    = string
  default = "env"
}

variable "terraform_remote_state_bucket" {
  type    = string
  default = "terraform-myproje-euc1-dev"
}