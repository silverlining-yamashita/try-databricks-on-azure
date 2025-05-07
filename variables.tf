# 環境変数より取得する
variable "ARM_CLIENT_ID" {
  type = string
}
variable "ARM_CLIENT_SECRET" {
  type = string
}
variable "ARM_TENANT_ID" {
  type = string
}
variable "DATABRICKS_ACCOUNT_ID" {
  type        = string
  description = "アカウントIDは手動で調べて、手動で設定を行う"
}

# Basic settings
variable "tags" {
  type = map(any)
}

variable "env" {
  type = string
}

variable "location" {
  type        = string
  description = "databricks location"

}

variable "project_prefix" {
  type        = string
  description = "project prefix"
}

variable "adb" {
  type        = string
  description = "databricks prefix"
}

variable "no_public_ip" {
  type        = bool
  description = "Defines whether Secure Cluster Connectivity (No Public IP) should be enabled."
}

variable "storage_replication_type" {
  type        = string
  description = "storage replication type"
}
