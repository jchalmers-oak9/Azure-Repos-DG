resource "azurerm_virtual_network" "example" {
  name                = "virtnetname"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "subnetname"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]
}

resource "azurerm_network_interface" "test" {
  name                = "acctni"
  location            = azurerm_resource_group.example.location
  resource_group_name = "${azurerm_resource_group.example.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.example.id}"
    private_ip_address_allocation = "dynamic"
  }
}

# resource "azurerm_storage_account_network_rules" "test" {
#   resource_group_name  = azurerm_resource_group.example.name
#   storage_account_name = azurerm_storage_account.demo_storage_account.name

#   default_action             = "Allow"
#   ip_rules                   = ["127.0.0.1"]
#   virtual_network_subnet_ids = [azurerm_subnet.example.id]
#   bypass                     = ["Metrics"]
# }

# resource "azurerm_storage_account_network_rules" "netrules" {
#   resource_group_name  = azurerm_resource_group.example.name
#   storage_account_name = azurerm_storage_account.demo_storage_account.name

#   default_action = "Deny"
#   bypass = [
#     "Metrics",
#     "Logging",
#     "AzureServices"
#   ]

#   # depends_on = [
#   #   azurerm_storage_container.storage_container,
#   # ]
# }

