
# --- Secure Key Vault ---
resource "azurerm_key_vault" "kv_secure" {
  name                        = "defenderlabkv-secure123"
  location                    = azurerm_resource_group.lab.location
  resource_group_name         = azurerm_resource_group.lab.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7
  public_network_access_enabled = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"

    ip_rules = [
      "49.37.131.0"
    ]
  }

  tags = {
    environment = "lab"
  }
}

# --- Secure NSG ---
resource "azurerm_network_security_group" "nsg_secure" {
  name                = "secure-nsg"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "lab"
  }
}

# --- Encrypted Managed Disk ---
resource "azurerm_managed_disk" "disk_secure" {
  name                 = "encrypted-lab-disk-secure"
  location             = azurerm_resource_group.lab.location
  resource_group_name  = azurerm_resource_group.lab.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 30
  disk_encryption_set_id = null # Using default encryption with platform-managed key

  tags = {
    environment = "lab"
  }
}
