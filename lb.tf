resource "azurerm_public_ip" "zulip-ipv4" {
  name                = "zulip-ipv4"
  location            = azurerm_resource_group.chat-pindropt-fail.location
  resource_group_name = azurerm_resource_group.chat-pindropt-fail.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_public_ip" "zulip-ipv6" {
  name                = "zulip-ipv6"
  location            = azurerm_resource_group.chat-pindropt-fail.location
  resource_group_name = azurerm_resource_group.chat-pindropt-fail.name
  allocation_method   = "Static"
  ip_version          = "IPv6"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_lb" "chat-pindropt-fail" {
  name                = "chat-lb"
  location            = azurerm_resource_group.chat-pindropt-fail.location
  resource_group_name = azurerm_resource_group.chat-pindropt-fail.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "zulip-ipv4"
    public_ip_address_id = azurerm_public_ip.zulip-ipv4.id
  }

  frontend_ip_configuration {
    name                 = "zulip-ipv6"
    public_ip_address_id = azurerm_public_ip.zulip-ipv6.id
  }
}

resource "azurerm_lb_nat_rule" "https" {
  resource_group_name            = azurerm_resource_group.chat-pindropt-fail.name
  loadbalancer_id                = azurerm_lb.chat-pindropt-fail.id
  name                           = "https"
  protocol                       = "Tcp"
  frontend_port_start            = 443
  frontend_port_end              = 443
  backend_port                   = 443
  frontend_ip_configuration_name = azurerm_public_ip.zulip-ipv4.name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.zulip.id
}

resource "azurerm_lb_nat_rule" "https-ipv6" {
  resource_group_name            = azurerm_resource_group.chat-pindropt-fail.name
  loadbalancer_id                = azurerm_lb.chat-pindropt-fail.id
  name                           = "https-ipv6"
  protocol                       = "Tcp"
  frontend_port_start            = 443
  frontend_port_end              = 443
  backend_port                   = 443
  frontend_ip_configuration_name = azurerm_public_ip.zulip-ipv6.name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.zulip.id
}


resource "azurerm_lb_backend_address_pool" "zulip" {
  loadbalancer_id = azurerm_lb.chat-pindropt-fail.id
  name            = "zulip"
}

resource "azurerm_lb_backend_address_pool_address" "zulip-vm" {
  name                    = "99fba80b-70a3-48f9-b7e1-beab0f7e4f1a"
  backend_address_pool_id = azurerm_lb_backend_address_pool.zulip.id
  virtual_network_id      = azurerm_virtual_network.chat.id
  ip_address              = azurerm_network_interface.zulip15.private_ip_address
}
