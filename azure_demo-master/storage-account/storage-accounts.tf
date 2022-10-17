resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}

resource "azurerm_storage_account" "demo_storage_account" {
  # oak9: microsoft_storage.storage_accounts.network_acls.virtual_network_rules is not configured
  # oak9: azurerm_key_vault.network_acls.bypass is not configured
  # oak9: azurerm_key_vault.network_acls.default_action is not set to deny by default
  # name should be unique
  name                     = "oka9uniquestoragename"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"

  # Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS.
  account_replication_type = "GRS"
  # BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2.
  account_kind  = "StorageV2"
  enable_https_traffic_only = true

  #  Possible values are TLS1_0, TLS1_1, and TLS1_2.
  min_tls_version = "TLS1_2"
  allow_blob_public_access = false
  shared_access_key_enabled = true
  large_file_share_enabled = false

  # This can only be true when account_tier is Standard or when account_tier is Premium and account_kind is BlockBlobStorage
  is_hns_enabled = true

  nfsv3_enabled = false
  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["100.0.0.1"]
    # oak9: azurerm_storage_account.network_rules.ip_rules is not configured
    virtual_network_subnet_ids = [azurerm_subnet.example.id]
  }

  identity {
    type = "SystemAssigned"
  }
  blob_properties {
    cors_rule {
      allowed_headers = ["*"]
      allowed_methods = ["DELETE", "GET", "HEAD", "MERGE", "POST", "OPTIONS", "PUT", "PATCH"]
      max_age_in_seconds = 100
      allowed_origins = ["*"]
      exposed_headers = ["*"]
    }
    # delete_retention_policy {
    #   days = 365
    # }
    # container_delete_retention_policy {
    #    days = 365
    # }

    versioning_enabled = false
    change_feed_enabled = false
    default_service_version = "2020-06-12"
    last_access_time_enabled = true
  }
  
  tags = {
    name = "storage-accounts"
    environment = "dev"
  }
}
