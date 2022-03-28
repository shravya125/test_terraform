terraform {
   required_version = ">= 0.11"

}


provider "azurerm" {
 features{}
  client_id="9af9399e-24a0-43e8-abd6-f4419532728c"
  client_secret="iKi7Q~5NYOh6U3l9v5VTwJu2yQ9sj6ge8d88M"
  tenant_id="d9c49be0-fa1c-4bc3-a7b3-dc6447345526"
  subscription_id="86355a5e-01d5-426a-8de8-b0d89f47844d"
}

resource "azurerm_resource_group" "vrg" {
  name     = "vrg"
  location = "eastus"
}

resource "azurerm_virtual_network" "app1" {
  name                = "app1"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.vrg.name
  address_space       = ["10.0.0.0/16"]
}

//tags = {
//environment = "Production"
//department  = "health"
//team        = "intergrations"
//}


resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vrg.location
  resource_group_name = azurerm_resource_group.vrg.name
}

resource "azurerm_subnet" "net1" {
  name                 = "netl"
  resource_group_name  = azurerm_resource_group.vrg.name
  virtual_network_name = azurerm_virtual_network.app1.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "vnic" {
  name                = "vnic"
  location            = azurerm_resource_group.vrg.location
  resource_group_name = azurerm_resource_group.vrg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.net1.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_virtual_machine" "ashuvm"{
  resource_group_name   = azurerm_resource_group.vrg.name
  name                  = "ashuvm"
  vm_size               = "Standard_DS1_v2"
  location              = azurerm_resource_group.vrg.location
  network_interface_ids = [azurerm_network_interface.vnic.id]

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku   = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "ashuvm"
    admin_username = "azureuser"
    admin_password = "Welcome123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

