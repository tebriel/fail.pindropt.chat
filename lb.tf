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

resource "azurerm_lb_backend_address_pool" "zulip" {
  loadbalancer_id = azurerm_lb.chat-pindropt-fail.id
  name            = "zulip"
}
