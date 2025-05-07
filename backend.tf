terraform {
  backend "azurerm" {
    resource_group_name  = "rg-dev-terraform"
    storage_account_name = "slvstoragedevterraform"
    container_name       = "tfstate"
    key                  = "dev-terraform-project.terraform.tfstate"
  }
}
