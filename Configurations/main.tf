# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.98"
    }
  }
  required_version = ">= 1.1.6"
}

provider "azurerm" {
  features {}
}
locals {
  #Construct Tag Data for Resource
  resourceTags = {
    environment  = var.environment
    createdBy    = var.createdBy
    managedBy    = var.managedBy
    colorBand    = var.colorBand
    purpose      = var.purpose
    lastUpdateOn = formatdate("DD-MM-YYYY hh:mm:ss ZZZ", timestamp())
  }
}

#Resource Group 
resource "azurerm_resource_group" "webserverTfPackerRG" {
  name     = "rg-${var.suffix}"
  location = var.location
  tags     = local.resourceTags
}
#Virtual Network
resource "azurerm_virtual_network" "webserverTfPackerVNET" {
  name                = "vnet-${var.suffix}"
  address_space       = ["10.0.0.0/22"]
  location            = var.location
  resource_group_name = azurerm_resource_group.webserverTfPackerRG.name
  tags                = local.resourceTags
}
#Azure Subnet
resource "azurerm_subnet" "webserverTfPackerSNET" {
  name                 = "snet-${var.suffix}"
  resource_group_name  = azurerm_resource_group.webserverTfPackerRG.name
  virtual_network_name = azurerm_virtual_network.webserverTfPackerVNET.name
  address_prefixes     = ["10.0.0.0/24"]
}
#Network Security Groups
resource "azurerm_network_security_group" "webserverTfPackerNSG" {
  name                = "nsg-${var.suffix}"
  resource_group_name = azurerm_resource_group.webserverTfPackerRG.name
  location            = var.location
  tags                = local.resourceTags
  #Security Rules Defined to allow explicitly access to other VMs on the subnet
  security_rule {
    name                       = "AllowVMAccessOnSubnet"
    description                = "Allow access to other VMs on the subnet"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
    access                     = "Allow"
    priority                   = "2000"
    direction                  = "Inbound"
  }
  #Security Rules Defined to deny direct access from the internet
  security_rule {
    name                       = "DenyDirectAcessFromInternet"
    description                = "Denies direct access from the internet"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
    access                     = "Deny"
    priority                   = "1000"
    direction                  = "Inbound"
  }
}
#Network Interface
resource "azurerm_network_interface" "webserverTfPackerNIC" {
  count               = var.vmCount
  name                = "nic-${var.suffix}-${var.serverName[count.index]}-udacity"
  resource_group_name = azurerm_resource_group.webserverTfPackerRG.name
  location            = var.location
  tags                = local.resourceTags

  ip_configuration {
    name                          = "ipconfig-${var.suffix}-udacity"
    subnet_id                     = azurerm_subnet.webserverTfPackerSNET.id
    private_ip_address_allocation = "Dynamic"
  }
}
#Public IP Creation
resource "azurerm_public_ip" "webserverTfPackerPIP" {
  name                = "pip-${var.suffix}"
  resource_group_name = azurerm_resource_group.webserverTfPackerRG.name
  location            = var.location
  allocation_method   = "Static"
  tags                = local.resourceTags
}
#Load Balancer Creation
resource "azurerm_lb" "webserverTfPackerLB" {
  name                = "lbi-${var.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.webserverTfPackerRG.name
  tags                = local.resourceTags

  frontend_ip_configuration {
    name                 = "frontendip-${var.suffix}"
    public_ip_address_id = azurerm_public_ip.webserverTfPackerPIP.id
  }
}
#Backend Address Pool for the Load Balancer 
resource "azurerm_lb_backend_address_pool" "webserverTfPackerBackendLB" {
  loadbalancer_id = azurerm_lb.webserverTfPackerLB.id
  name            = "backend-address-${var.suffix}"
}
#Address Pool Association for the Network Interface and Load Balancer
resource "azurerm_network_interface_backend_address_pool_association" "webserverTfPackerBackendNicLB" {
  count                   = var.vmCount
  network_interface_id    = azurerm_network_interface.webserverTfPackerNIC[count.index].id
  ip_configuration_name   = "ipconfig-${var.suffix}-udacity"
  backend_address_pool_id = azurerm_lb_backend_address_pool.webserverTfPackerBackendLB.id
}
#Virtual Machine Availablity Set
resource "azurerm_availability_set" "webserverTfPackerAVAIL" {
  name                         = "avail-${var.suffix}"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.webserverTfPackerRG.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  tags                         = local.resourceTags
}
#Linux Virtual Machines using the image which we have deployed using packer
resource "azurerm_linux_virtual_machine" "webserverTfPackerLinuxVM" {
  name                            = "linux-vm-${var.suffix}-${count.index}"
  resource_group_name             = azurerm_resource_group.webserverTfPackerRG.name
  location                        = var.location
  size                            = "Standard_D2s_v3"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  count                           = var.vmCount
  availability_set_id             = azurerm_availability_set.webserverTfPackerAVAIL.id


  network_interface_ids = [element(azurerm_network_interface.webserverTfPackerNIC.*.id, count.index)]
  source_image_id       = var.packerImage

  os_disk {
    storage_account_type = var.storageAccountType
    caching              = "ReadWrite"
  }
  tags = local.resourceTags

}
#Managed Disks for VMs
resource "azurerm_managed_disk" "webserverTfPackerMD" {
  name                 = "md-${var.suffix}"
  location             = var.location
  resource_group_name  = azurerm_resource_group.webserverTfPackerRG.name
  storage_account_type = var.storageAccountType
  create_option        = "Empty"
  disk_size_gb         = "1"
  tags                 = local.resourceTags
}
