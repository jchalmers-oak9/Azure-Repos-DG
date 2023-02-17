resource "azurerm_storage_account" "oak9examplestoracc" {
  # oak9: Define Tags for Storage Accounts
  name                     = "oak9examplestoracc"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.oak9examplestoracc.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "example" {
  name                   = "my-awesome-content.zip"
  storage_account_name   = azurerm_storage_account.oak9examplestoracc.name
  storage_container_name = azurerm_storage_container.example.name
  type                   = "Block"
  # source                 = "./zip/some-local-file.zip"
}
