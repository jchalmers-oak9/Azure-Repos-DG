resource "azurerm_storage_encryption_scope" "example" {
  name               = "microsoftmanaged"
  storage_account_id = azurerm_storage_account.demo_storage_account.id
  source             = "Microsoft.Keyvault"
}
