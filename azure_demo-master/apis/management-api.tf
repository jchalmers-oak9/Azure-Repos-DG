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

resource "azurerm_resource_group" "foo" {
  name     = var.resource_group
  location = var.resource_location
}

resource "azurerm_api_management" "foo" {
  name                = "foo-apim"
  location            = azurerm_resource_group.foo.location
  resource_group_name = azurerm_resource_group.foo.name
  publisher_name      = "My foo-publisher"
  publisher_email     = "foo@foo.com"

  sku_name = "Developer_1"
}

resource "azurerm_api_management_api" "foo" {
  name                = "foo-api"
  resource_group_name = azurerm_resource_group.foo.name
  api_management_name = azurerm_api_management.foo.name
  revision            = "1"
  display_name        = "foo API"  // required when source_api_id is not set
  path                = "foo"      // required when source_api_id is not set
  protocols           = "https"

  description = "Foo API gateway"
  subscription_required = true
  revision_description = ""

  service_url = "http://foo.com"
  soap_pass_through = false

  import {
    content_format = "swagger-link-json"
    content_value  = "http://conferenceapi.azurewebsites.net/?format=json"
  }

  oauth2_authorization {
    authorization_server_name = ""    //  The name of an OAuth2 Authorization Server.
    scope = ""
  }

  openid_authentication {
    openid_provider_name = ""              // The name of an OpenID Connect Provider.
    bearer_token_sending_methods = []      //  A list of zero or more methods. Valid values are authorizationHeader and query.
  }

  subscription_key_parameter_names {
    header = "" //   The name of the HTTP Header which should be used for the Subscription Key.
    query = "" //   The name of the QueryString parameter which should be used for the Subscription Key.
  }
}

resource "azurerm_api_management_logger" "foo" {
  name                = "foo-apimlogger"
  api_management_name = azurerm_api_management.foo.name
  resource_group_name = azurerm_resource_group.foo.name

  application_insights {
    instrumentation_key = azurerm_application_insights.foo.instrumentation_key
  }
}

resource "azurerm_api_management_api_diagnostic" "foo" {
  resource_group_name      = azurerm_resource_group.foo.name
  api_management_name      = azurerm_api_management.foo.name
  api_name                 = azurerm_api_management_api.foo.name
  api_management_logger_id = azurerm_api_management_logger.foo.id

  sampling_percentage       = 5.0
  always_log_errors         = true
  log_client_ip             = true
  verbosity                 = "Verbose"
  http_correlation_protocol = "W3C"

  frontend_request {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "accept",
      "origin",
    ]
  }

  frontend_response {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "content-length",
      "origin",
    ]
  }

  backend_request {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "accept",
      "origin",
    ]
  }

  backend_response {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "content-length",
      "origin",
    ]
  }
}

resource "azurerm_api_management_api_operation" "foo" {
  operation_id        = "user-delete"
  api_name            = data.azurerm_api_management_api.foo.name
  api_management_name = data.azurerm_api_management_api.foo.api_management_name
  resource_group_name = data.azurerm_api_management_api.foo.resource_group_name
  display_name        = "Delete User Operation"
  method              = "DELETE"
  url_template        = "/users/{id}/delete"
  description         = "This can only be done by the logged in user."

  response {
    status_code = 200
  }
}

resource "azurerm_api_management_api_operation_policy" "foo" {
  api_name            = azurerm_api_management_api_operation.foo.api_name
  api_management_name = azurerm_api_management_api_operation.foo.api_management_name
  resource_group_name = azurerm_api_management_api_operation.foo.resource_group_name
  operation_id        = azurerm_api_management_api_operation.foo.operation_id

  xml_content = <<XML
<policies>
  <inbound>
    <find-and-replace from="xyz" to="abc" />
  </inbound>
</policies>
XML

}

resource "azurerm_api_management_api_operation_tag" "foo" {
  api_operation_id = azurerm_api_management_api_operation.foo.id
  name             = "foo-Tag"
}

resource "azurerm_api_management_api_release" "foo" {
  name   = "foo-Api-Release"
  api_id = azurerm_api_management_api.foo.id
}