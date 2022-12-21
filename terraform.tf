terraform {
  required_version = ">= 1.3.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.36.0"
    }
  }

  cloud {
    organization = "tebriel"
    workspaces {
      name = "chat.pindropt.fail"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {}
}
