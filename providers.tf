terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.64.0"
    }
  }

  cloud {
    organization = "give-back-cincinnati"

    workspaces {
      name = "gbc-infra"
    }
  }

}