resource "azurerm_resource_group" "example" {
  name     = "LoadBalancerRG"
  location = "West Europe"
}

resource "azurerm_public_ip" "example" {
  name                = "PublicIPForLB"
  location            = "West US"
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "example" {
  # oak9: azurerm_lb_outbound_rule.enable_tcp_reset is not configured
  # oak9: azurerm_lb_rule.disable_outbound_snat is not configured
  # oak9: azurerm_lb_rule.enable_tcp_reset is not configured
  # oak9: azurerm_lb_rule.enable_floating_ip is not configured
  # oak9: azurerm_lb_rule.load_distribution does not specify the load distribution criteria for the rule
  # oak9: microsoft_networkload_balancers.load_balancers.inbound_nat_pools[0].enable_tcp_reset is not configured
  # oak9: microsoft_networkload_balancers.load_balancers.inbound_nat_pools[0].enable_floating_ip is not configured
  # oak9: azurerm_lb.frontend_ip_configuration.private_ip_address_version is not configured
  # oak9: azurerm_lb.frontend_ip_configuration.private_ip_address is not defined to access load balancer privately
  # oak9: azurerm_lb_probe.request_path is not configured
  name                = "TestLoadBalancer"
  location            = "West US"
  # oak9: azurerm_lb.frontend_ip_configuration.private_ip_address_allocation is not configured
  resource_group_name = azurerm_resource_group.example.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}
resource "azurerm_lb_backend_address_pool" "example" {
  loadbalancer_id = azurerm_lb.example.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_backend_address_pool_address" "example" {
  name                    = "example"
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
  virtual_network_id      = azurerm_virtual_network.example.id
  ip_address              = "10.0.0.1"
}

resource "azurerm_lb_nat_pool" "example" {
  resource_group_name            = azurerm_resource_group.example.name
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "SampleApplicationPool"
  protocol                       = "Tcp"
  frontend_port_start            = 80
  frontend_port_end              = 81
  backend_port                   = 8080
  frontend_ip_configuration_name = "PublicIPAddress"
}


resource "azurerm_lb_nat_rule" "example" {
  # oak9: azurerm_lb_nat_rule.enable_tcp_reset is not configured
  # oak9: azurerm_lb_nat_rule.enable_floating_ip is not configured
  resource_group_name            = azurerm_resource_group.example.name
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "RDPAccess"
  protocol                       = "Tcp"
  # oak9: azurerm_lb_nat_rule.protocol does not specify the protocol that is allowed inbound to the load balancer
  frontend_port                  = 3389
  # oak9: azurerm_lb_nat_rule.frontend_port is not configured
  backend_port                   = 3389
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_outbound_rule" "example" {
  resource_group_name     = azurerm_resource_group.example.name
  loadbalancer_id         = azurerm_lb.example.id
  name                    = "OutboundRule"
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id

  frontend_ip_configuration {
    name = "PublicIPAddress"
  }
}

resource "azurerm_lb_probe" "example" {
  resource_group_name = azurerm_resource_group.example.name
  loadbalancer_id     = azurerm_lb.example.id
  name                = "ssh-running-probe"
  port                = 22
}
resource "azurerm_lb_rule" "example" {
  resource_group_name            = azurerm_resource_group.example.name
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "PublicIPAddress"

}

resource "azurerm_network_security_group" "example" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_network_ddos_protection_plan" "example" {
  name                = "ddospplan1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_virtual_network" "example" {
  name                = "virtualNetwork1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.example.id
    enable = true
  }

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
  }

  subnet {
    name           = "subnet3"
    address_prefix = "10.0.3.0/24"
    security_group = azurerm_network_security_group.example.id
  }

  tags = {
    environment = "Production"
  }
}




