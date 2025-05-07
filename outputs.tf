output "resource_group_name" {
  value = azurerm_resource_group.rg_adb.name
}

output "databricks_host" {
  value = "https://${azurerm_databricks_workspace.ws_adb.workspace_url}"

}
