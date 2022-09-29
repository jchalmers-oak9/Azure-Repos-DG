variable "resource_group" {
    type = string
    default = "foo"
    description = "Name of the resource group"  
}

variable "resource_location" {
    type = string
    default = "West Europe"
    description = "Location of the resource group"
}

variable "storage_account_name" {
    type = string
    default = "foo"
    description = "Name of storage account"
}

variable "mssql_server_name" {
    type = string
    default = "foo"
    description = "Name of mssql service"
}

variable "mssql_database_name" {
    type = string
    default = "foo"
    description = "Name of mssql database"
}

variable "administrator_user" {
    type = string
    default = "foo"
    description = "Name of administrator user"
}

variable "administrator_login_password" {
    type = string
    default = ""
    description = "Password of administrator user"
}

variable "mssql_job_user" {
    type = string
    default = "foo"
    description = "Name of administrator user"
}

variable "mssql_job_user_password" {
    type = string
    default = ""
    description = "Password of administrator user"
}

variable "key_vault_key_id" {
    type = string
    default = ""
    description = "Key vault key id"
}

resource "azurerm_resource_group" "foo" {
  name     = var.resource_group
  location = var.resource_location
}

resource "azurerm_storage_account" "foo" {
  # oak9: azurerm_storage_account.tags is not configured
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.foo.name
  location                 = azurerm_resource_group.foo.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_mssql_server" "foo" {
  name                         = var.mssql_server_name
  resource_group_name          = azurerm_resource_group.foo.name
  location                     = azurerm_resource_group.foo.location
  version                      = "12.0"
  administrator_login          = var.administrator_user
  administrator_login_password = var.administrator_login_password
}

resource "azurerm_mssql_database" "foo" {
  name           = var.mssql_database_name
  server_id      = azurerm_mssql_server.foo.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"             // Possible values LicenseIncluded and BasePrice
  max_size_gb    = 4
  read_scale     = true
  sku_name       = "BC_Gen5_2"
  zone_redundant = false                 //  only settable for Premium and Business Critical databases.

  # Required for "Serverless" SKU's
  auto_pause_delay_in_minutes = -1       // automatic pause is disabled
  create_mode = "Default"                // Possible values are Copy, Default, OnlineSecondary, PointInTimeRestore, Recovery, Restore, RestoreExternalBackup, RestoreExternalBackupSecondary, RestoreLongTermRetentionBackup and Secondary.
  #elastic_pool_id = ""

  # geo_backup_enabled = false           //  Only applicable for DataWarehouse SKUs (DW*)
  # read_replica_count = 1               //  Only applicable for Hyperscale edition databases.

  long_term_retention_policy {
    monthly_retention = "PT0S"
    week_of_year =  1
    weekly_retention = "PT0S"
    yearly_retention = "PT0S"
  }

  short_term_retention_policy {
      retention_days = 7
  }

  threat_detection_policy {
    state = "Enabled"                      //   Possible values are Enabled, Disabled or New.
    disabled_alerts = []
    email_account_admins = "Enabled"
    email_addresses = ["foo1@example.com", "foo2@example.com"]
    retention_days = 30
    storage_account_access_key = azurerm_storage_account.foo.primary_access_key
    storage_endpoint = azurerm_storage_account.foo.primary_blob_endpoint
    use_server_default = "Disabled"
  }

  tags = {
    Environment = "Dev"
  }
}

resource "azurerm_mssql_database_extended_auditing_policy" "foo" {
  database_id                             = azurerm_mssql_database.foo.id
  storage_endpoint                        = azurerm_storage_account.foo.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.foo.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 6
}


resource "azurerm_mssql_elasticpool" "foo" {
  name                = "test-epool"
  resource_group_name = azurerm_resource_group.foo.name
  location            = azurerm_resource_group.foo.location
  server_name         = azurerm_mssql_server.foo.name
  license_type        = "LicenseIncluded"
  max_size_gb         = 756

  sku {
    name     = "GP_Gen5"
    tier     = "GeneralPurpose"
    family   = "Gen5"
    capacity = 4
  }

  per_database_settings {
    min_capacity = 0.25
    max_capacity = 4
  }
}

resource "azurerm_mssql_firewall_rule" "foo" {
  name             = "foo"
  server_id        = azurerm_mssql_server.foo.id
  start_ip_address = "40.112.0.0"
  end_ip_address   = "40.112.255.255"
}


resource "azurerm_mssql_job_agent" "foo" {
  name        = "foo-job-agent"
  location    = azurerm_resource_group.foo.location
  database_id = azurerm_mssql_database.foo.id
}

resource "azurerm_mssql_job_credential" "foo" {
  name         = "foo-credential"
  job_agent_id = azurerm_mssql_job_agent.foo.id
  username     = var.mssql_job_user
  password     = var.mssql_job_user_password
}

resource "azurerm_mssql_server_transparent_data_encryption" "foo" {
  server_id        = azurerm_mssql_server.foo.id
  key_vault_key_id = var.key_vault_key_id
}

resource "azurerm_mssql_server_security_alert_policy" "foo" {
  resource_group_name = azurerm_resource_group.foo.name
  server_name         = azurerm_mssql_server.foo.name
  state               = "Enabled"
}

resource "azurerm_storage_container" "foo" {
  name                  = "foo-storage-container"
  storage_account_name  = azurerm_storage_account.foo.name
  container_access_type = "private"
}

resource "azurerm_mssql_server_vulnerability_assessment" "foo" {
  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.foo.id
  storage_container_path          = "${azurerm_storage_account.foo.primary_blob_endpoint}${azurerm_storage_container.foo.name}/"
  storage_account_access_key      = azurerm_storage_account.foo.primary_access_key

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
    emails = [
      "foo1@example.com",
      "foo2@example.com"
    ]
  }
}