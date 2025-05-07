# 変数定義など
resource "random_id" "uid" {
  byte_length = 8
}

resource "random_password" "pw" {
  length  = 20
  special = true
}

resource "random_string" "str" {
  length      = 6
  numeric     = true
  upper       = false
  min_lower   = 2
  min_numeric = 2
  special     = false
}

# databricks用のリソースグループ作成
resource "azurerm_resource_group" "rg_adb" {
  location = var.location
  name     = "rg-${var.env}-${var.adb}-${random_string.str.result}"

  tags = var.tags
}

# databricksのワークスペース作成
resource "azurerm_databricks_workspace" "ws_adb" {
  name                        = "${var.project_prefix}-${var.adb}-${random_string.str.result}"
  resource_group_name         = azurerm_resource_group.rg_adb.name
  location                    = azurerm_resource_group.rg_adb.location
  sku                         = "premium"
  managed_resource_group_name = "${var.project_prefix}-${var.adb}-managed-${random_string.str.result}"

  tags = var.tags

  custom_parameters {
    no_public_ip = var.no_public_ip
  }
}

# databricksアクセスコネクター作成
resource "azurerm_databricks_access_connector" "ac_adb" {
  name                = "${var.project_prefix}-${var.adb}-accessconnector-${random_string.str.result}"
  resource_group_name = azurerm_resource_group.rg_adb.name
  location            = azurerm_resource_group.rg_adb.location

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# ストレージ作成
resource "azurerm_storage_account" "sa_adb" {
  name                              = "${var.project_prefix}sc${var.adb}${random_string.str.result}"
  resource_group_name               = azurerm_resource_group.rg_adb.name
  location                          = azurerm_resource_group.rg_adb.location
  account_tier                      = "Standard"
  account_kind                      = "StorageV2"
  account_replication_type          = var.storage_replication_type
  min_tls_version                   = "TLS1_2"
  is_hns_enabled                    = true
  infrastructure_encryption_enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# コンテナ作成
resource "azurerm_storage_container" "sa_container" {
  name               = "databricks-metastore-${random_string.str.result}"
  storage_account_id = azurerm_storage_account.sa_adb.id
}

# ストレージ BLOB データ共同作成者
resource "azurerm_role_assignment" "blob_data_contributor" {
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.sa_adb.id
  principal_id         = azurerm_databricks_access_connector.ac_adb.identity[0].principal_id
}

# ストレージ キュー データ共同作成者
resource "azurerm_role_assignment" "queue_data_contributor" {
  role_definition_name = "Storage Queue Data Contributor"
  scope                = azurerm_storage_account.sa_adb.id
  principal_id         = azurerm_databricks_access_connector.ac_adb.identity[0].principal_id
}

# EventGrid EventSubscription 共同作成者
resource "azurerm_role_assignment" "eventgrid_contributor" {
  role_definition_name = "EventGrid EventSubscription Contributor"
  scope                = azurerm_resource_group.rg_adb.id
  principal_id         = azurerm_databricks_access_connector.ac_adb.identity[0].principal_id
}

# Databricksの設定
# メタストア作成
resource "databricks_metastore" "adb_metastore" {
  provider      = databricks.accounts
  name          = "metastore-${random_string.str.result}"
  storage_root  = "abfss://${azurerm_storage_container.sa_container.name}@${azurerm_storage_account.sa_adb.name}.dfs.core.windows.net/metastore-${random_string.str.result}"
  region        = var.location
  owner         = "admin"
  force_destroy = true
}

# Databricksのストレージクレデンシャル
resource "databricks_storage_credential" "this" {
  provider     = databricks.accounts
  metastore_id = databricks_metastore.adb_metastore.id
  name         = "${var.project_prefix}-storage-credential-${random_string.str.result}"

  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.ac_adb.id
  }
}

# メタストアのデータアクセス
resource "databricks_metastore_data_access" "this" {
  provider     = databricks.accounts
  name         = "default-${random_string.str.result}"
  metastore_id = databricks_metastore.adb_metastore.id
  is_default   = true

  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.ac_adb.id
  }
}

# メタストアのアサイン
resource "databricks_metastore_assignment" "this" {
  provider     = databricks.accounts
  metastore_id = databricks_metastore.adb_metastore.id
  workspace_id = azurerm_databricks_workspace.ws_adb.workspace_id
}
