data "azurerm_client_config" "current" {}

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

variable "sql_server_name" {
    type = string
    default = "foo"
    description = "Name of mssql service"
}

variable "sql_database_name" {
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

variable "key_vault_key_id" {
    type = string
    default = ""
    description = "Key vault key id"
}

variable "storage_account_name" {
    type = string
    default = "foo"
    description = "Name of storage account"
}

resource "azurerm_resource_group" "foo" {
  name     = var.resource_group
  location = var.resource_location
}

resource "azurerm_virtual_network" "vnet" {
  # oak9: microsoft_networkvirtual_networks.virtual_networks.address_space.address_prefixes is not configured
  name                = "foo-vnet"
  address_space       = ["10.1.12.0/29"]
  location            = azurerm_resource_group.foo.location
  resource_group_name = azurerm_resource_group.foo.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "foo-subnet"
  resource_group_name  = azurerm_resource_group.foo.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.12.0/29"]
  service_endpoints    = ["Microsoft.Sql"]
}
resource "azurerm_sql_server" "foo" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.foo.name
  location                     = azurerm_resource_group.foo.location
  version                      = "12.0"
  administrator_login          = var.administrator_user
  administrator_login_password = var.administrator_login_password
}

resource "azurerm_sql_elasticpool" "foo" {
  name                = "test"
  resource_group_name = azurerm_resource_group.foo.name
  location            = azurerm_resource_group.foo.location
  server_name         = azurerm_sql_server.foo.name
  edition             = "Basic"
  dtu                 = 50
  db_dtu_min          = 0
  db_dtu_max          = 5
  pool_size           = 5000
}

resource "azurerm_sql_active_directory_administrator" "foo" {
  server_name         = azurerm_sql_server.foo.name
  resource_group_name = azurerm_resource_group.foo.name
  login               = "sqladmin"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
}

resource "azurerm_storage_account" "foo" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.foo.name
  location                 = azurerm_resource_group.foo.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_database" "foo" {
  name                = var.mysql_database_name
  resource_group_name = azurerm_resource_group.foo.name
  location            = azurerm_resource_group.foo.location
  server_name         = azurerm_sql_server.foo.name

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.foo.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.foo.primary_access_key
    storage_account_access_key_is_secondary = true
    # retention_in_days                       = 6
  }

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_sql_firewall_rule" "foo" {
  name                = "foo-firewall-rule"
  resource_group_name = azurerm_resource_group.foo.name
  server_name         = azurerm_sql_server.foo.name
  start_ip_address    = "10.0.17.62"
  end_ip_address      = "10.0.17.62"
}

resource "azurerm_sql_virtual_network_rule" "foo" {
  name                = "sql-vnet-rule"
  resource_group_name = azurerm_resource_group.foo.name
  server_name         = azurerm_sql_server.sqlserver.name
  subnet_id           = azurerm_subnet.subnet.id
}