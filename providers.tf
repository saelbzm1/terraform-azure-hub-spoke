terraform {
  required_version = ">=1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstate062727"
    container_name       = "tfstate"
    key                  = "terraform-final.tfstate"
  }
}

provider "azurerm" {
  features {}
}