terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.0,<5.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">=3.0,<4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.0,<4.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.0,<2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "databricks" {
  alias               = "accounts"
  host                = "https://accounts.azuredatabricks.net"
  account_id          = var.DATABRICKS_ACCOUNT_ID
  azure_client_id     = var.ARM_CLIENT_ID
  azure_client_secret = var.ARM_CLIENT_SECRET
  azure_tenant_id     = var.ARM_TENANT_ID
}

provider "databricks" {
  alias               = "workspace"
  host                = azurerm_databricks_workspace.ws_adb.workspace_url
  azure_client_id     = var.ARM_CLIENT_ID
  azure_client_secret = var.ARM_CLIENT_SECRET
  azure_tenant_id     = var.ARM_TENANT_ID
}
