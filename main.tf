/* locals {
  nicName = "${local.serverName}-NIC"
  osDiskName = "${local.serverName}-OSDisk"
  ipConfigName = "${local.serverName}-IPConfig"
  serverName = "${var.serverNamePrefix}${count.index}"
}
*/

terraform {
  required_providers {
      azurerm = {
          source = "hashicorp/azurerm"
          version = "~> 2.65"
      }
  }
      required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {

  }
}

resource "azurerm_resource_group" "rg" {
    name = var.rgName
    location = var.rgLocation
}

data "azurerm_subnet" "existingSubnet" {
    name = var.deploymentSubnetName
    virtual_network_name = var.deploymentVnetName
    resource_group_name = var.vnetRGName
}

resource "azurerm_network_interface" "vmNic" {
    count = var.numberOfVMs
  //name = local.nicName
  name = "${var.serverNamePrefix}${count.index +1}-NIC"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    //name = local.ipConfigName
    name = "${var.serverNamePrefix}${count.index+1}-IPConfig"
    subnet_id = "${data.azurerm_subnet.existingSubnet.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
    count = var.numberOfVMs

    //name = local.serverName
    name = "${var.serverNamePrefix}${count.index+1}"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = var.vmSize
    admin_username = "DenisCooper"
    admin_password = "MyPassword@123"
    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
      //name = local.osDiskName
      name = "${var.serverNamePrefix}${count.index+1}-OSDisk"
    }
    source_image_reference {
      publisher = "MicrosoftWindowsServer"
      offer = "WindowsServer"
      sku = "2016-Datacenter"
      version = "latest"
    }
    network_interface_ids = [
        azurerm_network_interface.vmNic[count.index].id
    ]
  
}