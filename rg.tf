resource "azurerm_resource_group" "chat-pindropt-fail" {
  name     = "chat.pindropt.fail"
  location = "South Central US"
}

resource "azurerm_management_lock" "chat-pindropt-fail-rg" {
  name       = "${azurerm_resource_group.chat-pindropt-fail.name}-lock"
  scope      = azurerm_resource_group.chat-pindropt-fail.id
  lock_level = "CanNotDelete"
  notes      = "Managed by terraform."
}
