terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Configuración parcial: el pipeline pasa RG, storage account, container y key
  backend "azurerm" {
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}
  # subscription_id se toma de ARM_SUBSCRIPTION_ID
  resource_provider_registrations = "none" # los providers se registran en bootstrap.sh
}
