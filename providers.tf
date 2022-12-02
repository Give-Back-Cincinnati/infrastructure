terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.64.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "4.20.1"
    }
  }

  cloud {
    organization = "give-back-cincinnati"

    workspaces {
      name = "gbc-infra"
    }
  }

}