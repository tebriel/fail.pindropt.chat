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

  boot_diagnostics {
    enabled     = true
    storage_uri = ""
  }

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

resource "azurerm_managed_disk" "zulip-data" {
  name                 = "zulip_data"
  location             = azurerm_resource_group.chat-pindropt-fail.location
  resource_group_name  = azurerm_resource_group.chat-pindropt-fail.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "16"
}

resource "azurerm_virtual_machine_data_disk_attachment" "zulip-data" {
  managed_disk_id    = azurerm_managed_disk.zulip-data.id
  virtual_machine_id = azurerm_virtual_machine.zulip.id
  lun                = "0"
  caching            = "None"
}

resource "azurerm_network_security_group" "zulip-nsg" {
  name                = "zulip-nsg"
  location            = azurerm_resource_group.chat-pindropt-fail.location
  resource_group_name = azurerm_resource_group.chat-pindropt-fail.name
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "SSH"
  resource_group_name         = azurerm_resource_group.chat-pindropt-fail.name
  network_security_group_name = azurerm_network_security_group.zulip-nsg.name
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "https" {
  name                        = "HTTPS"
  resource_group_name         = azurerm_resource_group.chat-pindropt-fail.name
  network_security_group_name = azurerm_network_security_group.zulip-nsg.name
  priority                    = 320
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}
