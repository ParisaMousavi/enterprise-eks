variable "prefix" {
  description = "Team name"
  type        = string
  default     = "tname"
}

variable "name" {
  description = "Project name"
  type        = string
  default     = "myproj"
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
  default = "tname-myproje-terraform-dev-euc1"
}

variable "connect_to_arc" {
  type    = bool
  default = false
}


variable "install_arc_flux" {
  type    = bool
  default = false
}

variable "install_arc_monitor" {
  type    = bool
  default = false
}

variable "install_arc_policy" {
  type    = bool
  default = false
}

variable "install_arc_custom_location" {
  type    = bool
  default = false
}

variable "install_arc_data_controller" {
  type    = bool
  default = false
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "az_location" {
  type    = string
  default = "westeurope"
}

variable "az_location_shortname" {
  type    = string
  default = "weu"
}

variable "az_subscription_id" {
  type = string
}
