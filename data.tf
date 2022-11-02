data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.terraform_remote_state_bucket
    key    = "enterprise-network/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "azuread_service_principal" "deployment_sp" {
  display_name = "technical-user-for-devops"
}

data "azuread_group" "aks_cluster_admin" {
  display_name     = "AKS Cluster Admin"
  security_enabled = true
}

data "aws_caller_identity" "current" {}

data "aws_iam_user" "paisa" {
  user_name = "parisam"
}
