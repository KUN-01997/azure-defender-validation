terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74.0"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "lab" {
  name     = "defender-misconfig-rg"
  location = "eastus"
}

resource "azurerm_network_security_group" "insecure" {
  name                = "insecure-nsg"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }
}

resource "azurerm_key_vault" "public" {
  name                        = "defenderlabkv1234"
  location                    = azurerm_resource_group.lab.location
  resource_group_name         = azurerm_resource_group.lab.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  enable_rbac_authorization   = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }
}

resource "azurerm_managed_disk" "unencrypted" {
  name                 = "unencrypted-disk"
  location             = azurerm_resource_group.lab.location
  resource_group_name  = azurerm_resource_group.lab.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32
  os_type              = "Linux"
}


resource "azurerm_security_center_subscription_pricing" "keyvault" {
  tier          = "Standard"
  resource_type = "KeyVaults"
}

resource "azurerm_virtual_network" "lab_vnet" {
  name                = "lab-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
}

resource "azurerm_subnet" "lab_subnet" {
  name                 = "lab-subnet"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "lab_subnet_assoc" {
  subnet_id                 = azurerm_subnet.lab_subnet.id
  network_security_group_id = azurerm_network_security_group.insecure.id
}

resource "azurerm_public_ip" "lab_ip" {
  name                = "lab-ip"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "lab_nic" {
  name                = "lab-nic"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "lab_vm" {
  name                = "lab-vm"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  disable_password_authentication = true
  network_interface_ids = [azurerm_network_interface.lab_nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMSC7xW7SAK+dt1tCvl21vjcJdK/K4FQXWroOfaZTZfyKXYzy/qmsDxZrnU59LKnXVCEtwEEKMWsmFyVMwGQRs6raE61hcO6YjK/83GunjJ8McAI8F+Qdfiv5XiDYJGMnUFlF910o6csAca6JvOlQ+jUV8zxMEMAL168p8Ol3qU9GHyao5GsVN2ov2OyjxpdUDj8j4W6T70drEIa3hqT2xa1RYyv4jkZjTyoBgZcfSJ/W2eduIOnoUcyCge8exkmxoQ7NOyWFlDWybaXFgdmwWaScApUbdWFFgg0wQL/aRl/V2HkdK3MagP9+Z9Vc/+9uDNElRyyT9ELIoZu0cNNgt1Ky5+IS6Vggrkz78kWSiwB5IbPyVEOeeZuDYtcyk3vaS7p8D98jP8zV/SQk/PEhnZHH2lhZKZdy0aawEk0vjXDRKQQRIhyf1q30vCeseqAbehBFWf9Aot2kfR9g8Qu+iaYwQUk8nJl1cMmVnbPrOnZjlrZ4FVXpNh7ZkTZ5b5tcJR+/x5TgYTKRIA4vXGU0btYKYQrQLQ7FW7WYEIhqEI9uz+dPldxrC+QAk2T0VD0TcNV/uaZ5uhD23JMIE9zJhoEeZkdW6a4lhQfPkwLQ0U4f4pvuHOw5cuWR3AijCHqRAN+uLPoQPgQSI4+jvezauMs6vtkp50BPH5lFW9vHmbw== nayankotharu@Nayans-MacBook-Pro.local"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk_attach" {
  managed_disk_id    = azurerm_managed_disk.unencrypted.id
  virtual_machine_id = azurerm_linux_virtual_machine.lab_vm.id
  lun                = 0
  caching            = "None"
}
