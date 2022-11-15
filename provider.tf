terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.33.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.29.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.22.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.0.0"
    }
  }
  backend "s3" {
    bucket = "tname-myproje-terraform-dev-euc1"
    key    = "enterprise-eks/terraform.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "azuread" {
  # Configuration options
}

provider "azapi" {
  # Configuration options
}