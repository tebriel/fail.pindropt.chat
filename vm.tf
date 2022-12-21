resource "azurerm_virtual_network" "chat" {
  name                = "chat.pindropt.fail-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.chat-pindropt-fail.location
  resource_group_name = azurerm_resource_group.chat-pindropt-fail.name
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.chat-pindropt-fail.name
  virtual_network_name = azurerm_virtual_network.chat.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "zulip-ip" {
  name                = "zulip-ip"
  location            = azurerm_resource_group.chat-pindropt-fail.location
  resource_group_name = azurerm_resource_group.chat-pindropt-fail.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "zulip15" {
  name                = "zulip15"
  location            = azurerm_resource_group.chat-pindropt-fail.location
  resource_group_name = azurerm_resource_group.chat-pindropt-fail.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.zulip-ip.id
  }
}

resource "azurerm_virtual_machine" "zulip" {
  name                  = "zulip"
  location              = azurerm_resource_group.chat-pindropt-fail.location
  resource_group_name   = upper(azurerm_resource_group.chat-pindropt-fail.name)
  network_interface_ids = [azurerm_network_interface.zulip15.id]
  vm_size               = "Standard_B2s"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  storage_os_disk {
    os_type           = "Linux"
    name              = "zulip_OsDisk_1_30f87e8a2d6f4358b651fb56d6775d82"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "zulip"
    admin_username = "tebriel"
  }
  os_profile_linux_config {
    disable_password_authentication = true
  }
}
