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

variable "subnet_id" {
    type = string
    default = ""
    description = "Subnet ID"
}

resource "azurerm_resource_group" "foo" {
  name     = var.resource_group
  location = var.resource_location
}

resource "azurerm_api_management" "foo" {
  name                = "foo-apim"
  sku_name            = "Developer_1"
  location            = azurerm_resource_group.foo.location
  resource_group_name = azurerm_resource_group.foo.name
  publisher_name      = "foo"
  publisher_email     = "foo@example.com"
  notification_sender_email = "foo@example.com"

  virtual_network_type  = "Internal"         // Valid values include: None, External, Internal.
  # client_certificate_enabled = true           // Supported when sku type is Consumption

  min_api_version = ""

  additional_location {
    location = ""
    virtual_network_configuration {}        // Required when virtual_network_type is External or Internal.
  }

  gateway_disabled = false                  // only supported when additional_location is set

  certificate {
    encoded_certificate = ""                // Base64 Encoded PFX or Base64 Encoded X.509 Certificate
    store_name = "CertificateAuthority"     // Possible values are CertificateAuthority and Root.
    certificate_password = ""
  }

  identity {
    type = "SystemAssigned"          // Possible values are SystemAssigned, UserAssigned, SystemAssigned, UserAssigned (to enable both).
    # identity_ids = []              // Required when type is set to UserAssigned or SystemAssigned, UserAssigned
  }

  variable "key_vault_id" {
    type = string
    default = ""
    description = "The ID of the Key Vault Secret containing the SSL Certificate, which must be should be of the type application/x-pkcs12"
  }

  hostname_configuration {
    management {
      host_name = "api.foo.com"
      key_vault_id = var.key_vault_id
      # certificate = filebase64("./cert.pfx")       // Either key_vault_id or certificate and certificate_password must be specified.
      # certificate_password = ""
      negotiate_client_certificate = false
      ssl_keyvault_identity_client_id = ""
    }

    portal {
      host_name = "api.foo.com"
      # key_vault_id = var.key_vault_id
      # certificate = filebase64("./cert.pfx")       // Either key_vault_id or certificate and certificate_password must be specified.
      # certificate_password = ""
      # negotiate_client_certificate = false
      # ssl_keyvault_identity_client_id = ""
    }

    developer_portal {
      host_name = "api.foo.com"
      key_vault_id = var.key_vault_id
      # certificate = filebase64("./cert.pfx")    // Either key_vault_id or certificate and certificate_password must be specified.
      # certificate_password = ""
      negotiate_client_certificate = false
      ssl_keyvault_identity_client_id = ""
    }

    proxy {
      default_ssl_binding = false
      host_name = "api.foo.com"
      key_vault_id = var.key_vault_id    
      # certificate = ""                        // Either key_vault_id or certificate and certificate_password must be specified.
      # certificate_password = ""            
      # negotiate_client_certificate = false
    }

    scm {
      host_name = "api.foo.com"
      key_vault_id = var.key_vault_id
      # certificate = filebase64("./cert.pfx")   // Either key_vault_id or certificate and certificate_password must be specified.
      # certificate_password = ""
      # negotiate_client_certificate = false
      # ssl_keyvault_identity_client_id = ""
    }
  }

  # policy {
  #   xml_content = ""
  #   xml_link = ""
  # }

  protocols {
    enable_http2 = true
  }

  # security {
  #   enable_backend_ssl30 = false
  #   enable_backend_tls10 = false
  #   enable_backend_tls11 = false
  #   enable_frontend_ssl30 = false
  #   enable_frontend_tls10 = false
  #   enable_frontend_tls11 = false
  #   tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = false
  #   tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = false
  #   tls_ecdheRsa_with_aes128_cbc_sha_ciphers_enabled = false
  #   tls_ecdheRsa_with_aes256_cbc_sha_ciphers_enabled = false
  #   tls_rsa_with_aes128_cbc_sha256_ciphers_enabled = false
  #   tls_rsa_with_aes128_cbc_sha_ciphers_enabled = false
  #   tls_rsa_with_aes128_gcm_sha256_ciphers_enabled = false
  #   tls_rsa_with_aes256_cbc_sha256_ciphers_enabled = false
  #   tls_rsa_with_aes256_cbc_sha_ciphers_enabled = false
  #   enable_triple_des_ciphers  = false
  #   triple_des_ciphers_enabled  = false
  #   disable_backend_ssl30 = false
  #   disable_backend_tls10 = false 
  #   disable_backend_tls11 = false
  #   disable_frontend_ssl30 = false 
  #   disable_frontend_tls10 = false
  #   disable_frontend_tls11 = false
  # }

  sign_in {
    enabled = true
  }

  sign_up {
    enabled = false
    terms_of_service {
      consent_required = true
      enabled = true
      text = "Terms of service = foo"
    }
  }

  tenant_access {
    enabled  = true
  }

  virtual_network_configuration {
    subnet_id = var.subnet_id
  }

  tags {
    Environment = "dev"
  }
}